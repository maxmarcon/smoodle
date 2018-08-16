<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal#updateAnswerModal(
			:title="$t('event_viewer.update.title')"
			:ok-title="$t('event_viewer.update.load')"
			:cancel-title="$t('actions.cancel')"
			:ok-disabled="!pollParticipant"
			@ok="loadPoll"
		)
			p.form-text {{ $t('event_viewer.update.how_to') }}
			.form-group
				input#pollParticipant.form-control(
					v-model.trim="pollParticipant"
					:class="{'is-invalid': pollParticipantError}"
					:placeholder="$t('event_viewer.update.name_placeholder')"
					@keyup.enter="loadPoll"
				)
				.invalid-feedback {{ pollParticipantError }}

		b-modal(ref="copiedToClipboardModal" hide-header ok-only)
			p {{ $t('event_editor.link_copied') }}

		b-modal#cancelEventModal(
			:title="$t('event_viewer.cancel_event')"
			:ok-title="$t('event_viewer.cancel_event')"
			:cancel-title="$t('actions.cancel')"
			@ok="cancelEvent"
		)
			p {{ $t('event_viewer.really_cancel_event') }}

		b-modal(ref="eventCanceledModal"
			:title="$t('event_viewer.cancel_event')"
			ok-only
		)
			p {{ $t('event_viewer.event_canceled_ok') }}

		b-modal(ref="eventCancelErrorModal"
			:title="$t('errors.error')"
			ok-only
		)
			p {{ $t('event_viewer.cancel_event_error') }}

		b-modal(ref="eventOpenedModal"
			:title="$t('event_viewer.open_event')"
			ok-only
		)
			p {{ $t('event_viewer.event_opened_ok') }}

		b-modal(ref="eventOpenErrorModal"
			:title="$t('errors.error')"
			ok-only
		)
			p {{ $t('event_viewer.open_event_error') }}


		.card(v-if="eventName")
			.card-header
				event-header#event-header(
					:name="eventName"
					:organizer="eventOrganizer"
					:timeWindowFrom="eventTimeWindowFrom"
					:timeWindowTo="eventTimeWindowTo"
				)
			ul.list-group.list-group-flush
				li.list-group-item
					p
						em.text-muted {{ isOrganizer ? $t('event_viewer.description') : $t('event_viewer.organizer_says', {organizer: eventOrganizer}) }} &nbsp;
						| {{ eventDesc }}
				li.list-group-item(v-if="isOrganizer && eventOpen")
					.form-group.row.justify-content-center
						label.col-md-auto.col-form-label {{ $t('event_viewer.share_link') }}
						.col-md
							.input-group
								input.form-control(:value="eventShareLink" readonly)
								.input-group-append
									button.btn.btn-sm.btn-outline-secondary(
										v-clipboard:copy="eventShareLink"
										v-clipboard:success="clipboard"
									)
										span.fas.fa-share-alt
				li.list-group-item
					p.text-muted(v-if="!isOrganizer") {{ $t('event_viewer.welcome', {organizer: eventOrganizer, timeWindow}) }}
					div(v-if="eventOpen")
						.alert.alert-danger(v-if="eventScheduleError")
							i.fas.fa-exclamation-triangle.fa-lg
							| &nbsp; {{ eventScheduleError }}
						div(v-else-if="eventScheduleParticipants")
							.alert.alert-info
								i.fas.fa-calendar-check.fa-lg
								| &nbsp; {{ $t('event_viewer.event_open', {participants: eventScheduleParticipants}) }}
							.row.justify-content-center
								.col-md-6.text-center
									v-calendar(
										:attributes="scheduleCalendarAttributes"
										:min-date="minDate"
										:max-date="maxDate"
										:is-double-paned="true"
									)
						div(v-else-if="loaded").alert.alert-primary(v-else)
							i.fas.fa-meh-rolling-eyes.fa-lg
							| &nbsp; {{ $t('event_viewer.no_participants') }}
					.alert.alert-success(v-else-if="eventScheduled")
						i.fas.fa-handshake.fa-lg
						| &nbsp;  {{ $t('event_viewer.event_scheduled', {time: eventScheduledTime, organizer: eventOrganizer}) }}
					.alert.alert-warning(v-else-if="eventCanceled")
						i.fas.fa-ban.fa-lg
						| &nbsp; {{ $t('event_viewer.event_canceled') }}

			.card-footer
				.row.justify-content-center
					.col-auto.mt-1(v-if="eventOpen && isOrganizer")
						button.btn.btn-warning(v-b-modal.cancelEventModal="")
							i.fas.fa-ban
							| &nbsp; {{ $t('event_viewer.cancel_event') }}
					.col-auto.mt-1(v-if="eventCanceled && isOrganizer")
						button.btn.btn-warning(@click="openEvent")
							i.fas.fa-undo
							| &nbsp; {{ $t('event_viewer.open_event') }}
					.col-auto.mt-1(v-if="eventOpen && !isOrganizer")
						router-link.btn.btn-success(
							role="button"
							:to="{ name: 'new_poll', params: {eventId: eventId}}"
						)
							i.fas.fa-question
							| &nbsp; {{ $t('event_viewer.create_poll') }}
					.col-auto.mt-1(v-if="eventOpen && !isOrganizer")
						button.btn.btn-primary(v-b-modal.updateAnswerModal="")
							i.fas.fa-edit
							| &nbsp; {{ $t('event_viewer.update_poll') }}


		error-page(
			v-else-if="loaded"
			:message="$t('errors.not_found')"
		)
</template>
<script>
import { fetchEventMixin, timeWindowMixin, colorCodes, eventHelpersMixin } from '../globals'
import dateFns from 'date-fns'

const SCHEDULE_DATES_LIMIT = null;

export default {
	mixins: [fetchEventMixin, timeWindowMixin, eventHelpersMixin],
	props: {
		eventId: {
			type: String,
			required: true
		},
		secret: String
	},
	data: () => ({
		eventName: null,
		eventOrganizer: null,
		evendDesc: null,
		eventState: null,
		eventShareLink: null,
		eventTimeWindowFrom: null,
		eventTimeWindowTo: null,
		eventScheduledFrom: null,
		eventScheduleDates: [],
		eventScheduleParticipants: 0,
		eventScheduleError: null,
		pollParticipant: null,
		pollParticipantError: null,
		loaded: false
	}),
	created() {
		let self = this;
		Promise.all([
			this.fetchEvent(this.eventId, this.secret).then(function(eventData) {
				if (eventData) {
					self.assignEventData(eventData);
				}
			}),
			this.fetchSchedule(this.eventId).then(function(scheduleData) {
				if (scheduleData) {
					self.eventScheduleDates = scheduleData.dates;
					self.eventScheduleParticipants = scheduleData.participants;
				}
			})
		]).then(function() { self.loaded = true });
	},
	computed: {
		isOrganizer() {
			return this.secret;
		},
		eventParticipants() {
			if (this.eventSchedule) {
				return this.eventSchedule.participants
			} else {
				return 0;
			}
		},
		scheduleCalendarAttributes() {
			let limit = (SCHEDULE_DATES_LIMIT != null ? SCHEDULE_DATES_LIMIT : this.eventScheduleDates.length);
			return this.eventScheduleDates.slice(0, limit).map((date_entry, index) => ({
				dates: dateFns.parse(date_entry.date),
				highlight: {
					backgroundColor: this.colorForDate(index)
				},
				popover: {
					label: this.$i18n.tc('event_viewer.participants_for_date', -date_entry.negative_rank, {count: -date_entry.negative_rank})
				}
			}));
		}
	},
	methods: {
		clipboard() {
      this.$refs.copiedToClipboardModal.show();
		},
		colorForDate: (index) => (
			[[10, colorCodes.red], [5, colorCodes.yellow], [0, colorCodes.green]].find(function(item) {
				return index >= item[0];
			})[1]
		),
		fetchSchedule(eventId) {
			let self = this;
			return this.$http.get("/v1/events/" + eventId + "/schedule",
				{
					headers: { 'Accept-Language': this.$i18n.locale },
					params: {
						limit: SCHEDULE_DATES_LIMIT
					}
				}).then(function(result) {
					self.eventScheduleError = null;
					return result.data.data;
				}, function(result) {
					if (result.request.status == 404) {
						self.eventScheduleError = self.$i18n.t('event_viewer.schedule_not_found');
					} else {
						self.$refs.errorBar.show(self.$i18n.t('errors.network'));
					}
			});
		},
		fetchPoll(participant) {
			let self = this;
			return this.$http.get("/v1/events/" + this.eventId + "/polls",
				{
					headers: { 'Accept-Language': this.$i18n.locale },
					params: {
						participant
					}
				}).then(function(result) {
					self.pollParticipantError = null;
					return result.data.data;
				}, function(result) {
					if (result.request.status == 404) {
						self.pollParticipantError = self.$i18n.t('event_viewer.update.poll_not_found');
					} else {
						self.$refs.errorBar.show(self.$i18n.t('errors.network'));
					}
			});
		},
		loadPoll(bvEvt) {
			bvEvt.preventDefault();
			let self = this;
			if (this.pollParticipant) {
				this.fetchPoll(this.pollParticipant).then(function(poll) {
					if (poll) {
						self.$router.push({name: 'edit_poll', params: {pollId: poll.id}});
					}
				});
			}
		},
		assignEventData(eventData) {
			this.eventName = eventData.name;
			this.eventOrganizer = eventData.organizer;
			this.eventDesc = eventData.desc;
			this.eventTimeWindowFrom = eventData.time_window_from;
			this.eventTimeWindowTo = eventData.time_window_to;
			this.eventState = eventData.state;
			this.eventScheduledFrom = eventData.scheduled_from;
			this.eventScheduledTo = eventData.scheduled_to;
			this.eventShareLink = eventData.share_link;
		},
		openEvent() {
			let self = this;
			this.$http.patch("/v1/events/" + this.eventId,
				{
					event: { state: "OPEN", secret: this.secret }
				},
				{
					headers: { 'Accept-Language': this.$i18n.locale }
				},
			).then(function(result) {
				self.assignEventData(result.data.data);
				self.$refs.eventOpenedModal.show();
			}, function(result) {
				self.$refs.eventOpenErrorModal.show();
			}).finally(function() {
				self.$scrollTo('#event-header');
			});
		},
		cancelEvent() {
			let self = this;
			this.$http.patch("/v1/events/" + this.eventId,
				{
					event: { state: "CANCELED", secret: this.secret }
				},
				{
					headers: { 'Accept-Language': this.$i18n.locale }
				},
			).then(function(result) {
				self.assignEventData(result.data.data);
				self.$refs.eventCanceledModal.show();
			}, function(result) {
				self.$refs.eventCancelErrorModal.show();
			}).finally(function() {
				self.$scrollTo('#event-header');
			})
		}
	}
}
</script>