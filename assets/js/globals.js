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

export const formWithErrorsMixin = {
	data: () => ({
		wasServerValidated: false,
		wasLocalValidated: false
	}),
	methods: {
		localValidation() {
			self = this;
			Object.values(this.errorsMap).forEach(function(fieldMap) {
				for (let field in fieldMap) {
					let errorField = fieldMap[field].errorField;
					self[errorField] = self[field] ? null : self.$i18n.t('errors.required_field');
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
					let key_with_error = errorKeys.find(key => errors[key]);
					this[errorField] = (key_with_error ? errors[key_with_error].join(', ') : null);
					if (key_with_error && !groupShownBecauseOfErrors) {
						this.groupVisibility[group] = true;
						groupShownBecauseOfErrors = group;
					}
				}
			}
		}
	}
}

export const fetchEventMixin = {
	methods: {
		fetchEvent(eventId) {
			let self = this;
			return this.$http.get("/v1/events/" + eventId
				,{
					headers: { 'Accept-Language': this.$i18n.locale }
				}).then(function(result) {
					return result.data.data;
				}, function(result) {
					if (result.request.status == 404) {
						self.$refs.errorBar.show(self.$i18n.t('errors.not_found'));
					} else {
						self.$refs.errorBar.show(self.$i18n.t('errors.network'));
					}
			});
		}
	}
}

export const timeWindowMixin = {
	computed: {
		timeWindow() {
			let from = this.timeWindowFrom || this.eventTimeWindowFrom;
			let to = this.timeWindowTo || this.eventTimeWindowTo;
			return dateFns.format(from, 'DD/MM/YYYY', {locale: this.$i18n.t('date_fns_locale')})
			 + " - " +
			 dateFns.format(to, 'DD/MM/YYYY', {locale: this.$i18n.t('date_fns_locale')});
		}
	}
}

