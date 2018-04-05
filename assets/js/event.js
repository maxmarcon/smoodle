export default class Event {

	constructor(name, desc) {
		this._name = name;
		this._desc = desc;
	}

	get name() {
		return this._name;
	}

	get desc() {
		return this._desc;
	}

	set name(name) {
		this._name = name;
	}

	set desc(desc) {
		this._desc = desc;
	}
}