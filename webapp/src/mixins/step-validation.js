function dotAccessObject(obj, deep_key) {
  if (!(obj instanceof Object)) {
    throw "dotAccessObject should be called with an object";
  }
  let retval = undefined;
  let keys = deep_key.split('.');
  keys.every(function (key) {
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

function stringifyServerError(error) {
  if (error instanceof Array) {
    return error.map(stringifyServerError).join(', ');
  } else if (error instanceof Object) {
    return stringifyServerError(Object.values(error));
  }
  return error;
}

export default {
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
      Object.values(this.errorsMap).filter(group => group.step === this.step).map(group => group.fields).forEach((fieldMap) => {
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
              this[field] === this[confirmation_field] ? null : this.$i18n.t('errors.confirmation_required', {
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
      return Object.values(this.errorsMap).filter(group => group.step === step).find(this.groupHasErrors)
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
      if (stepsWithErrors.length === 0) {
        return 0
      } else {
        return Math.min(...stepsWithErrors)
      }
    }
  }
}