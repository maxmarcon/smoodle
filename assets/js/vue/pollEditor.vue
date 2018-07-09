<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal(ref="welcomeModal" hide-header ok-only)
				p.my-3 {{ $t('poll_editor.welcome', {eventName, eventOrganizer}) }}
		b-modal(ref="pollSavedModal" hide-header ok-only)
			p.my-4 {{ $t('poll_editor.poll_saved') }}
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
					span.ml-2.mr-auto {{ $t('poll_editor.weekday_ranks_group') }}
					div(v-if="showGroupErrorIcon('weekday-ranker-group')").fas.fa-exclamation
					div(v-else-if="showGroupOkIcon('weekday-ranker-group')").fas.fa-check
				b-tooltip(
					target="weekday-ranker-button"
					triggers=""
					:title="$t('poll_editor.weekday_ranks_help')"
					:show="groupVisibility['weekday-ranker-group'] && showToolTip('weekday-ranker')"
				)
				b-collapse#weekday-ranker(
					accordion="poll-editor"
					v-model="groupVisibility['weekday-ranker-group']"
					:visible="true"
				)
					.invalid-feedback {{ pollWeekdayRanksError }}
					ranker(:elements="pollWeekdayRanks")

			.card-footer.text-center
				button.btn.btn-primary(@click="saveEvent") {{ $t('poll_editor.save_poll') }}

</template>
<script>
import dateFns from 'date-fns'
import { showToolTip, dotAccessObject, formWithErrorsMixin, fetchEventMixin } from '../globals'

export default {
	mixins: [formWithErrorsMixin, fetchEventMixin],
	props: {
		eventId: {
			type: String,
			required: true
		},
		pollId: {
			type: String
		}
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
				'weekday-ranker-group': false
			},
			showToolTip,
			eventName: null,
			eventOrganizer: null,
			evendDesc: null,
			eventTimeWindowFrom: null,
			eventTimeWindowTo: null,
			wasServerValidated: false,
			wasLocalValidated: false,
			pollWeekdayRanks: this.$i18n.t('date_picker.days').map((day, index) => ({day: index, name: day, rank: 0})),
			pollParticipant: null,
			pollParticipantError: null
		}
	},
	created() {
		let self = this;
		this.fetchEvent(this.eventId).then(function(eventData) {
			if (eventData) {
				self.eventName = eventData.name;
				self.eventOrganizer = eventData.organizer;
				self.eventDesc = eventData.desc;
				self.eventTimeWindowFrom = eventData.time_window_from;
				self.eventTimeWindowTo = eventData.time_window_to;
				//self.$refs.welcomeModal.show();
			}
		});

		if (this.pollId) {
			console.log("we should fetch an existing poll here");
		}
	},
	methods: {
		saveEvent() {
			let self = this;
			this.$http.post("/v1/events/" + this.eventId + "/polls", {
				poll: self.pollData
			}, {
				headers: { 'Accept-Language': this.$i18n.locale }
			})
			.then(function(result) {
				self.setServerErrors();
				self.poll = result.data.data;
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
		}
	},
	computed: {
		pollData() {
			return {
				participant: this.pollParticipant,
				preferences: {
					weekday_ranks: this.pollWeekdayRanks.filter(weekday_rank => weekday_rank.rank) // exclude 0 ranks
				}
			}
		},
		timeWindow() {
			return dateFns.format(this.eventTimeWindowFrom, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')})
			 + " - " +
			 dateFns.format(this.eventTimeWindowTo, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')});
		}
	}
}
</script>