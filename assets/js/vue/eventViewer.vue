<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		.card(v-if="eventName")
			.card-header
				event-header(
					:name="eventName"
					:organizer="eventOrganizer"
					:timeWindowFrom="eventTimeWindowFrom"
					:timeWindowTo="eventTimeWindowTo"
				)
			.card-body
				p {{ eventDesc }}
			.card-footer
				.row.justify-content-center
					.col-auto.mt-1
						button.btn.btn-success(@click="newPoll") {{ $t('event_viewer.create_poll') }}
					.col-auto.mt-1
						button.btn.btn-primary {{ $t('event_viewer.update_poll') }}

</template>
<script>
import { fetchEventMixin } from '../globals'

export default {
	mixins: [fetchEventMixin],
	props: {
		eventId: {
			type: String,
			required: true
		},
	},
	data: () => ({
		eventName: null,
		eventOrganizer: null,
		evendDesc: null,
		eventTimeWindowFrom: null,
		eventTimeWindowTo: null,
	}),
	created() {
		let self = this;
		this.fetchEvent(this.eventId).then(function(eventData) {
			if (eventData) {
				self.eventName = eventData.name;
				self.eventOrganizer = eventData.organizer;
				self.eventDesc = eventData.desc;
				self.eventTimeWindowFrom = eventData.time_window_from;
				self.eventTimeWindowTo = eventData.time_window_to;
				//self.$refs.welcomeModal.show();
			}
		});
	},
	methods: {
		newPoll() {
			this.$router.push({name: 'poll', params: {eventId: this.eventId}});
		}
	}
}
</script>