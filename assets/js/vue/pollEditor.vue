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
import { showToolTip, dotAccessObject } from '../globals'

const errorsMap = {
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
};


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
	data() {
		return {
			showToolTip,
			eventName: null,
			eventOrganizer: null,
			evendDesc: null,
			eventTimeWindowFrom: null,
			eventTimeWindowTo: null,
			wasServerValidated: false,
			wasLocalValidated: false,
			groupVisibility: {
				'participant-group': true,
				'weekday-ranker-group': false
			},
			pollWeekdayRanks: this.$i18n.t('date_picker.days').map((day, index) => ({day: index, name: day, rank: 0})),
			pollParticipant: null,
			pollParticipantError: null
		}
	},
	created() {
		let self = this;
		fetchEvent.call(this).then(function(eventData) {
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
		},
		inputFieldClass(field) {
			let fieldMap = Object.values(errorsMap).find(map => map[field]);
			if (fieldMap) {
				let errorField = fieldMap[field].errorField;
				if (this[errorField]) {
					return 'is-invalid';
				} else if (this.wasServerValidated || this.wasLocalValidated) {
					return 'is-valid';
				}
			}
		},
		localValidation() {
			self = this;
			Object.values(errorsMap).forEach(function(fieldMap) {
				for (let field in fieldMap) {
					let errorField = fieldMap[field].errorField;
					if (!self[field]) {
						self[errorField] = self.$i18n.t('errors.required_field')
					}
				}
			});
			this.wasLocalValidated = true;
		},
		collapseAllGroups() {
			for (let group in this.groupVisibility) {
				this.groupVisibility[group] = false;
			}
		},
		showGroupOkIcon(group) {
			return this.wasServerValidated && !this.groupHasErrors(group);
		},
		showGroupErrorIcon(group) {
			return this.wasServerValidated && this.groupHasErrors(group);
		},
		groupVariant(group) {
			if (this.wasServerValidated) {
				return (this.groupHasErrors(group) ? 'danger' : 'success');
			}
		},
		setServerErrors(errors={}) {
			let groupShownBecauseOfErrors = null;
			for (let group in errorsMap) {
				let fieldMap = errorsMap[group];
				for (let field in fieldMap) {
					let errorKeys = fieldMap[field].errorKeys;
					let errorField = fieldMap[field].errorField;
					errorKeys = errorKeys instanceof Array ? errorKeys : [errorKeys];
					let key_with_error = errorKeys.find(key => dotAccessObject(errors, key));
					this[errorField] = (key_with_error ? dotAccessObject(errors, key_with_error).join(', ') : null);
					if (key_with_error && !groupShownBecauseOfErrors) {
						this.groupVisibility[group] = true;
						groupShownBecauseOfErrors = group;
					}
				}
			}
		},
		groupHasErrors(group) {
			let groupErrorsMap = errorsMap[group] || {}
			for (let field in groupErrorsMap) {
				if (this[groupErrorsMap[field].errorField]) {
					return true;
				}
			}
			return false;
		},
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