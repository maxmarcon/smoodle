export default class Event {

	constructor(name, desc) {
		this._name = name;
		this._desc = desc;
		this._time_window_from = new Date();
		this._time_window_to = new Date();
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

	get time_window_from() {
		return this._time_window_from;
	}

	get time_window_to() {
		return this._time_window_to;
	}

	set time_window_from(from) {
		this._time_window_from = from;
	}

	set time_window_to(to) {
		this._time_window_to = to;
	}
}