<template lang="pug">
	form
		.form-row
			.col-4
				input(id="event_id" v-model="id" class="form-control" readonly)
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
</template>

<script>
import Event from '../event.js'

export default {
	props: ['id'],
	data: () => ({
		event: new Event("new event", "big party!")
	})
}
</script>