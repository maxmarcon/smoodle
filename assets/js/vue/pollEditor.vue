<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal#pollSavedModal(ref="pollSavedModal" hide-header ok-only :ok-title="$t('poll_editor.back_to_event')" @hidden="backToEvent")
			p {{ $t('poll_editor.poll_saved') }}

		b-modal#dateRankerHelpModal(ok-only :title="$t('poll_editor.date_ranker_help_modal_title')")
			i18n(path="poll_editor.date_ranker_help_modal_content" tag="p")
				i.fas.fa-heart.text-success(place="good")
				i.fas.fa-thumbs-down.text-danger(place="bad")
				i.fas.fas.fa-trash-alt(place="trash")

		b-modal#weekdayRankerHelpModal(ok-only :title="$t('poll_editor.weekday_ranker_help_modal_title')")
			i18n(path="poll_editor.weekday_ranker_help_modal_content" tag="p")
				i.fas.fa-thumbs-up.text-success(place="good")
				i.fas.fa-circle.text-warning(place="ok")
				i.fas.fa-thumbs-down.text-danger(place="bad")

		b-modal#pollDeleteModal(
			:title="$t('poll_editor.delete_poll')"
			@ok="deletePoll"
			:ok-title="$t('poll_editor.delete_poll')"
			:cancel-title="$t('actions.cancel')"
			:ok-disabled="requestOngoing"
			ok-variant="danger"
		)
			p {{ $t('poll_editor.really_delete') }}

		b-modal(ref="pollDeletedModal"
			:title="$t('poll_editor.delete_poll')"
			ok-only
			:ok-title="$t('poll_editor.back_to_event')"
			@hidden="backToEvent"
		)
			p {{ $t('poll_editor.poll_deleted') }}

		b-modal(ref="pollDeleteErrorModal"
			:title="$t('errors.error')"
			ok-only
		)
			p {{ $t('poll_editor.poll_delete_error') }}

		b-modal#eventNoLongerOpenModal(ref="eventNoLongerOpenModal"
			hide-header
			:ok-title="$t('poll_editor.back_to_event')"
			ok-only
			@ok="backToEvent"
		)
			p {{ $t('poll_editor.event_no_longer_open') }}

		.card(v-if="loadedSuccessfully")
			.card-header(:class="eventBackgroundClass")
				event-header(
					v-bind="eventData"
				)
			.card-body
				.alert.alert-info(v-if="pollId")
					i.fas.fa-edit
					| &nbsp; {{ $t('poll_editor.welcome', {participant: pollParticipant}) }}
				.alert.alert-info(v-else)
					i.fas.fa-edit
					| &nbsp; {{ $t('poll_editor.welcome_new_participant') }}
				.small.text-danger(name="event-error") {{ eventError }}

				div(v-if="eventId")
					b-btn.btn-block.d-flex(
							v-b-toggle.organizer-group=""
							:variant="groupVariant('participant-group')"
						)
							span.fas.fa-chevron-up(v-if="groupVisibility['participant-group']")
							span.fas.fa-chevron-down(v-else)
							span.ml-2.mr-auto {{ $t('poll_editor.participant_group') }}
							div(v-if="showGroupErrorIcon('participant-group')").fas.fa-exclamation
							div(v-else-if="showGroupOkIcon('participant-group')").fas.fa-check
					b-collapse#organizer-group(accordion="poll-editor" v-model="groupVisibility['participant-group']")
							b-card
								.form-group.row
									label.col-md-3.col-form-label(for="pollParticipant") {{ $t('poll_editor.poll.participant') }}
									.col-md-9
										small.form-text.text-muted {{ $t('poll_editor.poll.participant_help') }}
										input#pollParticipant.form-control(
											v-model.trim="pollParticipant"
											@change="localValidation"
											@blur="localValidation"
											:class="inputFieldClass('pollParticipant')"
										)
										.invalid-feedback(name="poll-participant-error") {{ pollParticipantError }}


				b-btn#weekday-ranker-button.d-flex.btn-block.mt-2(
					v-b-toggle.weekday-ranker=""
					:variant="groupVariant('weekday-ranker-group')"
				)
					span.fas.fa-chevron-up(v-if="groupVisibility['weekday-ranker-group']")
					span.fas.fa-chevron-down(v-else)
					span.ml-2.mr-auto {{ $t('poll_editor.weekday_ranker_group') }}
					div(v-if="showGroupErrorIcon('weekday-ranker-group')").fas.fa-exclamation
					div(v-else-if="showGroupOkIcon('weekday-ranker-group')").fas.fa-check
				b-collapse#weekday-ranker(
					accordion="poll-editor"
					v-model="groupVisibility['weekday-ranker-group']"
					:visible="true"
				)
					b-card
						i18n.small.text-muted(path="poll_editor.weekday_ranker_help" tag="p")
							i.fas.fa-thumbs-up.text-success(place="good")
							i.fas.fa-circle.text-warning(place="ok")
							i.fas.fa-thumbs-down.text-danger(place="bad")
							a(v-b-modal.weekdayRankerHelpModal="" place="help" href="#") {{ $t('actions.tell_me_more')}}
						ranker(:elements="pollWeekdayRanks")
						.small.text-danger {{ pollWeekdayRanksError }}

				b-btn#calendar-ranker-button.d-flex.btn-block.mt-2(
					v-b-toggle.calendar-ranker=""
					:variant="groupVariant('calendar-ranker-group')"
				)
					span.fas.fa-chevron-up(v-if="groupVisibility['calendar-ranker-group']")
					span.fas.fa-chevron-down(v-else)
					span.ml-2.mr-auto {{ $t('poll_editor.calendar_ranker_group') }}
					div(v-if="showGroupErrorIcon('calendar-ranker-group')").fas.fa-exclamation
					div(v-else-if="showGroupOkIcon('calendar-ranker-group')").fas.fa-check
				b-collapse#calendar-ranker(
					accordion="poll-editor"
					v-model="groupVisibility['calendar-ranker-group']"
					:visible="true"
				)
					b-card
						.row.justify-content-md-between.justify-content-lg-center
							.col-md-3.offset-md-1.order-md-last.text-justify
								.form-group
									i18n.small.text-muted(path="poll_editor.date_ranker_helper" tag="p")
										i.fas.fa-heart.text-success(place="good")
										i.fas.fa-thumbs-down.text-danger(place="bad")
										a(v-b-modal.dateRankerHelpModal="" place="help" href="#") {{ $t('actions.tell_me_more') }}

							.col-md-6.text-center
								.form-group
									v-date-picker(
										:mode="(selectedDateRank && rangeModeSelected ? 'range' : 'single')"
										v-model="selectedDates"
										nav-visibility="hidden"
										:min-date="minDate"
										:max-date="maxDate"
										:is-inline="true"
										:is-double-paned="differentMonths"
										:attributes="datePickerAttributes"
										:tint-color="selectedDateRankColor"
										:is-linked="true"
										:show-caps="true"
										popover-visibility="hidden"
										:disabled-attribute="disabledAttribute"
										:drag-attribute="dragAttribute"
										:disabled-dates="disabledDates"
										@input="newDate"
										@dayclick="dayClicked"
									)
									.small.text-danger {{ pollDateRanksError }}

								.d-flex.justify-content-center.align-items-center
										.form-check
											p-radio.p-icon.p-plain(name="selectedDateRank" :value="1" v-model="selectedDateRank" toggle)
												i.icon.fas.fa-heart.text-success(slot="extra")
												i.icon.far.fa-heart(slot="off-extra")
												label(slot="off-label")
										.form-check
											p-radio.p-icon.p-plain(name="selectedDateRank" :value="-1" v-model="selectedDateRank" toggle)
												i.icon.fas.fa-thumbs-down.text-danger(slot="extra")
												i.icon.far.fa-thumbs-down(slot="off-extra")
												label(slot="off-label")
										.form-check
											p-radio.p-icon.p-plain(name="selectedDateRank" :value="0" v-model="selectedDateRank" toggle)
												i.icon.fas.fa-trash-alt(slot="extra")
												i.icon.far.fa-trash-alt(slot="off-extra")
												label(slot="off-label")
										.form-check
											p-check.p-switch.p-fill(v-model="rangeModeSelected" :disabled="!selectedDateRank")
												span {{ $t('poll_editor.range') }}



			.card-footer
				.row.justify-content-center
					.col-12.col-sm-auto.mt-1
						button.btn.btn-block.btn-primary(name="save-poll" @click="savePoll" :disabled="requestOngoing")
							i.fas.fa-save
							| &nbsp; {{ $t('poll_editor.save_poll') }}
					.col-12.col-sm-auto.mt-1(v-if="pollId")
						button.btn.btn-block.btn-danger(name="delete-poll"  v-b-modal.pollDeleteModal="" :disabled="requestOngoing")
							i.fas.fa-trash-alt
							| &nbsp; {{ $t('poll_editor.delete_poll') }}
					.col-12.col-sm-auto.mt-1
						button.btn.btn-block.btn-secondary(name="back-to-event" @click="backToEvent" :disabled="requestOngoing")
							i.fas.fa-ban
							| &nbsp; {{ $t('actions.cancel') }}

		error-page(
			v-else-if="loaded"
			:message="$t('errors.not_found')"
		)
</template>
<script>
import {
	accordionGroupsMixin,
	restMixin,
	colorCodes,
	eventHelpersMixin,
	eventDataMixin,
	scrollToTopMixin
} from '../globals'
import dateFns from 'date-fns'

export default {
	mixins: [accordionGroupsMixin, restMixin, scrollToTopMixin, eventHelpersMixin, eventDataMixin],
	props: {
		eventId: String,
		pollId: String
	},
	data() {
		return {
			errorsMap: {
				// maps, for each input group, the fields in the vue model to
				// the error fields and the error keys received by the back end
				'general': {
					errorField: 'eventError',
					errorKeys: 'event'
				},
				'participant-group': {
					pollParticipant: {
						required: true,
						errorField: 'pollParticipantError',
						errorKeys: 'participant'
					}
				},
				'weekday-ranker-group': {
					pollWeekdayRanks: {
						errorField: 'pollWeekdayRanksError',
						errorKeys: 'preferences.weekday_ranks'
					}
				},
				'calendar-ranker-group': {
					pollDateRanks: {
						errorField: 'pollDateRanksError',
						errorKeys: 'date_ranks'
					}
				}
			},
			groupVisibility: {
				'participant-group': true,
				'weekday-ranker-group': false,
				'calendar-ranker-group': false
			},
			eventError: null,
			pollWeekdayRanks: null,
			pollParticipant: null,
			pollParticipantError: null,
			pollWeekdayRanksError: null,
			pollDateRanksError: null,
			requestOngoing: false,
			loaded: false,
			loadedSuccessfully: false,
			selectedDates: null,
			selectedDateRank: 1,
			rangeModeSelected: false,
			datePickerAttributes: [],
			datePickerAttributesKey: 0,
			dragAttribute: {
				popover: {
					visibility: 'hidden'
				}
			},
			disabledAttribute: {
				contentStyle: {
					color: colorCodes.red,
					opacity: 0.5,
					cursor: 'default'
				}
			}
		}
	},
	created() {
		let self = this;
		if (this.eventId) {
			this.restRequest(['events', this.eventId].join('/'))
				.then(function(response) {
					self.assignEventData(response.data.data);
					self.assignPollData(null);
					self.checkEventOpen();
					self.loadedSuccessfully = true;
				})
				.finally(function() {
					self.loaded = true;
				});
		} else {
			this.restRequest(['polls', this.pollId].join('/'))
				.then(function(response) {
					self.assignEventData(response.data.data.event);
					self.assignPollData(response.data.data);
					self.checkEventOpen();
					self.loadedSuccessfully = true;
				})
				.finally(function() {
					self.loaded = true;
				});
			this.groupVisibility['participant-group'] = false;
			this.groupVisibility['weekday-ranker-group'] = false;
			this.groupVisibility['calendar-ranker-group'] = true;
		}
	},
	methods: {
		checkEventOpen() {
			if (!this.eventOpen) {
				this.$refs.eventNoLongerOpenModal.show();
			}
		},
		clearSelectedDates() {
			this.selectedDates = null;
		},
		newDate(value) {
			if (this.selectedDateRank && value) {
				this.datePickerAttributes.push( // add current selection to the calendar attributes
					{
						key: ++this.datePickerAttributesKey,
						dates: value,
						bar: {
							backgroundColor: this.selectedDateRankColor
						},
						customData: {
							rank: this.selectedDateRank
						}
					}
				);
			}
			this.clearSelectedDates();
		},
		dayClicked(day) {
			if (!this.selectedDateRank) { // we are deleting dates
				let self = this;
				day.attributes.forEach(attr => {
					let index = self.datePickerAttributes.findIndex(el => el.key == attr.key);
					if (index > -1) {
						self.datePickerAttributes.splice(index, 1);
					}
				});
			}
		},
		assignPollData(poll) {
			this.pollWeekdayRanks = this.initialWeeklyRanks;
			// this is to prevent date ranks that were entered when the event
			// had a larger time window (which was then shrunk by the organizer)
			// to show up
			let excludeDates = [{
				start: null,
				end: dateFns.subDays(this.minDate, 1)
			}, {
				start: dateFns.addDays(this.maxDate, 1),
				end: null
			}];
			if (poll) {
				this.eventIdFromPoll = poll.event_id;
				this.pollParticipant = poll.participant;
				let self = this;
				poll.preferences.weekday_ranks.forEach((rank) => {
					let el = self.pollWeekdayRanks.find((el) => el.day == rank.day);
					if (el) {
						el.rank = rank.rank;
					}
				});
				this.datePickerAttributes = poll.date_ranks.map(date_rank => ({
					key: ++self.datePickerAttributesKey,
					dates: {
						start: date_rank.date_from,
						end: date_rank.date_to
					},
					excludeDates,
					bar: {
						backgroundColor: self.colorForRank(date_rank.rank)
					},
					customData: {
						rank: date_rank.rank
					}
				}));
			}
		},
		savePoll() {
			let self = this;
			this.restRequest(
				(this.pollId ? ['polls', this.pollId].join('/') : ['events', this.eventId, 'polls'].join('/')), {
					method: (this.pollId ? 'put' : 'post'),
					data: {
						poll: this.pollDataForRequest
					}
				}
			).then(function(result) {
				self.collapseAllGroups();
				self.setServerErrors();
				self.$refs.pollSavedModal.show();
				self.wasServerValidated = true;
			}, function(error) {
				if (error.response && error.response.status == 422) {
					self.setServerErrors(error.response.data.errors);
					if (self.eventError) {
						// not really checking for the errror, but so far this is the only possible
						// cause for a global error
						self.$refs.eventNoLongerOpenModal.show();
					}
					self.wasServerValidated = true;
				} else {
					throw error;
				}
			});
		},
		deletePoll() {
			let self = this;
			this.restRequest(['polls', this.pollId].join('/'), {
					method: 'delete'
				})
				.then(function() {
					self.$refs.pollDeletedModal.show();
				}, function(error) {
					self.$refs.pollDeleteErrorModal.show();
					throw error;
				});
		},
		backToEvent() {
			this.$router.push({
				name: 'event',
				params: {
					eventId: this.computedEventId
				}
			});
		},
		colorForRank: (rank) => (rank > 0 ? colorCodes.green : colorCodes.red)
	},
	computed: {
		disabledDates() {
			return this.datePickerAttributes.map(attr => attr.dates);
		},
		selectedDateRankColor() {
			return this.colorForRank(this.selectedDateRank);
		},
		computedEventId() {
			return (this.eventId ? this.eventId : this.eventIdFromPoll);
		},
		initialWeeklyRanks() {
			return Object.keys(this.$i18n.t('week_days')).map((code, index) => ({
				day: index,
				name: `week_days.${code}`,
				rank: 0
			}));
		},
		pollDataForRequest() {
			return {
				participant: this.pollParticipant,
				preferences: {
					weekday_ranks: this.pollWeekdayRanks.filter(weekday_rank => weekday_rank.rank) // exclude 0 ranks
				},
				date_ranks: this.datePickerAttributes.map(attr => ({
					date_from: dateFns.format(attr.dates instanceof Date ? attr.dates : attr.dates.start, 'YYYY-MM-DD'),
					date_to: dateFns.format(attr.dates instanceof Date ? attr.dates : attr.dates.end, 'YYYY-MM-DD'),
					rank: attr.customData.rank
				}))
			}
		}
	}
}
</script>