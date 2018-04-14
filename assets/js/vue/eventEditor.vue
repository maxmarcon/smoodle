<template lang="pug">
	transition(name="slide" mode="out-in")
		form(:key="$route.query.step" @submit.prevent="")
			div {{ event }}
			div(v-if="$route.query.step == 1")
				.form-group.row.mt-md-3
					label.col-md-2.col-form-label(for="eventName") {{ $t('event_name') }}
					.col-md-6
						input#eventName.form-control(v-model="event.name" type="text")
						small.form-text.text-muted(id="eventNameHelp") {{ $t('event_name_help') }}
				.form-group.row
					label.col-md-2.col-form-label(for="eventDesc") {{ $t('event_desc') }}
					.col-md-6
						textarea#eventDesc.form-control(v-model="event.desc")
						small.form-text.text-muted(id="eventDescHelp") {{ $t('event_desc_help') }}

			div(v-else-if="$route.query.step == 2")
				.form-group.row.mt-md-3.date-picker-trigger
					label.col-md-2.col-form-label(for="eventDates") {{ $t('dates') }}
					.col-md-6
						input#eventDates.form-control(:value="event.time_window_from + ' - ' + event.time_window_to")

					AirbnbStyleDatepicker(
						:trigger-element-id="'eventDates'"
							:mode="'range'"
							:fullscreen-mobile="true"
							:date-one="event.time_window_from"
							:date-two="event.time_window_to"
							@date-one-selected="val => { event.time_window_from = val }"
							@date-two-selected="val => { event.time_window_to = val }"
					)

			.form-row.justify-content-between
				.col-1
					router-link.btn.btn-sm.btn-primary(
						role="button"
						:to="{ name: 'new_event', query: {step: ($route.query.step == minStep ? $route.query.step : parseInt($route.query.step) - 1) }}"
						v-bind:class="{disabled: $route.query.step == minStep}"
					) {{ $t('prev') }}
				.col-1
					router-link.btn.btn-sm.btn-primary(
						role="button"
						:to="{ name: 'new_event', query: {step: parseInt($route.query.step) + 1 }}"
					) {{ $t('next') }}

</template>

<script>
import Event from '../event.js'

const minStep = 1;
const maxStep = 3;

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
		event: new Event(),
		minStep,
		maxStep
 	}),
	beforeRouteEnter: sanitizeParameters,
	beforeRouteUpdate: sanitizeParameters
}
</script>

