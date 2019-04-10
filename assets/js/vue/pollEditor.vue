<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal#pollSavedModal(ref="pollSavedModal" hide-header ok-only :ok-title="$t('poll_editor.back_to_event')" @hidden="backToEvent")
			p {{ $t('poll_editor.poll_saved') }}

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

		b-modal#eventErrorModal(ref="eventErrorModal"
			hide-header
			:ok-title="$t('poll_editor.back_to_event')"
			ok-only
			no-close-on-esc
			no-close-on-backdrop
			@ok="backToEvent"
		)
			p {{ eventError }}

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
				.alert.alert-danger(v-if="emptyDomain")
								i.fas.fa-exclamation-triangle
								| &nbsp; {{ $t('event_viewer.empty_domain') }}
				div(v-else)
					div(v-if="eventId")
						//- if we have an eventId, we are creating a new poll and not editing an existing one
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
							.form-group.row
								.col.text-center.text-justify
									i18n.small.text-muted(path="poll_editor.date_ranker_helper" tag="p")
										i.fas.fa-heart.text-success(place="good")
										i.fas.fa-thumbs-down.text-danger(place="bad")
										i.fas.fa-circle.text-warning(place="indifferent")

							.form-group.row.justify-content-center.justify-content-md-between.justify-content-lg-center
								.col-md-6.mb-4.text-center
									v-date-picker#pollDateRanks(
										mode="single"
										v-model="datesSelection"
										nav-visibility="hidden"
										:is-inline="true"
										:is-required="true"
										:is-double-paned="differentMonths"
										:attributes="datePickerAttributes"
										:is-linked="true"
										:from-page="fromPage"
										:min-page="fromPage"
										:max-page="toPage"
										:show-caps="true"
										popover-visibility="hidden"
										:disabled-attribute="disabledAttribute"
										:select-attribute="selectAttribute"
										:available-dates="eventDomain"
										@input="newDate"
									)
									.small.text-danger {{ pollDateRanksError }}

									.d-flex.mt-2.justify-content-center.align-items-end(@click="cleardatesSelection")
											.form-check
												p-radio.p-icon.p-plain(name="selectedDateRank" :value="1" v-model="selectedDateRank" toggle)
													i.icon.fas.fa-thumbs-up.text-success(slot="extra")
													i.icon.far.fa-thumbs-up(slot="off-extra")
													label(slot="off-label")
											.form-check
												p-radio.p-icon.p-plain(name="selectedDateRank" :value="-1" v-model="selectedDateRank" toggle)
													i.icon.fas.fa-thumbs-down.text-danger(slot="extra")
													i.icon.far.fa-thumbs-down(slot="off-extra")
													label(slot="off-label")
											.form-check
												p-radio.p-icon.p-plain(name="selectedDateRank" :value="0" v-model="selectedDateRank" toggle)
													i.icon.fas.fa-circle.text-warning(slot="extra")
													i.icon.far.fa-circle(slot="off-extra")
													label(slot="off-label")

								.col-11.col-md-3.offset-md-1
									ranker#pollWeekdayRanks(:elements="pollWeekdayRanks")
									.small.text-danger {{ pollWeekdayRanksError }}


			.card-footer
				.row.justify-content-center
					.col-12.col-sm-auto.mt-1(v-if="eventOpen && !emptyDomain")
						button.btn.btn-block.btn-primary(name="save-poll" @click="savePoll" :disabled="requestOngoing")
							i.fas.fa-save
							| &nbsp; {{ $t('poll_editor.save_poll') }}
					.col-12.col-sm-auto.mt-1(v-if="pollId && eventOpen && !emptyDomain")
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
	pollDataMixin,
	colorCodes,
	eventHelpersMixin,
	eventDataMixin,
	scrollToTopMixin
} from '../globals'
import dateFns from 'date-fns'

export default {
	mixins: [accordionGroupsMixin, pollDataMixin, restMixin, scrollToTopMixin, eventHelpersMixin, eventDataMixin],
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
				'calendar-ranker-group': {
					pollDateRanks: {
						errorField: 'pollDateRanksError',
						errorKeys: 'date_ranks'
					},
					pollWeekdayRanks: {
						errorField: 'pollWeekdayRanksError',
						errorKeys: 'preferences.weekday_ranks'
					}
				}
			},
			groupVisibility: {
				'participant-group': true,
				'calendar-ranker-group': false
			},
			eventError: null,
			pollParticipantError: null,
			pollWeekdayRanksError: null,
			pollDateRanksError: null,
			requestOngoing: false,
			loaded: false,
			loadedSuccessfully: false,
			datesSelection: null,
			selectedDateRank: 1,
			disabledAttribute: {
				contentStyle: {
					color: colorCodes.red,
					opacity: 0.5,
					cursor: 'default'
				},
				order: 0
			}
		}
	},
	created() {
		let self = this;
		if (this.eventId) {
			this.restRequest(['events', this.eventId].join('/'))
				.then(function(response) {
					self.assignEventData(response.data.data)
					self.assignPollData({}, self.eventWeekdays)
					self.checkEventValid()
					self.loadedSuccessfully = true
				})
				.finally(function() {
					self.loaded = true
				});
		} else {
			this.restRequest(['polls', this.pollId].join('/'))
				.then(function(response) {
					self.assignEventData(response.data.data.event)
					self.assignPollData(response.data.data, self.eventWeekdays)
					self.eventIdFromPoll = response.data.data.event_id
					self.checkEventValid()
					self.loadedSuccessfully = true
					self.groupVisibility['calendar-ranker-group'] = true
				})
				.finally(function() {
					self.loaded = true
				});
		}
	},
	methods: {
		checkEventValid() {
			if (!this.eventOpen || this.emptyDomain) {
				this.eventError = this.$i18n.t('poll_editor.event_invalid')
				this.$refs.eventErrorModal.show();
			}
		},
		cleardatesSelection() {
			this.datesSelection = null;
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
						self.$refs.eventErrorModal.show();
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
		colorForRank: (rank) => (rank > 0 ? colorCodes.green : (rank < 0 ? colorCodes.red : colorCodes.yellow)),
		newDate(value) {
			if (value && this.eventDomain.length > 0) {
				let new_key = this.datesKey(value)
				let toReplace = this.pollDateRanks.findIndex(({
					key
				}) => key == new_key)

				if (this.selectedDateRank) {
					this.pollDateRanks.splice(toReplace, (toReplace < 0 ? 0 : 1), {
						date: value,
						key: new_key,
						rank: this.selectedDateRank
					})
				} else if (toReplace >= 0) {
					this.pollDateRanks.splice(toReplace, 1)
				}
			}
		}
	},
	computed: {
		datePickerAttributes() {
			return this.eventDomain.map(date => {
				let dateRank = this.pollDateRanks.find(({
					date: rank_date
				}) => dateFns.isEqual(date, rank_date))

				if (dateRank) {
					return {
						key: dateRank.key,
						dates: date,
						highlight: {
							backgroundColor: this.colorForRank(dateRank.rank)
						}
					}
				}

				let weekdayRank = this.pollWeekdayRanks.find(({
					day
				}) => ((day + 1) % 7) == dateFns.getDay(date))

				if (weekdayRank) {
					return {
						dates: date,
						highlight: {
							animated: true,
							backgroundColor: this.colorForRank(weekdayRank.value),
							opacity: 1
						}
					}
				}

				return {
					dates: date,
					highlight: {
						animated: true,
						backgroundColor: this.colorForRank(0),
						opacity: 1
					}
				}
			})
		},
		selectedDateRankColor() {
			return this.colorForRank(this.selectedDateRank);
		},
		selectAttribute() {
			return {
				highlight: {
					backgroundColor: this.selectedDateRankColor
				},
				popover: {
					visibility: 'hidden'
				}
			}
		},
		computedEventId() {
			return this.eventId || this.eventIdFromPoll;
		}
	}
}
</script>