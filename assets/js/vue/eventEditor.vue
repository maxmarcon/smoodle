<template lang="pug">
	form
		.form-row
			.col-4
				input(id="step" v-model="$route.query.step" class="form-control" readonly)
		div(v-if="$route.query.step == 1")
			.form-row
				.form-group.col-md-12
					label(for="eventName") Event name
					input(id="eventName" v-model="event.name" type="text" class="form-control")
					small(id="eventNameHelp" class="form-text text-muted") Enter a name for the event
			.form-row
				.form-group.col-md-6
					label(for="eventDesc") Event description
					textarea(id="eventDesc" v-model="event.desc" class="form-control")
					small(id="eventDescHelp" class="form-text text-muted") Describe the event

		div(v-else-if="$route.query.step == 2")
			.form-row
				.form-group.col-4
					label(for="eventName") Time
					input(class="form-control")

		.form-row.justify-content-between
			.col-1
				router-link.btn.btn-sm.btn-primary(
					role="button"
					:to="{ name: 'new_event', query: {step: ($route.query.step < 2 ? $route.query.step : parseInt($route.query.step) - 1) }}"
					v-bind:class="{disabled: $route.query.step < 2}"
				)
					| Prev
			.col-1
				router-link.btn.btn-sm.btn-primary(
					role="button"
					:to="{ name: 'new_event', query: {step: parseInt($route.query.step) + 1 }}"
				)
					| Next

</template>

<script>
import Event from '../event.js'

const checkStep = (to, from, next) => {
	let step = parseInt(to.query.step);
	if (isNaN(step) || step < 1 || step > 3) {
		next({ path: to.path, query: {step: 1}});
	} else {
		next();
	}
}

export default {
	data: () => ({
		event: new Event("new event", "big party!")
	}),
	beforeRouteEnter: checkStep,
	beforeRouteUpdate: checkStep
}
</script>