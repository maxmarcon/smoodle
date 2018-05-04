<template lang="pug">
	transition(name="slide" mode="out-in")
		form(:key="$route.query.step" @submit.prevent="" novalidate=true)
			div(v-if="$route.query.step == 1")
				.form-group.row.mt-md-3
					label.col-md-2.col-form-label(for="eventName") {{ $t('event_editor.event.name') }}
					.col-md-6
						small.form-text.text-muted(id="eventNameHelp") {{ $t('event_editor.event.name_help') }}
						input#eventName.form-control(v-model="eventName" type="text"
						:class="{'is-invalid': eventNameError}")
						.invalid-feedback {{ eventNameError }}
				.form-group.row
					label.col-md-2.col-form-label(for="eventDesc") {{ $t('event_editor.event.desc') }}
					.col-md-6
						small.form-text.text-muted(id="eventDescHelp") {{ $t('event_editor.event.desc_help') }}
						textarea#eventDesc.form-control(v-model="eventDesc"
						:class="{'is-invalid': eventDescError}")
						.invalid-feedback {{ eventDescError }}

			div(v-else-if="$route.query.step == 2")
				.form-group.row.mt-md-3.date-picker-trigger
					label.col-md-2.col-form-label(for="eventDates") {{ $t('event_editor.event.dates') }}
					.col-md-4
						input#eventDates.form-control(
						:value="dateRange"
						:class="{'is-invalid': eventDatesError}"
						)
						.invalid-feedback {{ eventDatesError }}

					AirbnbStyleDatepicker(
						:trigger-element-id="'eventDates'"
							:mode="'range'"
							:fullscreen-mobile="true"
							:date-one="dateFrom"
							:date-two="dateTo"
							@date-one-selected="val => { dateFrom = val }"
							@date-two-selected="val => { dateTo = val }"
					)

				.form-group.row
					.col-md-2.offset-md-2
						b-dropdown(:text="$t('event_editor.dates_quick_selection')")
							b-dropdown-item(v-if="showThisWeekButton" @click="pickThisWeek") {{ $t('event_editor.this_week') }}
							b-dropdown-item(@click="pickNextWeek") {{ $t('event_editor.next_week') }}
							b-dropdown-item(@click="pickNextMonths(1)") {{ $tc('event_editor.within_months', 1) }}

			.row(v-if="$route.query.step < 3")
				.col
					router-link.btn.btn-primary(
						role="button"
						:to="{ name: 'new_event', query: {step: ($route.query.step == firstStep ? $route.query.step : parseInt($route.query.step) - 1) }}"
						:class="{disabled: $route.query.step == firstStep}"
					) {{ $t('event_editor.prev') }}
				.col
					router-link.btn.btn-primary(
						role="button"
						:to="{ name: 'new_event', query: {step: parseInt($route.query.step) + 1 }}"
					) {{ $t('event_editor.next') }}

</template>

<script>
import dateFns from 'date-fns'

const firstStep = 1;
const lastStep = 3;
const today = new Date();
const InvalidDate = 'Invalid Date';

const sanitizeParameters = (to, forceFirstStep=false) => {
	let step = parseInt(to.query.step);
	if (isNaN(step) || step < firstStep || step > lastStep || (forceFirstStep && step != firstStep)) {
		return { path: to.path, query: {step: firstStep} };
	} else {
		return true;
	}
}

function beforeRouteUpdate(to, from, next) {
	let res = sanitizeParameters(to);
	if (res != true) {
		next(res);
	} else {
		if (from.query.step > to.query.step) {
			next();
		} else {
		 	let self = this;
			this.$http.post("/v1/events", {
				dry_run: true,
				event: self.dataForStep(from.query.step)
			})
			.then(function(result) {
				self.setErrorsForStep({}, from.query.step);
				next();
			})
			.catch(function(result) {
				self.setErrorsForStep(result.response.data.errors, from.query.step);
				next(false);
			});
		}
	}
}

const errorsMap = {
	"1": {
		name: "eventNameError",
		desc: "eventDescError"
	},
	"2": {
		time_window_from: "eventDatesError",
		time_window_to: "eventDatesError"
	}
};

export default {
	data: () => ({
		eventName: '',
		eventNameError: null,
		eventDesc: '',
		eventDescError: null,
		dateFrom: '',
		dateTo: '',
		eventDatesError: null,
		firstStep,
		lastStep,
		showThisWeekButton: (dateFns.getDay(today) > 0 && dateFns.getDay(today) < 4) // betewn Mon and Wed
 	}),
	beforeRouteEnter: (to, from, next) => {
		next(sanitizeParameters(to, true));
	},
	beforeRouteUpdate,
	computed: {
		dateRange() {
			let fromDate_s = dateFns.format(this.dateFrom, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')});
			let toDate_s = dateFns.format(this.dateTo, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')});

			if (fromDate_s == InvalidDate || toDate_s == InvalidDate) {
				return '';
			} else {
				return fromDate_s + ' - ' + toDate_s;
			}
		}
	},
	methods: {
		dataForStep(step) {
			let data = {};
			if (step >= "1") {
				Object.assign(data, {
					name: this.eventName,
					desc: this.eventDesc
				});
			}
			if (step >= "2") {
				Object.assign(data, {
					time_window_from: this.dateFrom,
					time_window_to: this.dateTo
				});
			}
			return data;
		},
		setErrorsForStep(errors, step) {
			let map = errorsMap[step];
			if (map) {
				for (let k in map) {
					this[map[k]] = (k in errors ? errors[k][0] : null)
				}
			}
		},
		applyDates(from, to) {
			this.dateFrom = from;
			this.dateTo = to;
		},
		pickThisWeek() {
			let today = new Date();
			this.applyDates(
				dateFns.startOfWeek(today, {weekStartsOn: 1}),
				dateFns.endOfWeek(today, {weekStartsOn: 1})
			);
		},
		pickNextWeek() {
			let today_next_week = dateFns.addWeeks(new Date(), 1);
			this.applyDates(
				dateFns.startOfWeek(today_next_week, {weekStartsOn: 1}),
				dateFns.endOfWeek(today_next_week, {weekStartsOn: 1})
			);
		},
		pickNextMonths(months) {
			let today = new Date();
			this.applyDates(today, dateFns.addMonths(today,1));
		}
	}
}
</script>

