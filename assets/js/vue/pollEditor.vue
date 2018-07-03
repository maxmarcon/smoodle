<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal(ref="welcomeModal" hide-header ok-only)
				p.my-3 {{ $t('poll_editor.welcome', {eventName, eventOrganizer}) }}
		.card(v-if="eventName")
			.card-header
				.row
					.col
						h5 {{ $t('poll_editor.title', {eventName}) }}
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

				b-btn#weekday-ranker-button.d-flex.btn-block(v-b-toggle.weekday-ranker="")
					span.oi.oi-chevron-bottom(v-if="groupVisibility['weekday-ranker-group']")
					span.oi.oi-chevron-top(v-else)
					span.ml-2
					| {{ $t('poll_editor.poll.weekday_ranks') }}
				b-tooltip(
					target="weekday-ranker-button"
					triggers=""
					:title="$t('poll_editor.poll.weekday_ranks_help')"
					:show="groupVisibility['weekday-ranker-group'] && showToolTip('weekday-ranker')"
				)
				b-collapse#weekday-ranker(
					accordion="poll-questions"
					v-model="groupVisibility['weekday-ranker-group']"
					:visible="true"
				)
					ranker(:elements="$t('date_picker.days').map((day, index) => ({name: day, rank: 1}))")

			.card-footer

</template>
<script>
import dateFns from 'date-fns'
import { showToolTip } from '../globals'

function fetchEvent() {
	let self = this;
	return this.$http.get("/v1/events/" + this.eventId
		,{
			headers: { 'Accept-Language': this.$i18n.locale }
		}).then(function(result) {
			return result.data.data;
		}, function(result) {
			if (result.request.status == 404) {
				self.$refs.errorBar.show(self.$i18n.t('errors.not_found'));
			} else {
				self.$refs.errorBar.show(self.$i18n.t('errors.network'));
			}
		});
}

export default {
	props: {
		eventId: {
			type: String,
			required: true
		},
		pollId: {
			type: String
		}
	},
	data: () => ({
		showToolTip,
		eventName: null,
		eventOrganizer: null,
		evendDesc: null,
		eventTimeWindowFrom: null,
		eventTimeWindowTo: null,
		groupVisibility: {
			'weekday-ranker-group': false
		}
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

		if (this.pollId) {
			console.log("we should fetch an existing poll here");
		}
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