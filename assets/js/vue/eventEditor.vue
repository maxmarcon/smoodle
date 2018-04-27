<template lang="pug">
	transition(name="slide" mode="out-in")
		form(:key="$route.query.step" @submit.prevent="")
			div(v-if="$route.query.step == 1")
				.form-group.row.mt-md-3
					label.col-md-2.col-form-label(for="eventName") {{ $t('event_editor.event.name') }}
					.col-md-6
						input#eventName.form-control(v-model="eventName" type="text")
						small.form-text.text-muted(id="eventNameHelp") {{ $t('event_editor.event.name_help') }}
				.form-group.row
					label.col-md-2.col-form-label(for="eventDesc") {{ $t('event_editor.event.desc') }}
					.col-md-6
						textarea#eventDesc.form-control(v-model="eventDesc")
						small.form-text.text-muted(id="eventDescHelp") {{ $t('event_editor.event.desc_help') }}

			div(v-else-if="$route.query.step == 2")
				.form-group.row.mt-md-3.date-picker-trigger
					label.col-md-2.col-form-label(for="eventDates") {{ $t('event_editor.event.dates') }}
					.col-md-4
						input#eventDates.form-control(
						:value="dateRange"
						)

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

			.row
				.col
					router-link.btn.btn-primary(
						role="button"
						:to="{ name: 'new_event', query: {step: ($route.query.step == minStep ? $route.query.step : parseInt($route.query.step) - 1) }}"
						:class="{disabled: $route.query.step == minStep}"
					) {{ $t('event_editor.prev') }}
				.col
					router-link.btn.btn-primary(
						role="button"
						:to="{ name: 'new_event', query: {step: parseInt($route.query.step) + 1 }}"
					) {{ $t('event_editor.next') }}

</template>

<script>

import dateFns from 'date-fns'

const minStep = 1;
const maxStep = 3;
const today = new Date();
const InvalidDate = 'Invalid Date';

const sanitizeParameters = (to, from, next) => {
	let step = parseInt(to.query.step);
	if (isNaN(step) || step < minStep || step > maxStep) {
		next({ path: to.path, query: {step: minStep}});
	} else {
		next();
	}
}

export default {
	data: () => ({
		eventName: '',
		eventDesc: '',
		dateFrom: '',
		dateTo: '',
		minStep,
		maxStep,
		showThisWeekButton: (dateFns.getDay(today) > 0 && dateFns.getDay(today) < 4) // betewn Mon and Wed
 	}),
	beforeRouteEnter: sanitizeParameters,
	beforeRouteUpdate: sanitizeParameters,
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
		applyDates(from, to) {
			this.dateFrom = from;//DateFns.format(from, 'YYYY-MM-DD');
			this.dateTo = to;//DateFns.format(to, 'YYYY-MM-DD');
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

