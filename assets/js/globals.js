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
