<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal(ref="pollSavedModal" hide-header ok-only :ok-title="$t('poll_editor.back_to_event')" @hidden="backToEvent")
			p.my-4 {{ $t('poll_editor.poll_saved') }}
		b-modal#pollDeleteModal(
			hide-header
			@ok="deletePoll"
			:ok-title="$t('poll_editor.delete_poll')"
			ok-variant="danger"
		)
			p.my-4 {{ $t('poll_editor.really_delete') }}
		b-modal(ref="pollDeletedModal" hide-header ok-only :ok-title="$t('poll_editor.back_to_event')" @hidden="backToEvent")
			p.my-4 {{ $t('poll_editor.poll_deleted') }}
		.card(v-if="eventName")
			.card-header
				event-header(
					:name="eventName"
					:organizer="eventOrganizer"
					:timeWindowFrom="eventTimeWindowFrom"
					:timeWindowTo="eventTimeWindowTo"
				)
			.card-body
				b-btn.btn-block.d-flex(
						v-b-toggle.organizer-group=""
						:variant="groupVariant('participant-group')"
					)
						span.fas.fa-chevron-down(v-if="groupVisibility['participant-group']")
						span.fas.fa-chevron-up(v-else)
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
									.invalid-feedback {{ pollParticipantError }}


				b-btn#weekday-ranker-button.d-flex.btn-block.mt-2(
					v-b-toggle.weekday-ranker=""
					:variant="groupVariant('weekday-ranker-group')"
				)
					span.fas.fa-chevron-down(v-if="groupVisibility['weekday-ranker-group']")
					span.fas.fa-chevron-up(v-else)
					span.ml-2.mr-auto {{ $t('poll_editor.weekday_ranker_group') }}
					div(v-if="showGroupErrorIcon('weekday-ranker-group')").fas.fa-exclamation
					div(v-else-if="showGroupOkIcon('weekday-ranker-group')").fas.fa-check
				b-collapse#weekday-ranker(
					accordion="poll-editor"
					v-model="groupVisibility['weekday-ranker-group']"
					:visible="true"
				)
					p.small.text-muted.mt-3 {{ $t('poll_editor.weekday_ranker_help') }}
					ranker(:elements="pollWeekdayRanks")

				b-btn#calendar-ranker-button.d-flex.btn-block.mt-2(
					v-b-toggle.calendar-ranker=""
					:variant="groupVariant('calendar-ranker-group')"
				)
					span.fas.fa-chevron-down(v-if="groupVisibility['calendar-ranker-group']")
					span.fas.fa-chevron-up(v-else)
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
							.col-auto
								div
									v-date-picker(
										:mode="(selected_date_rank ? 'range' : 'single')"
										v-model="selected_dates"
										:min-date="minDate"
										:max-date="maxDate"
										:is-inline="true"
										:is-double-paned="true"
										:attributes="date_picker_attributes"
										:tint-color="dateRankColor"
										:is-linked="true"
										:show-caps="true"
										@input="newDate"
										@dayclick="dayClicked"
									)
							.col-auto
								.form-check
									p-radio.p-icon.p-plain(name="selected_date_rank" :value="1" v-model="selected_date_rank" toggle)
										i.icon.fas.fa-heart.text-success(slot="extra")
										i.icon.far.fa-heart(slot="off-extra")
										label(slot="off-label")
								.form-check
									p-radio.p-icon.p-plain(name="selected_date_rank" :value="-1" v-model="selected_date_rank" toggle)
										i.icon.fas.fa-thumbs-down.text-danger(slot="extra")
										i.icon.far.fa-thumbs-down(slot="off-extra")
										label(slot="off-label")
								.form-check
									p-radio.p-icon.p-plain(name="selected_date_rank" :value="0" v-model="selected_date_rank" toggle)
										i.icon.fas.fa-trash-alt(slot="extra")
										i.icon.far.fa-trash-alt(slot="off-extra")
										label(slot="off-label")

					//-v-calendar(
						is-double-paned
						:min-date="eventTimeWindowFrom"
						:max-date="eventTimeWindowTo"
						)

			.card-footer
				.row.justify-content-center
					.col-auto.mt-1
						button.btn.btn-primary(@click="savePoll")
							i.fas.fa-save
							| &nbsp; {{ $t('poll_editor.save_poll') }}
					.col-auto.mt-1(v-if="pollId")
						button.btn.btn-danger(v-b-modal.pollDeleteModal="")
							i.fas.fa-trash-alt
							| &nbsp; {{ $t('poll_editor.delete_poll') }}
					.col-auto.mt-1
						button.btn.btn-secondary(@click="backToEvent")
							i.fas.fa-ban
							| &nbsp; {{ $t('actions.cancel') }}

		error-page(
			v-else-if="loaded"
			:message="$t('errors.not_found')"
		)
</template>
<script>
import { showToolTip, dotAccessObject, accordionGroupsMixin, fetchEventMixin, fetchPollMixin } from '../globals'
import dateFns from 'date-fns'

export default {
	mixins: [accordionGroupsMixin, fetchEventMixin, fetchPollMixin],
	props: {
		eventId: String,
		pollId: String
	},
	data() {
		return {
			errorsMap: {
				// maps, for each input group, the fields in the vue model to
				// the error fields and the error keys received by the back end
				'participant-group': {
					pollParticipant: {
						errorField: 'pollParticipantError',
						errorKeys: 'participant'
					}
				},
				'weekday-ranker-group': {
					pollWeekdayRanks: {
						errorField: 'pollWeekdayRanksError',
						errorKeys: 'preferences.weekday_ranks'
					}
				}
			},
			groupVisibility: {
				'participant-group': true,
				'weekday-ranker-group': false,
				'calendar-ranker-group': false
			},
			showToolTip,
			eventName: null,
			eventOrganizer: null,
			evendDesc: null,
			eventTimeWindowFrom: null,
			eventTimeWindowTo: null,
			pollWeekdayRanks: null,
			pollParticipant: null,
			pollParticipantError: null,
			loaded: false,
			selected_dates: null,
			selected_date_rank: 1,
			date_picker_attributes: [],
			date_picker_attributes_key: 0
		}
	},
	created() {
		let self = this;
		if (this.eventId) {
			this.fetchEvent(this.eventId).then(function(event) {
				if (event) {
					self.assignEventData(event);
					self.assignPollData(null);
				}
				self.loaded = true;
			});
		} else {
			this.fetchPoll(this.pollId).then(function(poll) {
				if (poll) {
					self.assignEventData(poll.event);
					self.assignPollData(poll);
				}
				self.loaded = true;
			});
			this.groupVisibility['participant-group'] = false;
			this.groupVisibility['weekday-ranker-group'] = false;
			this.groupVisibility['calendar-ranker-group'] = true;
		}
	},
	methods: {
		newDate(value) {
			if (this.selected_date_rank) {
				this.date_picker_attributes_key += 1;
				this.date_picker_attributes.push( // add current selection to the calendar attributes
					{
						key: this.date_picker_attributes_key,
						dates: value,
						bar: { backgroundColor: this.dateRankColor },
						popover: {
							label: `date ${this.date_picker_attributes_key}`
						}
					}
				);
			}
			this.selected_dates = null; // disable current selection
		},
		dayClicked(day) {
			if (!this.selected_date_rank) {
				let self = this;
				day.attributes.forEach(attr => {
					let index = self.date_picker_attributes.findIndex(el => el.key == attr.key);
					if (index > -1) {
						self.date_picker_attributes.splice(index, 1);
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
		},
		assignPollData(poll) {
			this.pollWeekdayRanks = this.initialWeeklyRanks;
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
			}
		},
		savePoll() {
			let self = this;
			this.$http.request({
				method: (this.pollId ? 'put' : 'post'),
				url: (this.pollId ? '/v1/polls/' + this.pollId : '/v1/events/' + this.eventId + '/polls'),
				data: {
					poll: this.pollData
				},
				headers: { 'Accept-Language': this.$i18n.locale }
			})
			.then(function(result) {
				self.setServerErrors();
				self.collapseAllGroups();
				self.$refs.pollSavedModal.show();
			}, function(result) {
				if (result.response && result.response.status == 422) {
					self.setServerErrors(result.response.data.errors);
				} else {
					self.$refs.errorBar.show(self.$i18n.t('errors.network'));
				}
			})
			.finally(function() {
				self.wasServerValidated = true;
			});
		},
		deletePoll() {
			let self = this;
			this.$http.delete('/v1/polls/' + this.pollId)
			.then(function() {
				self.$refs.pollDeletedModal.show();
			}, function() {
				self.$refs.errorBar.show(self.$i18n.t('errors.network'));
			});
		},
		backToEvent() {
			this.$router.push({name: 'event', params: {eventId: this.computedEventId}});
		}
	},
	computed: {
		dateRankColor() {
			return (this.selected_date_rank > 0 ? '#28a745' : '#dc3545');
		},
		minDate() {
			return dateFns.parse(this.eventTimeWindowFrom);
		},
		maxDate() {
			return dateFns.parse(this.eventTimeWindowTo);
		},
		computedEventId() {
			return (this.eventId ? this.eventId : this.eventIdFromPoll);
		},
		initialWeeklyRanks() {
			return this.$i18n.t('week_days').map((day, index) => ({day: index, name: day, rank: 0}));
		},
		pollData() {
			return {
				participant: this.pollParticipant,
				preferences: {
					weekday_ranks: this.pollWeekdayRanks.filter(weekday_rank => weekday_rank.rank) // exclude 0 ranks
				}
			}
		}
	}
}
</script>