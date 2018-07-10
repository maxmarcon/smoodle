<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal#updateAnswerModal(
			:title="$t('event_viewer.update.title')"
			:ok-title="$t('event_viewer.update.load')"
			@ok="loadAnswer"
		)
			.container-fluid
				p.form-text {{ $t('event_viewer.update.how_to') }}
				.form-group
					input#pollParticipant.form-control(
						v-model.trim="pollParticipant"
						:class="{'is-invalid': pollParticipantError}"
						:placeholder="$t('event_viewer.update.name_placeholder')"
					)
					.invalid-feedback {{ pollParticipantError }}

		.card(v-if="eventName")
			.card-header
				event-header(
					:name="eventName"
					:organizer="eventOrganizer"
					:timeWindowFrom="eventTimeWindowFrom"
					:timeWindowTo="eventTimeWindowTo"
				)
			ul.list-group.list-group-flush
				li.list-group-item
					p {{ eventDesc }}
				li.list-group-item
					p.text-muted {{ $t('event_viewer.welcome', {organizer: eventOrganizer, timeWindow}) }}
				li.list-group-item
					div(v-if="bestDates")
					div.alert.alert-primary(v-else) {{ $t('event_viewer.no_participants') }}
			.card-footer
				.row.justify-content-center
					.col-auto.mt-1
						router-link.btn.btn-success(
							role="button"
							:to="{ name: 'poll', params: {eventId: eventId}}"
						) {{ $t('event_viewer.create_poll') }}
					.col-auto.mt-1
						button.btn.btn-primary(v-b-modal.updateAnswerModal="") {{ $t('event_viewer.update_poll') }}

</template>
<script>
import { fetchEventMixin, timeWindowMixin } from '../globals'

export default {
	mixins: [fetchEventMixin, timeWindowMixin],
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
		bestDates: null,
		pollParticipant: null,
		pollParticipantError: null
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
			}
		});
	},
	methods: {
		loadAnswer(bvEvt) {
			// TEST
			this.pollParticipantError = "Not found";
			bvEvt.preventDefault();
		}
	}
}
</script>