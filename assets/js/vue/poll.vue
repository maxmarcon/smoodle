<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal(ref="welcomeModal" hide-header ok-only)
				p.my-3 {{ $t('event_poll.welcome', {eventName, eventOrganizer}) }}
		.card(v-if="eventName")
			.card-header
				.row
					.col
						h5 {{ $t('event_poll.title', {eventName}) }}
				.row
					.col-md-4
						p.text-muted Organizer:
					.col-md-8
						p {{ eventOrganizer }}
				.row
					.col-md-4
						p.text-muted Event description:
					.col-md-8
						p {{ eventDesc }}
				.row
					.col-md-4
						p.text-muted When can it take place:
					.col-md-8
						p {{ timeWindow }}
				hr.my-3

				b-btn.btn-block(v-b-toggle.weekday-ranker="" variant="info") Which days work best for you?
				b-collapse#weekday-ranker(accordion="poll-questions" :visible="true")
					ranker(:elements="$t('date_picker.days').map((day, index) => ({name: day, rank: 1}))")

			.card-footer

</template>
<script>
import dateFns from 'date-fns'


function fetchEvent() {
	let self = this;
	return this.$http.get("/v1/events/" + this.eventId
		,{
			headers: { 'Accept-Language': this.$i18n.locale }
		}).then(function(result) {
			return result.data.data;
		}, function(result) {
			self.$refs.errorBar.show(self.$i18n.t('errors.network'));
		});
}

export default {
	props: {
		eventId: {
			type: String,
			required: true
		}
	},
	data: () => ({
		eventName: null,
		eventOrganizer: null,
		evendDesc: null,
		eventTimeWindowFrom: null,
		eventTimeWindowTo: null
	}),
	created() {
		let self = this;
		fetchEvent.call(this).then(function(eventData) {
			if (eventData) {
				self.eventName = eventData.name;
				self.eventOrganizer = eventData.organizer;
				self.eventDesc = eventData.desc;
				self.eventTimeWindowFrom = eventData.time_window_from;
				self.eventTimeWindowTo = eventData.time_window_to;
				self.$refs.welcomeModal.show();
			}
		});
	},
	computed: {
		timeWindow() {
			return dateFns.format(this.eventTimeWindowFrom, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')})
			 + " - " +
			 dateFns.format(this.eventTimeWindowTo, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')});
		}
	}
}
</script>