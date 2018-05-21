<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal(ref="welcomeModal" hide-header ok-only)
				p.my-3 {{ $t('event_poll.welcome', {eventName, eventOrganizer}) }}
		.card(v-if="eventId")
			.card-header
				.row.align-items-center
					.col-md-2.text-center.align-items-center
						strong.h5 {{ $t('event_poll.title', {eventName}) }}
					.col
						b-progress(:max="lastStep")
							b-progress-bar(:value="parseInt($route.query.step)" variant="success")
								| {{ $t('event_editor.step', {step: $route.query.step, lastStep: lastStep}) }}

			.card-body
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

				div(v-if="$route.query.step == 1")
					ul.list-group

			.card-footer
				.row(v-if="$route.query.step < lastStep")
					.col.text-left
						router-link.btn.btn-primary(
							v-if="$route.query.step > firstStep"
							role="button"
							:to="{ name: 'poll', params: { event_id: eventId }, query: {step: ($route.query.step == firstStep ? $route.query.step : parseInt($route.query.step) - 1) }}"
							:class="{disabled: $route.query.step == firstStep}"
						)
							span.oi.oi-arrow-thick-left
							span &nbsp; {{ $t('event_editor.prev') }}
					.col.text-right
						router-link.btn.btn-primary.btn-(
							role="button"
							:to="{ name: 'poll', params: { event_id: eventId }, query: {step: parseInt($route.query.step) + 1 }}"
						)
							span {{ $t('event_editor.next') }} &nbsp;
							span.oi.oi-arrow-thick-right

</template>
<script>
import dateFns from 'date-fns'
import { sanitizeStepRouteParameter } from '../globals.js'

const firstStep = 1;
const lastStep = 3;

function fetchEvent(event_id) {
	let self = this;
	return this.$http.get("/v1/events/" + this.$route.params.event_id
		,{
			headers: { 'Accept-Language': this.$i18n.locale }
		}).then(function(result) {
			return result.data.data;
		}, function(result) {
			self.$refs.errorBar.show(self.$i18n.t('errors.network'));
		});
}

export default {
	data: () => ({
		eventId: null,
		eventName: null,
		eventOrganizer: null,
		evendDesc: null,
		eventDateFrom: null,
		eventDateTo: null,
		firstStep,
		lastStep
	}),
	beforeRouteEnter: (to, from, next) => {
		next(sanitizeStepRouteParameter(to, firstStep, lastStep, true));
	},
	created() {
		let self = this;
		fetchEvent.call(this).then(function(eventData) {
			if (eventData) {
				self.eventId = eventData.id;
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