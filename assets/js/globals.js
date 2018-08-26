import dateFns from 'date-fns'

export const sanitizeStepRouteParameter = (to, firstStep, lastStep, forceFirstStep=false, stepParameter="step") => {
	let query = to.query;
	let step = parseInt(to.query[stepParameter]);

	if (isNaN(step) || step < firstStep || step > lastStep || (forceFirstStep && step != firstStep)) {
		query[stepParameter] = firstStep;
		return { path: to.path, query };
	} else {
		return true;
	}
}

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
		localValidation() {
			self = this;
			Object.values(this.errorsMap).forEach(function(fieldMap) {
				for (let field in fieldMap) {
					let fieldMapObj = fieldMap[field];
					let errorField = fieldMapObj.errorField;
					if (fieldMapObj.required) {
						self[errorField] = self[field] ? null : self.$i18n.t('errors.required_field');
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
			let groupShownBecauseOfErrors = null;
			for (let group in this.errorsMap) {
				let fieldMap = this.errorsMap[group];
				for (let field in fieldMap) {
					let errorKeys = fieldMap[field].errorKeys;
					let errorField = fieldMap[field].errorField;
					errorKeys = errorKeys instanceof Array ? errorKeys : [errorKeys];
					let key_with_error = errorKeys.find(key => dotAccessObject(errors, key));
					this[errorField] = (key_with_error ? stringifyServerError(dotAccessObject(errors, key_with_error)) : null);
					if (key_with_error && !groupShownBecauseOfErrors) {
						this.groupVisibility[group] = true;
						groupShownBecauseOfErrors = group;
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
				return this.$scrollTo('#app');
			}
		}
	}
}

export const restMixin = {
	data() {
		return {
			requestOngoing: false,
			apiVersion: 'v1'
		};
	},
	methods: {
		restRequest(path, config, scrollToTop = true) {
			let self = this;
			self.requestOngoing = true;
			return this.$http.request(
				Object.assign({
					url: [null, this.apiVersion, path].join('/'),
					headers: {
						'Accept-Language': this.$i18n.locale
					}
				}, config)
			).catch(function(error) {
				if (error.response) {
					if (error.response.status == 404) {
						self.$refs.errorBar.show(self.$i18n.t('errors.not_found'));
					} else if (error.response.status != 422) {
						self.$refs.errorBar.show(self.$i18n.t('errors.server'));
					}
				} else if (error.request) {
					self.$refs.errorBar.show(self.$i18n.t('errors.network'));
				} else {
					console.log(error);
					scrollToTop = false;
				}
				if (self.$scrollTo && scrollToTop) {
					self.$scrollTo('#app');
				}
				throw error;
			}).finally(function() {
				self.requestOngoing = false;
			});
		}
	}
}

export const timeWindowMixin = {
	computed: {
		timeWindow() {
			let from = this.timeWindowFrom || this.eventTimeWindowFrom;
			let to = this.timeWindowTo || this.eventTimeWindowTo;
			if (from && to) {
				return dateFns.format(from, this.$i18n.t('date_format'), {locale: this.$i18n.t('date_fns_locale')})
				 + " - " +
				 dateFns.format(to, this.$i18n.t('date_format'), {locale: this.$i18n.t('date_fns_locale')});
			}
		}
	}
}

export const eventHelpersMixin = {
	computed: {
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
			return dateFns.max(dateFns.parse(this.eventTimeWindowFrom), new Date());
		},
		maxDate() {
			return dateFns.parse(this.eventTimeWindowTo);
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
