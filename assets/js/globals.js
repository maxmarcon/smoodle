import dateFns from 'date-fns'

export const InitialLocale = window.smoodle_locale || 'en'

export function dotAccessObject(obj, deep_key) {
  if (!(obj instanceof Object)) {
    throw "dotAccessObject should be called with an object";
  }
  let retval = undefined;
  let keys = deep_key.split('.');
  keys.every(function(key) {
    if (obj.hasOwnProperty(key)) {
      obj = obj[key]
      if (!(obj instanceof Object) || (obj instanceof Array)) {
        retval = obj
        return false;
      }
      return true;
    } else {
      return false;
    }
  });
  return retval;
}

export function stringifyServerError(error) {
  if (error instanceof Array) {
    return error.map(stringifyServerError).join(', ');
  } else if (error instanceof Object) {
    return stringifyServerError(Object.values(error));
  }
  return error;
}

export const stepValidationMixin = {
  data: () => ({
    locallyValidatedStep: 0,
    remotelyValidatedStep: 0
  }),
  methods: {
    clearErrorFields() {
      Object.values(this.errorsMap).map(group => group.fields).forEach((fieldMap) => {
        for (let field in fieldMap) {
          let fieldMapObj = fieldMap[field];
          this[fieldMapObj.errorField] = null;
        }
      })
    },
    localValidation() {
      this.clearErrorFields();
      Object.values(this.errorsMap).filter(group => group.step == this.step).map(group => group.fields).forEach((fieldMap) => {
        for (let field in fieldMap) {
          let fieldMapObj = fieldMap[field];
          let errorField = fieldMapObj.errorField;
          if (this[errorField]) {
            // was already set, don't overwrite
            return;
          }

          let errorMsgs = []
          if (fieldMapObj.required && (!this[field] || (this[field] instanceof Array && this[field].length <= 0))) {
            errorMsgs.push(this.$i18n.t('errors.required_field'))
          }
          if (fieldMapObj.customValidation) {
            let msg = this.customValidate(field, this[field])
            if (msg) {
              errorMsgs.push(msg)
            }
          }
          if (errorMsgs.length) {
            this[errorField] = errorMsgs.join(', ')
          }

          if (fieldMapObj.confirmation) {
            let confirmation_field = `${field}_confirmation`;
            let confirmation_error_field = `${errorField}_confirmation`;
            this[confirmation_error_field] = (
              this[field] == this[confirmation_field] ? null : this.$i18n.t('errors.confirmation_required', {
                field: field
              })
            );
          }
        }
      })
      this.locallyValidatedStep = this.step
    },
    showGroupOkIcon(groupName) {
      let group = this.errorsMap[groupName] || {}
      return this.remotelyValidatedStep >= group.step && !this.groupHasErrors(group);
    },
    showGroupErrorIcon(groupName) {
      let group = this.errorsMap[groupName] || {}
      return this.remotelyValidatedStep >= group.step && this.groupHasErrors(group);
    },
    groupBgVariant(groupName) {
      let group = this.errorsMap[groupName] || {}
      if (this.remotelyValidatedStep >= group.step) {
        return (this.groupHasErrors(group) ? 'danger' : 'success');
      } else {
        return 'secondary'
      }
    },
    groupHasErrors(group) {
      return Object.values(group.fields).find(field => this[field.errorField])
    },
    stepHasErrors(step) {
      return Object.values(this.errorsMap).filter(group => group.step == step).find(this.groupHasErrors)
    },
    inputFieldClass(field) {
      let group = Object.values(this.errorsMap).find(group => field in group.fields);
      if (group) {
        let errorField = group.fields[field].errorField;
        if (this[errorField]) {
          return 'is-invalid';
        } else if (Math.max(this.remotelyValidatedStep, this.locallyValidatedStep) >= group.step) {
          return 'is-valid';
        }
      }
    },
    setServerErrors(errors = {}) {
      function setErrorField(fieldMap, errors) {
        let errorKeys = fieldMap.errorKeys;
        let errorField = fieldMap.errorField;
        errorKeys = errorKeys instanceof Array ? errorKeys : [errorKeys];
        let key_with_error = errorKeys.find(key => dotAccessObject(errors, key));
        this[errorField] = (key_with_error ? stringifyServerError(dotAccessObject(errors, key_with_error)) : null);
        return key_with_error;
      }

      Object.values(this.errorsMap)
        .filter(group => group.step === undefined || group.step <= this.step)
        .map(group => Object.values(group.fields))
        .flat()
        .forEach(fieldMap => setErrorField.call(this, fieldMap, errors))

      this.remotelyValidatedStep = Math.max(this.remotelyValidatedStep, this.step)
    }
  },
  computed: {
    firstStepWithErrors() {
      let stepsWithErrors = Object.values(this.errorsMap).filter((group) => group.step && this.groupHasErrors(group)).map(group => group.step)
      if (stepsWithErrors.length == 0) {
        return 0
      } else {
        return Math.min(...stepsWithErrors)
      }
    }
  }
}

export const scrollToTopMixin = {
  methods: {
    scrollToTop() {
      if (this.$scrollTo) {
        return this.$scrollTo('main');
      }
    }
  }
}

export const restMixin = {
  data() {
    return {
      requestOngoing: false,
      apiVersion: 'v1'
    }
  },
  methods: {
    restRequest(path, config) {
      config = Object.assign({
        url: [null, this.apiVersion, path].join('/'),
        headers: {
          'Accept-Language': this.$i18n.locale
        },
        showErrors: true,
        spinnerDelay: 100
      }, config);

      let self = this;

      let loader = null;
      let timeout = setTimeout(function() {
        loader = self.$loading.show();
      }, config.spinnerDelay);

      this.requestOngoing = true;

      return this.$http.request(
        config
      ).catch(function(error) {
        if (config.showErrors) {
          if (!error.response) {
            if (error.request) {
              self.showInErrorBar(self.$i18n.t('errors.network'))
            } else {
              self.showInErrorBar(self.$i18n.t('errors.generic', {
                message: error.message
              }))
            }
          }
        }
        throw error;
      }).finally(function() {
        clearTimeout(timeout);
        if (loader) {
          loader.hide();
        }
        self.requestOngoing = false;
      });
    }
  }
}

export const errorBarMixin = {
  data() {
    return {
      errorCodeMessages: {
        422: 'errors.unprocessable_entity',
        404: 'errors.not_found'
      }
    }
  },
  methods: {
    showErrorCodeInErrorBar(code) {
      let message = this.errorCodeMessages[code] ? this.$i18n.t(this.errorCodeMessages[code]) : this.$i18n.t('errors.server', {
        code
      })
      this.showInErrorBar(message)
    },
    showInErrorBar(message) {
      this.$refs.errorBar.show(message);
      if (this.scrollToTop) {
        this.scrollToTop()
      }
    }
  }
}

export const eventDataMixin = {
  data() {
    return {
      eventName: null,
      eventOrganizer: null,
      eventOrganizerEmail: null,
      eventOrganizerEmail_confirmation: null,
      eventDesc: null,
      eventState: null,
      eventShareLink: null,
      eventPossibleDates: [],
      eventScheduledFrom: null,
      eventScheduledTo: null,
      eventInsertedAt: null,
      eventModifiedAt: null,
      eventWeekdays: null,
      eventWeekdays: this.initialWeekdays(),
      eventOrganizerMessage: null
    }
  },
  methods: {
    assignEventData({
      name,
      organizer,
      email,
      desc,
      state,
      scheduled_from,
      scheduled_to,
      share_link,
      inserted_at,
      updated_at,
      preferences,
      possible_dates = [],
      organizer_message
    }) {
      this.eventName = name
      this.eventOrganizer = organizer
      this.eventOrganizerEmail = email
      this.eventDesc = desc
      this.eventPossibleDates = possible_dates.map(({
        date_from,
        date_to,
        rank
      }) => ({
        date_from: dateFns.parse(date_from),
        date_to: dateFns.parse(date_to),
        rank
      }))
      this.eventState = state
      this.eventScheduledFrom = scheduled_from && dateFns.parse(scheduled_from)
      this.eventScheduledTo = scheduled_to && dateFns.parse(scheduled_to)
      this.eventShareLink = share_link
      this.eventInsertedAt = inserted_at && dateFns.parse(inserted_at)
      this.eventModifiedAt = updated_at && dateFns.parse(updated_at)
      this.eventOrganizerMessage = organizer_message;
      (preferences || {
        weekdays: []
      }).weekdays.forEach(weekday => {
        let el = this.eventWeekdays.find(({
          day
        }) => day == weekday.day)
        if (el) {
          el.value = weekday.rank >= 0
        }
      })
    },
    initialWeekdays() {
      return Object.keys(this.$i18n.t('week_days')).map((code, index) => ({
        day: index,
        name: `week_days.${code}`,
        value: true
      }));
    }
  },
  computed: {
    eventData() {
      return {
        eventName: this.eventName,
        eventOrganizer: this.eventOrganizer,
        eventOrganizerEmail: this.eventOrganizerEmail,
        eventDesc: this.eventDesc,
        eventPossibleDates: this.eventPossibleDates,
        eventState: this.eventState,
        eventScheduledFrom: this.eventScheduledFrom,
        eventScheduledTo: this.eventScheduledTo,
        eventShareLink: this.eventShareLink,
        eventWeekdays: this.eventWeekdays,
        eventOrganizerMessage: this.eventOrganizerMessage,
        eventTimeWindow: this.formattedEventTimeWindow
      };
    },
    eventDataForRequest() {
      let data = {
        name: this.eventName,
        desc: this.eventDesc,
        organizer: this.eventOrganizer,
        possible_dates: this.eventPossibleDates.map(({
          date_from,
          date_to,
          rank
        }) => ({
          date_from: dateFns.format(date_from, 'YYYY-MM-DD'),
          date_to: dateFns.format(date_to, 'YYYY-MM-DD'),
          rank: rank
        })),
        email: this.eventOrganizerEmail,
        email_confirmation: this.eventOrganizerEmail_confirmation,
        organizer_message: this.eventOrganizerMessage,
        preferences: {
          weekdays: this.eventWeekdays.filter(({
              value
            }) => !value)
            .map(({
              day
            }) => ({
              day,
              rank: -1
            }))
        }
      };
      Object.keys(data).forEach((k) => data[k] == null && delete data[k]);
      return data;
    }
  }
}

export const pollDataMixin = {
  data() {
    return {
      pollParticipant: null,
      pollWeekdayRanks: this.initialWeeklyRanks(),
      pollDateRanks: []
    }
  },
  computed: {
    pollDataForRequest() {
      return {
        participant: this.pollParticipant,
        preferences: {
          weekday_ranks: this.pollWeekdayRanks
            .filter(({
              value
            }) => value) // exclude 0 ranks
            .map(({
              day,
              value: rank
            }) => ({
              day,
              rank
            }))
        },
        date_ranks: this.pollDateRanks
          .filter(({
            rank
          }) => rank)
          .map(({
            date,
            rank
          }) => ({
            date_from: dateFns.format(date, 'YYYY-MM-DD'),
            date_to: dateFns.format(date, 'YYYY-MM-DD'),
            rank: rank
          }))
      }
    }
  },
  methods: {
    initialWeeklyRanks() {
      return Object.keys(this.$i18n.t('week_days')).map((code, index) => ({
        day: index,
        name: `week_days.${code}`,
        value: 0
      }));
    },
    datesKey: (date) => `${date.getTime()}`,
    assignPollData({
        participant,
        date_ranks = [],
        preferences = {
          weekday_ranks: []
        },
      },
      eventWeekdays) {
      this.pollParticipant = participant;

      eventWeekdays.forEach(({
        day: event_day,
        value: permitted
      }) => {
        let weekDayRank = this.pollWeekdayRanks.find(({
          day
        }) => day == event_day)
        weekDayRank.disabled = !permitted
      })

      preferences.weekday_ranks.forEach((rank) => {
        let el = this.pollWeekdayRanks.find(({
          day
        }) => day == rank.day);
        if (el) {
          el.value = rank.rank;
        }
      });

      this.pollDateRanks = date_ranks.map(({
        date_from,
        date_to,
        rank
      }) => {
        date_from = dateFns.parse(date_from)
        date_to = dateFns.parse(date_to)

        return dateFns.eachDay(date_from, date_to).map(date => ({
          date,
          rank,
          key: this.datesKey(date)
        }))
      }).flat()
    }
  }
}

export const eventHelpersMixin = {
  methods: {
    weekdayEnabled(date) {
      let enabledWeekdays = this.eventWeekdays.filter(({
        value
      }) => value).map(({
        day
      }) => (day + 1) % 7) // from 0=Mon...6=Sun to dateFns's 0=Sun...6=Sat

      return enabledWeekdays.indexOf(dateFns.getDay(date)) > -1
    },
    normalizePossibleDates() {
      // first, lower the rank to 0 if a rank higher than 0 is not needed...
      this.eventPossibleDates.forEach(possibleDate => {
        if (possibleDate.rank > 0 &&
          dateFns.eachDay(possibleDate.date_from, possibleDate.date_to).every(date =>
            this.weekdayEnabled(date)
          )) {
          possibleDate.rank = 0
        }
      })

      //...then, combine adjacent intervals with the same rank
      this.eventPossibleDates = this.eventPossibleDates
        .sort(({
          date_from: date1
        }, {
          date_from: date2
        }) => dateFns.differenceInDays(date1, date2))
        .reduce((output, nextPossibleDate) => {
          if (output.length == 0) {
            output.push(nextPossibleDate)
          } else {
            let lastPossibleDate = output[output.length - 1]
            if (lastPossibleDate.rank == nextPossibleDate.rank &&
              dateFns.isEqual(lastPossibleDate.date_to, dateFns.subDays(nextPossibleDate.date_from, 1))) {
              lastPossibleDate.date_to = nextPossibleDate.date_to
            } else {
              output.push(nextPossibleDate)
            }
          }
          return output
        }, [])
    }
  },
  computed: {
    formattedEventTimeWindow() {
      let from = this.minDate
      let to = this.maxDate

      if (from && to) {
        return dateFns.format(from, this.$i18n.t('date_format'), {
            locale: this.$i18n.t('date_fns_locale')
          }) +
          " - " +
          dateFns.format(to, this.$i18n.t('date_format'), {
            locale: this.$i18n.t('date_fns_locale')
          });
      }
    },
    eventModified() {
      return this.eventInsertedAt && this.eventModifiedAt && !dateFns.isEqual(this.eventInsertedAt, this.eventModifiedAt);
    },
    eventModifiedRelative() {
      if (this.eventModified) {
        return dateFns.distanceInWordsToNow(this.eventModifiedAt, {
          locale: this.$i18n.t('date_fns_locale'),
          addSuffix: true
        });
      }
    },
    eventScheduledTime() {
      let time = this.eventScheduledFrom;

      if (time) {
        return dateFns.format(time, this.$i18n.t('time_format'), {
          locale: this.$i18n.t('date_fns_locale')
        });
      }
    },
    eventScheduledDateTime() {
      let time = this.eventScheduledFrom;

      if (time) {
        return dateFns.format(time, this.$i18n.t('datetime_format'), {
          locale: this.$i18n.t('date_fns_locale')
        });
      }
    },
    eventScheduledDateTimeRelative() {
      let time = this.eventScheduledFrom;

      if (time) {
        let distance = dateFns.distanceInWordsToNow(time, {
          locale: this.$i18n.t('date_fns_locale'),
          addSuffix: true
        });

        let trans_key = dateFns.isFuture(time) ? 'event_viewer.time_distance_future' : 'event_viewer.time_distance_past';

        return this.$i18n.t(trans_key, {
          time_distance: distance
        })
      }
    },
    eventCanceled() {
      return this.eventState == "CANCELED";
    },
    eventOpen() {
      return this.eventState == "OPEN";
    },
    eventScheduled() {
      return this.eventState == "SCHEDULED";
    },
    fromPage() {
      let date = this.minDate || new Date()
      return {
        month: dateFns.getMonth(date) + 1, // from dateFns 0=Jan...11=Dec to v-calendar 1=Jan...12=Dec
        year: dateFns.getYear(date)
      }
    },
    toPage() {
      let date = this.maxDate || new Date()
      return {
        month: dateFns.getMonth(date) + 1, // from dateFns 0=Jan...11=Dec to v-calendar 1=Jan...12=Dec
        year: dateFns.getYear(date)
      }
    },
    minDate() {
      if (this.eventScheduled) {
        return this.eventScheduledFrom
      } else if (this.eventDomain.length > 0) {
        return dateFns.min.apply(null, this.eventDomain)
      }
    },
    maxDate() {
      if (this.eventScheduled) {
        return this.eventScheduledTo
      } else if (this.eventDomain.length > 0) {
        return dateFns.max.apply(null, this.eventDomain)
      }
    },
    emptyDomain() {
      return this.eventDomain.length == 0
    },
    eventDomain() {
      return this.eventPossibleDates.map(({
            date_from,
            date_to,
            rank
          }) =>
          dateFns.eachDay(date_from, date_to).map(date => ({
            date,
            rank
          }))
        )
        .flat()
        .filter(({
          date
        }) => !dateFns.isBefore(date, dateFns.startOfToday()))
        .filter(({
            date,
            rank
          }) =>
          this.weekdayEnabled(date) || rank > 0
        )
        .map(({
          date
        }) => date)
    },
    differentMonths() {
      if (this.minDate && this.maxDate) {
        return dateFns.differenceInCalendarMonths(this.maxDate, this.minDate) > 0
      } else {
        return false
      }
    },
    eventBackgroundClass() {
      if (this.eventOpen) {
        return 'bg-light';
      } else if (this.eventScheduled) {
        return 'alert-success';
      } else {
        return 'alert-warning';
      }
    }
  }
}

export const nameListTrimmerMixin = {
  methods: {
    trimmedNameList(list, maxVisible = 5) {
      if (!(list instanceof Array)) {
        throw 'trimmedNameList should be called with an array'
      }

      if (list.length <= maxVisible) {
        return list.join(', ')
      } else {
        return this.$i18n.t('trimmed_list', {
          list: list.slice(0, maxVisible).join(', '),
          others: list.length - maxVisible
        })
      }
    }
  }
}

export const whatsAppHelpersMixin = {
  methods: {
    whatsAppMessageURL: (link) => `https://wa.me/?text=${encodeURIComponent(link)}`
  }
};

export const colorCodes = {
  green: '#28a745',
  red: '#dc3545',
  yellow: '#ffc107',
  white: '#f8f9fa',
  black: '#000000',
  info: '#17a2b8',
  blue: '#007bff'
}

export const calThemeStyles = {
  dayCellNotInMonth: {
    opacity: '0.2'
  }
}
