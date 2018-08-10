<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal#updateAnswerModal(
			:title="$t('event_viewer.update.title')"
			:ok-title="$t('event_viewer.update.load')"
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
					p
						em.text-muted {{ eventOrganizer }} {{ $t('event_viewer.says') }} &nbsp;
						| {{ eventDesc }}
				li.list-group-item
					p.text-muted {{ $t('event_viewer.welcome', {organizer: eventOrganizer, timeWindow}) }}
					div(v-if="eventOpen")
						.alert.alert-danger(v-if="eventScheduleError")
							i.fas.fa-exclamation-triangle.fa-lg
							| &nbsp; {{ eventScheduleError }}
						div(v-else-if="eventScheduleParticipants")
							.alert.alert-info
								i.fas.fa-calendar-check.fa-lg
								| &nbsp; {{ $t('event_viewer.event_open') }}
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
					.col-auto.mt-1(v-if="eventOpen")
						router-link.btn.btn-success(
							role="button"
							:to="{ name: 'new_poll', params: {eventId: eventId}}"
						)
							i.fas.fa-question
							| &nbsp; {{ $t('event_viewer.create_poll') }}
					.col-auto.mt-1(v-if="eventOpen")
						button.btn.btn-primary(v-b-modal.updateAnswerModal="")
							i.fas.fa-edit
							| &nbsp; {{ $t('event_viewer.update_poll') }}
					.col-auto.mt-1(v-if="!eventOpen")
						router-link.btn.btn-primary(
							role="button"
							:to="{name: 'new_event'}"
						)
							i.fas.fa-plus
							| &nbsp; {{ $t('event_viewer.create_new_event') }}

		error-page(
			v-else-if="loaded"
			:message="$t('errors.not_found')"
		)
</template>
<script>
import { fetchEventMixin, timeWindowMixin, colorCodes } from '../globals'
import dateFns from 'date-fns'

const SCHEDULE_DATES_LIMIT = 5;

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
		eventStatus: null,
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
			this.fetchEvent(this.eventId).then(function(eventData) {
				if (eventData) {
					self.eventName = eventData.name;
					self.eventOrganizer = eventData.organizer;
					self.eventDesc = eventData.desc;
					self.eventTimeWindowFrom = eventData.time_window_from;
					self.eventTimeWindowTo = eventData.time_window_to;
					self.eventState = eventData.state;
					self.eventScheduledFrom = eventData.scheduled_from;
					self.eventScheduledTo = eventData.scheduled_to;
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
		eventCanceled() {
			return this.eventState == "CANCELED";
		},
		eventOpen() {
			return this.eventState == "OPEN";
		},
		eventScheduled() {
			return this.eventState == "SCHEDULED";
		},
		eventScheduledTime() {
			return dateFns.format(this.eventScheduledFrom, this.$i18n.t('time_format'), {locale: this.$i18n.t('date_fns_locale')});
		},
		minDate() {
			return dateFns.parse(this.eventTimeWindowFrom);
		},
		maxDate() {
			return dateFns.parse(this.eventTimeWindowTo);
		},
		eventParticipants() {
			if (this.eventSchedule) {
				return this.eventSchedule.participants
			} else {
				return 0;
			}
		},
		scheduleCalendarAttributes() {
			return Array.map(this.eventScheduleDates.slice(0, SCHEDULE_DATES_LIMIT), date_entry => ({
				dates: dateFns.parse(date_entry.date),
				highlight: {
					backgroundColor: this.colorForDate(date_entry)
				},
				popover: {
					label: this.$i18n.tc('event_viewer.participants_for_date', -date_entry.negative_rank+1, {count: -date_entry.negative_rank})
				}
			}));
		}
	},
	methods: {
		colorForDate(date_entry) {
			let cant_make_it_count = -date_entry.negative_rank;
			let fraction_cant_make_it = cant_make_it_count / this.eventParticipants;
			let colorEntry = [[0.5, colorCodes.red], [0.0, colorCodes.yellow]].find(function(item) {
				return fraction_cant_make_it > item[0];
			});
			return (colorEntry ? colorEntry[1] : colorCodes.green);
		},
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
		}
	}
}
</script>