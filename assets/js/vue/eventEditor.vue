<template lang="pug">
	transition(name="slide" mode="out-in")
		form(:key="$route.query.step")
			.form-row
				.col-4
					input(id="step" v-model="$route.query.step" class="form-control" readonly)
			div(v-if="$route.query.step == 1")
				.form-row
					.form-group.col-md-12
						label(for="eventName") {{ $t('event_name') }}
						input(id="eventName" v-model="event.name" type="text" class="form-control")
						small(id="eventNameHelp" class="form-text text-muted") {{ $t('event_name_help') }}
					.form-group.col-md-6
						label(for="eventDesc") {{ $t('event_desc') }}
						textarea(id="eventDesc" v-model="event.desc" class="form-control")
						small(id="eventDescHelp" class="form-text text-muted") {{ $t('event_desc_help') }}

			div(v-else-if="$route.query.step == 2")
				.form-row
					.form-group.col-4
						label(for="eventName") Time
						input(class="form-control")

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
	beforeRouteUpdate: sanitizeParameters,
}
</script>

