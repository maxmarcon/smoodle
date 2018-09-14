<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal#updateAnswerModal(
			:title="$t('event_viewer.update.title')"
			:ok-title="$t('event_viewer.update.load')"
			:cancel-title="$t('actions.cancel')"
			:ok-disabled="!pollParticipant || requestOngoing"
			:cancel-disabled="requestOngoing"
			@ok="loadPoll"
		)
			.form-group
				label(for="pollParticipant") {{ $t('event_viewer.update.how_to') }}
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

		b-modal#participantsListModal(
			:title="$t('event_viewer.current_participants')"
			ok-only
		)
			p {{ eventScheduleParticipants && eventScheduleParticipants.join(', ') + '.' }}

		b-modal#scheduleEventModal(
			:title="$t('event_viewer.schedule_event')"
			:cancel-title="$t('actions.cancel')"
			:ok-disabled="requestOngoing"
			:ok-only="!selectedDate"
			@ok="scheduleEvent"
		)
			div(v-if="selectedDate")
				.alert.alert-danger(v-if="selectedDateAttribute && selectedDateAttribute.customData.negative_rank < 0")
					| {{ $tc('event_viewer.warning_bad_date', -selectedDateAttribute.customData.negative_rank, {participants: -selectedDateAttribute.customData.negative_rank}) }}
				.alert.alert-info {{ $t('event_viewer.about_to_schedule', {date: selectedDateFormatted}) }}

				.text-center
					label(for="timePicker") {{ $t('event_viewer.select_time') }}
				.d-flex.justify-content-center
					date-picker#timePicker(
						v-model="selectedTime"
						:config="timePickerOptions"
					)
			div(v-else)
				p {{ $t('event_viewer.select_date_first') }}

		b-modal#scheduledEventModal(
			ref="scheduledEventModal"
			:title="$t('event_viewer.schedule_event')"
			ok-only
		)
			p {{ $t('event_viewer.event_scheduled_organizer', {datetime: eventScheduledDateTime, time_distance: eventScheduledDateTimeRelative}) }}

		b-modal(ref="scheduleEventErrorModal"
			:title="$t('errors.error')"
			ok-only
		)
			p {{ $t('event_viewer.schedule_event_error') }}

		.card(v-if="loadedSuccessfully")
			.card-header(:class="eventBackgroundClass")
				event-header#event-header(
					v-bind="eventData"
				)
			ul.list-group.list-group-flush
				li.list-group-item
					p
						em.text-muted {{ isOrganizer ? $t('event_viewer.description') : $t('event_viewer.organizer_says', {organizer: eventOrganizer}) }} &nbsp;
						| {{ eventDesc }}
				li.list-group-item(v-if="isOrganizer && !eventCanceled")
					.alert.alert-success
						i.fas.fa-key
						| &nbsp; {{ $t('event_viewer.welcome_organizer', {organizer: eventOrganizer}) }}
					.form-group.row.justify-content-center
						label.col-md-auto.col-form-label {{ $t('event_viewer.share_link') }}
						.col-md
							.input-group
								input.form-control(:value="eventShareLink" readonly)
								.input-group-append
									a.btn.bdn-sm.btn-outline-secondary(
										target="_blank"
										:href="whatsAppMessageURL(eventShareLink)"
									)
										span.fab.fa-lg.fa-whatsapp
									button.btn.btn-sm.btn-outline-secondary(
										v-clipboard:copy="eventShareLink"
										v-clipboard:success="clipboard"
									)
										span.fas.fa-lg.fa-share-alt
				li.list-group-item
					.alert.alert-success(v-if="!isOrganizer")
						i.fas.fa-share-alt
						| &nbsp; {{ $t('event_viewer.welcome', {organizer: eventOrganizer}) }}
					div(v-if="eventOpen")
						.alert.alert-warning(v-if="eventModified && !isOrganizer")
							i.fas.fa-cut
							| &nbsp; {{ $t('event_viewer.event_modified', {time_distance: eventModifiedRelative}) }}
						.alert.alert-danger(v-if="eventScheduleError")
							i.fas.fa-exclamation-triangle.fa-lg
							| &nbsp; {{ eventScheduleError }}
						div(v-else-if="eventScheduleParticipantsCount")
							.alert.alert-info
								i18n(path="event_viewer.event_open_organizer" v-if="isOrganizer")
									i.fas.fa-calendar-check.fa-lg(place="calendar_icon")
									a(href="#" place="participants" v-b-modal.participantsListModal="")
										| {{ $tc('event_viewer.nof_participants', eventScheduleParticipantsCount, {participants: eventScheduleParticipantsCount}) }}

								i18n(path="event_viewer.event_open" v-else)
									i.fas.fa-calendar-check.fa-lg(place="calendar_icon")
									span(place="answers") {{ $tc('event_viewer.answers', eventScheduleParticipantsCount, {count: eventScheduleParticipantsCount}) }}
							.row.justify-content-md-between.justify-content-lg-center
								.col-md-3.offset-md-1.order-md-last.text-justify
									.form-group
										i18n.small.text-muted(
											:path="isOrganizer ? 'event_viewer.date_selection_help_organizer' : 'event_viewer.date_selection_help'"
											tag="p"
										)
											span.text-success(place="best") {{ $t('event_viewer.best') }}
											span.text-danger(place="worst") {{ $t('event_viewer.worst') }}
											span.text-success(place="green") {{ $t('event_viewer.green') }}
											span.text-danger(place="red") {{ $t('event_viewer.red') }}

								.col-md-6.text-center
									.form-group
										v-date-picker(
											v-if="isOrganizer"
											mode="single"
											v-model="selectedDate"
											:attributes="scheduleCalendarAttributes"
											:is-inline="true"
											:is-linked="true"
											:min-date="minDate"
											:max-date="maxDate"
											:is-double-paned="differentMonths"
											nav-visibility="hidden"
											:theme-styles="{dayCellNotInMonth: {opacity: 0}}"
											@dayclick="dayClicked"
										)
										v-calendar(
											v-else
											:is-linked="true"
											nav-visibility="hidden"
											:attributes="scheduleCalendarAttributes"
											:min-date="minDate"
											:max-date="maxDate"
											:is-double-paned="differentMonths"
											:theme-styles="{dayCellNotInMonth: {opacity: 0}}"
										)

						div.alert.alert-primary(v-else v-else-if="loaded")
							i18n(path="event_viewer.no_participants_organizer" v-if="isOrganizer")
								i.fas.fa-grin-beam-sweat.fa-lg(place="icon")
							i18n(path="event_viewer.no_participants" v-else)
								i.fas.fa-trophy.fa-lg(place="icon")
					.alert.alert-success(v-else-if="eventScheduled")
						i.fas.fa-handshake.fa-lg
						| &nbsp; {{ $t(isOrganizer ? 'event_viewer.event_scheduled_organizer' : 'event_viewer.event_scheduled', {datetime: eventScheduledDateTime, organizer: eventOrganizer, time_distance: eventScheduledDateTimeRelative}) }}
					.alert.alert-warning(v-else-if="eventCanceled")
						i.fas.fa-ban.fa-lg
						| &nbsp; {{ $t(isOrganizer ? 'event_viewer.event_canceled_organizer' : 'event_viewer.event_canceled') }}

			.card-footer(v-if="eventOpen || isOrganizer")
				.row.justify-content-center
					.col-12.col-sm-auto.mt-1(v-if="eventOpen && isOrganizer && eventScheduleParticipantsCount")
						button.btn.btn-block.btn-primary(v-b-modal.scheduleEventModal="" :disabled="requestOngoing")
							i.fas.fa-clock
							| &nbsp; {{ $t('event_viewer.schedule_event') }}
					.col-12.col-sm-auto.mt-1(v-if="eventOpen && isOrganizer")
						router-link.btn.btn-block.btn-success(
							role="button"
							:to="{ name: 'edit_event', params: {eventId: eventId, secret: secret}, query: {s: secret} }"
						)
							i.fas.fa-edit
							| &nbsp; {{ $t('event_viewer.edit_event') }}
					.col-12.col-sm-auto.mt-1(v-if="eventOpen && isOrganizer")
						button.btn.btn-block.btn-block.btn-warning(v-b-modal.cancelEventModal="" :disabled="requestOngoing")
							i.fas.fa-ban
							| &nbsp; {{ $t('event_viewer.cancel_event') }}
					.col-12.col-sm-auto.mt-1(v-if="!eventOpen && isOrganizer")
						button.btn.btn-block.btn-warning(@click="openEvent" :disabled="requestOngoing")
							i.fas.fa-undo
							| &nbsp; {{ $t('event_viewer.open_event') }}
					.col-12.col-sm-auto.mt-1(v-if="eventOpen && !isOrganizer")
						router-link.btn.btn-block.btn-success(
							role="button"
							:to="{ name: 'new_poll', params: {eventId: eventId}}"
						)
							i.fas.fa-question
							| &nbsp; {{ $t('event_viewer.create_poll') }}
					.col-12.col-sm-auto.mt-1(v-if="eventOpen && !isOrganizer && eventScheduleParticipantsCount")
						button.btn.btn-block.btn-primary(v-b-modal.updateAnswerModal="" :disabled="requestOngoing")
							i.fas.fa-edit
							| &nbsp; {{ $t('event_viewer.update_poll') }}


		error-page(
			v-else-if="loaded"
			:message="$t('errors.not_found')"
		)
</template>
<script>
import { colorCodes, eventHelpersMixin, eventDataMixin, scrollToTopMixin, restMixin, whatsAppHelpersMixin} from '../globals'
import dateFns from 'date-fns'

const SCHEDULE_DATES_LIMIT = null;

export default {
	mixins: [restMixin, eventHelpersMixin, eventDataMixin, scrollToTopMixin, whatsAppHelpersMixin],
	props: {
		eventId: {
			type: String,
			required: true
		},
		secret: String
	},
	data: () => ({
		eventScheduleDates: [],
		eventScheduleParticipantsCount: 0,
		eventScheduleParticipants: [],
		eventScheduleError: null,
		pollParticipant: null,
		pollParticipantError: null,
		loaded: false,
		loadedSuccessfully: false,
		requestOngoing: false,
		selectedDate: null,
		selectedTime: "19:30",
		selectedDateAttribute: null,
		timePickerOptions: {
			format: 'HH:mm',
			inline: true,
			icons: {
				up: "fas fa-sort-up fa-2x",
				down: "fas fa-sort-down fa-2x"
			}
		}
	}),
	created() {
		let self = this;
		Promise.all([
			this.restRequest(['events', this.eventId].join('/'), { params: {secret: this.secret} }).then(function(result) {
				self.assignEventData(result.data.data);
			}),
			this.restRequest(['events', this.eventId, 'schedule'].join('/'),
				{ params: {limit: SCHEDULE_DATES_LIMIT, secret: this.secret } }).then(function(result) {
				self.eventScheduleDates = result.data.data.dates;
				self.eventScheduleParticipants = result.data.data.participants;
				self.eventScheduleParticipantsCount = result.data.data.participants_count;
			})
		])
		.then(function() { self.loadedSuccessfully = true; })
		.finally(function() { self.loaded = true });
	},
	computed: {
		isOrganizer() {
			return this.secret;
		},
		scheduleCalendarAttributes() {
			// Hack: we add this otherwise unused locale variable
			// to triger a dependency on $i18n.locale. This will cause
			// the scheduleCalendarAttributes to be recomputed whenever the locale changes, thus
			// allowing live locale changes on the client side
			let _hack_dependency_on_locale = this.$i18n.locale;

			let scheduleDates = this.eventScheduleDates.length;
			let minNegativeRank;
			let maxPositiveRank;
			if (scheduleDates > 0) {
				minNegativeRank = this.eventScheduleDates[scheduleDates-1].negative_rank;
				maxPositiveRank = this.eventScheduleDates[0].positive_rank;
			}
			let limit = (SCHEDULE_DATES_LIMIT != null ? SCHEDULE_DATES_LIMIT : this.eventScheduleDates.length);
			return this.eventScheduleDates.slice(0, limit).map((date_entry, index) => ({
				dates: dateFns.parse(date_entry.date),
				highlight: {
					backgroundColor: (date_entry.negative_rank < 0 ? colorCodes.red : colorCodes.green),
					opacity: this.opacityForDate(date_entry, minNegativeRank, maxPositiveRank)
				},
				popover: {
					label: this.labelForDate
				},
				customData: date_entry
			}));
		},
		selectedDateFormatted() {
			return dateFns.format(this.selectedDate, this.$i18n.t('date_format'), {locale: this.$i18n.t('date_fns_locale')});
		}
	},
	methods: {
		dayClicked({attributes}) {
			this.selectedDateAttribute = (attributes.length > 0 ? attributes[0] : null);
		},
		opacityForDate(date_entry, minNegativeRank, maxPositiveRank) {
			return (date_entry.negative_rank < 0
				? date_entry.negative_rank / minNegativeRank
				: Math.max(date_entry.positive_rank, 0.5) / maxPositiveRank);
		},
		labelForDate(attribute) {
			let date_entry = attribute.customData;
			if (date_entry.negative_rank < 0) {
				if (this.isOrganizer) {
					return this.$i18n.tc('event_viewer.negative_participants_list_date', date_entry.negative_participants.length,
						{participants: date_entry.negative_participants.join(', ')} );
				} else {
					return this.$i18n.tc('event_viewer.negative_participants_for_date', -date_entry.negative_rank,
						{count: -date_entry.negative_rank});
				}
			} else {
				if (this.isOrganizer && date_entry.positive_rank > 0) {
					return this.$i18n.tc('event_viewer.positive_participants_list_date', date_entry.positive_participants.length,
						{participants: date_entry.positive_participants.join(', ')} );
				} else {
					return this.$i18n.tc('event_viewer.positive_participants_for_date', date_entry.positive_rank,
						{count: date_entry.positive_rank});
				}
			}
		},
		clipboard() {
      this.$refs.copiedToClipboardModal.show();
		},
		loadPoll(bvEvt) {
			bvEvt.preventDefault();
			let self = this;
			if (this.pollParticipant) {
				this.restRequest(['events', this.eventId, 'polls'].join('/'), {
					params: {
						participant: this.pollParticipant
					}
				}).then(function(result) {
					self.pollParticipantError = null
					self.$router.push({name: 'edit_poll', params: {pollId: result.data.data.id}});
				}, function(error) {
					if (error.response && error.response.status == 404) {
						self.pollParticipantError = self.$i18n.t('event_viewer.update.poll_not_found');
					} else {
						throw error;
					}
				});
			}
		},
		openEvent() {
			let self = this;
			this.restRequest(['events', this.eventId].join('/'), {
				method: 'patch',
				data: {
					event: {
						state: "OPEN",
						secret: this.secret,
						scheduled_from: null,
						scheduled_to: null
					}
				}
			}).then(function(result) {
				self.assignEventData(result.data.data);
				self.$refs.eventOpenedModal.show();
			}, function(error) {
				self.$refs.eventOpenErrorModal.show();
				throw error;
			});
		},
		cancelEvent() {
			let self = this;
			this.restRequest(['events', this.eventId].join('/'), {
				method: 'patch',
				data: {
					event: { state: "CANCELED", secret: this.secret }
				}
			}).then(function(result) {
				self.assignEventData(result.data.data);
				self.$refs.eventCanceledModal.show();
			}, function(error) {
				self.$refs.eventCancelErrorModal.show();
				throw error;
			});
		},
		scheduleEvent() {
			if (!this.selectedDate) {
				return;
			}

			let [hours, minutes] = this.selectedTime.split(':');
			this.selectedDate = dateFns.setHours(
				dateFns.setMinutes(this.selectedDate, minutes),
				hours
			);

			let self = this;
			this.restRequest(['events', this.eventId].join('/'), {
				method: 'patch',
				data: {
					event: {
						state: 'SCHEDULED',
						secret: this.secret,
						scheduled_from: this.selectedDate.toISOString(),
						scheduled_to: dateFns.addHours(this.selectedDate, 6).toISOString()
					}
				}
			}).then(function(result) {
				self.assignEventData(result.data.data);
				self.$refs.scheduledEventModal.show();
			}, function(error) {
				self.$refs.scheduleEventErrorModal.show();
				throw error;
			});
		}
	}
}
</script>