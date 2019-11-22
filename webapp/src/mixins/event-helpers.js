import * as dateFns from "date-fns";

export default {
  methods: {
    weekdayEnabled(date) {
      const enabledWeekdays = this.eventWeekdays.filter(({
                                                         value
                                                       }) => value).map(({
                                                                           day
                                                                         }) => (day + 1) % 7) // from 0=Mon...6=Sun to dateFns's 0=Sun...6=Sat

      return enabledWeekdays.indexOf(dateFns.getDay(date)) > -1
    },
    isInDomain(date) {
      return this.eventDomain.find(d => dateFns.isEqual(d, date))
    },
    normalizePossibleDates() {
      // first, lower the rank to 0 if a rank higher than 0 is not needed...
      this.eventPossibleDates.forEach(possibleDate => {
        if (possibleDate.rank > 0 &&
          dateFns.eachDayOfInterval({start: possibleDate.date_from, end: possibleDate.date_to}).every(date =>
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
          if (output.length === 0) {
            output.push(nextPossibleDate)
          } else {
            let lastPossibleDate = output[output.length - 1]
            if (lastPossibleDate.rank === nextPossibleDate.rank &&
              dateFns.isEqual(lastPossibleDate.date_to, dateFns.subDays(nextPossibleDate.date_from, 1))) {
              lastPossibleDate.date_to = nextPossibleDate.date_to
            } else {
              output.push(nextPossibleDate);
            }
          }
          return output
        }, [])
    },
    textForDate(date_entry, isOrganizer, trim = false) {
      if (date_entry.negative_rank < 0) {
        return this.negativeParticipantsText(date_entry, isOrganizer, trim);
      } else {
        return this.positiveParticipantsText(date_entry, isOrganizer, trim);
      }
    },
    negativeParticipantsText(date_entry, isOrganizer, trim = false) {
      if (isOrganizer) {
        return this.$i18n.tc('event_viewer.negative_participants_list_date',
            date_entry.negative_participants.length,
            {participants: trim ? this.trimmedNameList(date_entry.negative_participants) : date_entry.negative_participants.join(', ')});
      } else {
        return this.$i18n.tc('event_viewer.negative_participants_for_date', -date_entry.negative_rank);
      }
    },
    positiveParticipantsText(date_entry, isOrganizer, trim = false) {
      if (isOrganizer && date_entry.positive_rank > 0) {
        return this.$i18n.tc('event_viewer.positive_participants_list_date', date_entry.positive_participants.length,
            {participants: trim
                  ? this.trimmedNameList(date_entry.positive_participants) : date_entry.positive_participants.join(', ')});
      } else {
        return this.$i18n.tc('event_viewer.positive_participants_for_date', date_entry.positive_rank);
      }
    },
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
        return dateFns.formatDistanceToNow(this.eventModifiedAt, {
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
      const time = this.eventScheduledFrom;

      if (time) {
        return dateFns.format(time, this.$i18n.t('datetime_format'), {
          locale: this.$i18n.t('date_fns_locale')
        });
      }
    },
    eventScheduledDateTimeRelative() {
      const time = this.eventScheduledFrom;

      if (time) {
        let distance = dateFns.formatDistanceToNow(time, {
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
      return this.eventState === "CANCELED";
    },
    eventOpen() {
      return this.eventState === "OPEN";
    },
    eventScheduled() {
      return this.eventState === "SCHEDULED";
    },
    fromPage() {
      const date = this.minDate || new Date()
      return {
        month: dateFns.getMonth(date) + 1, // from dateFns 0=Jan...11=Dec to v-calendar 1=Jan...12=Dec
        year: dateFns.getYear(date)
      }
    },
    toPage() {
      const date = this.maxDate || new Date()
      return {
        month: dateFns.getMonth(date) + 1, // from dateFns 0=Jan...11=Dec to v-calendar 1=Jan...12=Dec
        year: dateFns.getYear(date)
      }
    },
    minDate() {
      if (this.eventScheduled) {
        return this.eventScheduledFrom
      } else if (this.eventDomain.length > 0) {
        return dateFns.min(this.eventDomain)
      }
    },
    maxDate() {
      if (this.eventScheduled) {
        return this.eventScheduledTo
      } else if (this.eventDomain.length > 0) {
        return dateFns.max(this.eventDomain)
      }
    },
    emptyDomain() {
      return this.eventDomain.length === 0
    },
    eventDomain() {
      return this.eventPossibleDates.map(({
                                            date_from,
                                            date_to,
                                            rank
                                          }) =>
        dateFns.eachDayOfInterval({start: date_from, end: date_to}).map(date => ({
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
