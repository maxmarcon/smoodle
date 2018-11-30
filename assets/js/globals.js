import dateFns from 'date-fns'

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

export const accordionGroupsMixin = {
	// TODO: add a 'required' boolean attribute to the field
	// to specify that the field is required (if false, skip local validation for that field)
	data: () => ({
		wasServerValidated: false,
		wasLocalValidated: false
	}),
	methods: {
		clearErrorFields() {
			let self = this;
			Object.values(this.errorsMap).forEach(function(fieldMap) {
				for (let field in fieldMap) {
					let fieldMapObj = fieldMap[field];
					self[fieldMapObj.errorField] = null;
				}
			});
		},
		localValidation() {
			let self = this;
			this.clearErrorFields();
			Object.values(this.errorsMap).forEach(function(fieldMap) {
				for (let field in fieldMap) {
					let fieldMapObj = fieldMap[field];
					let errorField = fieldMapObj.errorField;
					if (self[errorField]) {
						// was already set, don't overwrite
						return;
					}

					let errorMsgs = []
					if (fieldMapObj.required && !self[field]) {
						errorMsgs.push(self.$i18n.t('errors.required_field'))
					}
					if (fieldMapObj.customValidation) {
						let msg = self.customValidate(field, self[field])
						if (msg) {
							errorMsgs.push(msg)
						}
					}
					if (errorMsgs.length) {
						self[errorField] = errorMsgs.join(', ')
					}

					if (fieldMapObj.confirmation) {
						let confirmation_field = `${field}_confirmation`;
						let confirmation_error_field = `${errorField}_confirmation`;
						self[confirmation_error_field] = (
							self[field] == self[confirmation_field] ? null : self.$i18n.t('errors.confirmation_required', {
								field: field
							})
						);
					}
				}
			});
			this.wasLocalValidated = true;
		},
		collapseAllGroups() {
			for (let group in this.groupVisibility) {
				this.groupVisibility[group] = false;
			}
		},
		showGroupOkIcon(group) {
			return this.wasServerValidated && !this.groupHasErrors(group);
		},
		showGroupErrorIcon(group) {
			return this.wasServerValidated && this.groupHasErrors(group);
		},
		groupVariant(group) {
			if (this.wasServerValidated) {
				return (this.groupHasErrors(group) ? 'danger' : 'success');
			}
		},
		groupHasErrors(group) {
			let groupErrorsMap = this.errorsMap[group] || {}
			for (let field in groupErrorsMap) {
				if (this[groupErrorsMap[field].errorField]) {
					return true;
				}
			}
			return false;
		},
		inputFieldClass(field) {
			let fieldMap = Object.values(this.errorsMap).find(map => map[field]);
			if (fieldMap) {
				let errorField = fieldMap[field].errorField;
				if (this[errorField]) {
					return 'is-invalid';
				} else if (this.wasServerValidated || this.wasLocalValidated) {
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

			let groupShownBecauseOfErrors = null;
			for (let group in this.errorsMap) {
				if (group == 'general') {
					setErrorField.call(this, this.errorsMap[group], errors);
				} else {
					let fieldMap = this.errorsMap[group];
					for (let field in fieldMap) {
						if (setErrorField.call(this, fieldMap[field], errors) && !groupShownBecauseOfErrors) {
							this.groupVisibility[group] = true;
							groupShownBecauseOfErrors = group;
						}
					}
				}
			}
			return groupShownBecauseOfErrors;
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
	data: () => ({
		requestOngoing: false,
		apiVersion: 'v1'
	}),
	methods: {
		restRequest(path, config) {
			config = Object.assign({
				url: [null, this.apiVersion, path].join('/'),
				headers: {
					'Accept-Language': this.$i18n.locale
				},
				showErrors: true,
				ignoreErrorCodes: [],
				errorCodeMessages: {
					422: this.$i18n.t('errors.unprocessable_entity'),
					404: this.$i18n.t('errors.not_found')
				},
				spinnerDelay: 100
			}, config);

			let self = this;

			let scrollToTop = false;
			let loader = null;
			let timeout = setTimeout(function() {
				loader = self.$loading.show();
			}, config.spinnerDelay);

			this.requestOngoing = true;

			return this.$http.request(
				config
			).catch(function(error) {
				if (config.showErrors) {
					if (error.response) {
						if (!config.ignoreErrorCodes.includes(error.response.status)) {
							let message = config.errorCodeMessages[error.response.status] || self.$i18n.t('errors.server', {
								code: error.response.status
							});
							self.$refs.errorBar.show(message);
							scrollToTop = true;
						}
					} else if (error.request) {
						self.$refs.errorBar.show(self.$i18n.t('errors.network'));
						scrollToTop = true;
					} else {
						self.$refs.errorBar.show(self.$i18n.t('errors.generic', {
							message: error.message
						}));
						scrollToTop = true;
					}
					if (self.scrollToTop && scrollToTop) {
						self.scrollToTop();
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
			eventTimeWindowFrom: null,
			eventTimeWindowTo: null,
			eventScheduledFrom: null,
			eventScheduledTo: null,
			eventInsertedAt: null,
			eventModifiedAt: null,
			eventWeekdays: null,
			eventWeekdays: this.initialWeekdays()
		}
	},
	methods: {
		assignEventData({
			name,
			organizer,
			email,
			desc,
			time_window_from,
			time_window_to,
			state,
			scheduled_from,
			scheduled_to,
			share_link,
			inserted_at,
			updated_at,
			preferences
		}) {
			this.eventName = name;
			this.eventOrganizer = organizer;
			this.eventOrganizerEmail = email;
			this.eventDesc = desc;
			this.eventTimeWindowFrom = time_window_from && dateFns.parse(time_window_from);
			this.eventTimeWindowTo = time_window_to && dateFns.parse(time_window_to);
			this.eventState = state;
			this.eventScheduledFrom = scheduled_from && dateFns.parse(scheduled_from);
			this.eventScheduledTo = scheduled_to && dateFns.parse(scheduled_to);
			this.eventShareLink = share_link;
			this.eventInsertedAt = inserted_at && dateFns.parse(inserted_at);
			this.eventModifiedAt = updated_at && dateFns.parse(updated_at);
			(preferences || {
				weekdays: []
			}).weekdays.forEach(weekday => {
				let el = this.eventWeekdays.find(({
					day
				}) => day == weekday.day)
				if (el) {
					el.value = weekday.permitted;
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
				eventTimeWindowFrom: this.eventTimeWindowFrom,
				eventTimeWindowTo: this.eventTimeWindowTo,
				eventState: this.eventState,
				eventScheduledFrom: this.eventScheduledFrom,
				eventScheduledTo: this.eventScheduledTo,
				eventShareLink: this.eventShareLink,
				eventWeekdays: this.eventWeekdays
			};
		},
		eventDataForRequest() {
			let data = {
				name: this.eventName,
				desc: this.eventDesc,
				organizer: this.eventOrganizer,
				time_window_from: this.eventTimeWindowFrom && dateFns.format(this.eventTimeWindowFrom, 'YYYY-MM-DD'),
				time_window_to: this.eventTimeWindowTo && dateFns.format(this.eventTimeWindowTo, 'YYYY-MM-DD'),
				email: this.eventOrganizerEmail,
				email_confirmation: this.eventOrganizerEmail_confirmation,
				preferences: {
					weekdays: (this.eventWeekdays.every((weekday) => weekday.value) ? [] :
						this.eventWeekdays.map(({
							value: permitted,
							day
						}) => ({
							permitted,
							day
						}))
					)
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
				.filter(({rank}) => rank)
				.map(({date, rank}) => ({
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

			this.pollDateRanks = date_ranks.flatMap(({
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
			})
		}
	}
}

export const eventHelpersMixin = {
	computed: {
		eventTimeWindow() {
			let from = this.eventTimeWindowFrom;
			let to = this.eventTimeWindowTo;

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
		minDate() {
			return dateFns.max(this.eventTimeWindowFrom, dateFns.startOfTomorrow())
		},
		maxDate() {
			return dateFns.max(this.eventTimeWindowTo)
		},
		dateDomain() {
			return dateFns.isAfter(this.minDate, this.maxDate) ? [] : dateFns.eachDay(this.minDate, this.maxDate)
		},
		differentMonths() {
			return dateFns.differenceInCalendarMonths(this.maxDate, this.minDate) > 0;
		},
		disabledDates() {
			return [{
				start: this.minDate,
				end: this.maxDate,
				weekdays: this.eventWeekdays.filter(({
					value
				}) => !value).map(({
					day
				}) => ((day + 1) % 7) + 1) // from 0=Mon...6=Sun to v-calendar's 1=Sun... 7=Sat
			}, {
				start: null,
				end: dateFns.subDays(this.minDate, 1),
			}, {
				start: dateFns.addDays(this.maxDate, 1),
				end: null
			}]
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
				return this.$i18n.t('trimmed_list', {list: list.slice(0, maxVisible).join(', '), others: list.length - maxVisible})
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
	info: '#17a2b8'
}