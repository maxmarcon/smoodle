import dateFns from 'date-fns'

export function dotAccessObject(obj, deep_key) {
	if (!obj instanceof Object) {
		throw "dotAccessObject should be called with an object";
	}
	let retval = undefined;
	let keys = deep_key.split('.');
	keys.every(function(key) {
		if (obj.hasOwnProperty(key)) {
			obj = obj[key]
			if (!obj instanceof Object || obj instanceof Array) {
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

class LocalStorageProxy {
	constructor() {
		try {
			localStorage.setItem("test", "test");
			let result = localStorage.getItem("test");
			localStorage.removeItem("test");
			this._available = (result == "test");
		} catch (e) {
			this._available = false;
		}
	}

	get available() {
		return this._available;
	}

	getItem(key) {
		if (this.available) {
			return localStorage.getItem(key);
		} else {
			return undefined;
		}
	}

	setItem(key, value) {
		if (this.available) {
			localStorage.setItem(key, value);
		}
	}
}

export const localStorageProxy = new LocalStorageProxy();

export function showToolTip(name) {
	if (localStorageProxy.available) {
		let status = localStorageProxy.getItem(name);
		if (status) {
			return false;
		} else {
			localStorageProxy.setItem(name, "shown");
			return true;
		}
	} else {
		return false;
	}
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

					if (fieldMapObj.required) {
						self[errorField] = (self[field] ? null : self.$i18n.t('errors.required_field'));
					}
					if (fieldMapObj.confirmation) {
						let confirmation_field = field + "_confirmation";
						let confirmation_error_field = errorField + "_confirmation";
						self[confirmation_error_field] = (
							self[field] == self[confirmation_field] ? null : self.$i18n.t('errors.confirmation_required', {field: field})
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
		setServerErrors(errors={}) {
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
				ignoreErrorCodes: []
			}, config);

			let scrollToTop = false;
			let self = this;
			self.requestOngoing = true;
			return this.$http.request(
				config
			).catch(function(error) {
				if (config.showErrors) {
					if (error.response) {
						if (!config.ignoreErrorCodes.includes(error.response.status)) {
							if (error.response.status == 422) {
								self.$refs.errorBar.show(self.$i18n.t('errors.unprocessable_entity'));
							} else if (error.response.status == 404) {
								self.$refs.errorBar.show(self.$i18n.t('errors.not_found'));
							} else {
								self.$refs.errorBar.show(self.$i18n.t('errors.server', {code: error.response.status}));
							}
							scrollToTop = true;
						}
					} else if (error.request) {
						self.$refs.errorBar.show(self.$i18n.t('errors.network'));
						scrollToTop = true;
					} else {
						self.$refs.errorBar.show(self.$i18n.t('errors.generic', {message: error.message}));
						scrollToTop = true;
					}
					if (self.scrollToTop && scrollToTop) {
						self.scrollToTop();
					}
				}
				throw error;
			}).finally(function() {
				self.requestOngoing = false;
			});
		}
	}
}

export const eventDataMixin = {
	data: () => ({
		eventName: null,
		eventOrganizer: null,
		eventOrganizerEmail: null,
		eventOrganizerEmail_confirmation: null,
		evendDesc: null,
		eventState: null,
		eventShareLink: null,
		eventTimeWindowFrom: null,
		eventTimeWindowTo: null,
		eventScheduledFrom: null,
		eventScheduledTo: null
	}),
	methods: {
		assignEventData(eventData) {
			this.eventName = eventData.name;
			this.eventOrganizer = eventData.organizer;
			this.eventOrganizerEmail = eventData.email;
			this.eventDesc = eventData.desc;
			this.eventTimeWindowFrom = dateFns.parse(eventData.time_window_from);
			this.eventTimeWindowTo = dateFns.parse(eventData.time_window_to);
			this.eventState = eventData.state;
			this.eventScheduledFrom = dateFns.parse(eventData.scheduled_from);
			this.eventScheduledTo = dateFns.parse(eventData.scheduled_to);
			this.eventShareLink = eventData.share_link;
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
				eventShareLink: this.eventShareLink
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
				email_confirmation: this.eventOrganizerEmail_confirmation
			};
			Object.keys(data).forEach((k) => data[k] == null && delete data[k]);
			return data;
		}
	}
}

export const eventHelpersMixin = {
	computed: {
		eventTimeWindow() {
			let from = this.eventTimeWindowFrom;
			let to = this.eventTimeWindowTo;

			if (from && to) {
				return dateFns.format(from, this.$i18n.t('date_format'), {locale: this.$i18n.t('date_fns_locale')})
				 + " - " +
				 dateFns.format(to, this.$i18n.t('date_format'), {locale: this.$i18n.t('date_fns_locale')});
			}
		},
		eventScheduledDateTime() {
			let time = this.eventScheduledFrom;

			if (time) {
				return dateFns.format(time, this.$i18n.t('datetime_format'), {locale: this.$i18n.t('date_fns_locale')});
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
		eventScheduledTime() {
			return dateFns.format(this.eventScheduledFrom, this.$i18n.t('time_format'), {locale: this.$i18n.t('date_fns_locale')});
		},
		minDate() {
			return dateFns.max(dateFns.parse(this.eventTimeWindowFrom), dateFns.startOfTomorrow());
		},
		maxDate() {
			return dateFns.parse(this.eventTimeWindowTo);
		},
		differentMonths() {
			return dateFns.differenceInCalendarMonths(this.maxDate, this.minDate) > 0;
		},
		eventBackgroundClass() {
			if (this.eventOpen) {
				return 'bg-light';
			} else if (this.eventScheduled) {
				return 'bg-success';
			} else {
				return 'bg-warning';
			}
		}
	}
}

export const colorCodes = {
	green: '#28a745',
	red: '#dc3545',
	yellow: '#ffc107',
	white: '#f8f9fa',
	black: '#000000',
	info: '#17a2b8'
}
