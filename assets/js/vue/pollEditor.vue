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


				b-btn#weekday-ranker-button.d-flex.btn-block.mt-2(v-b-toggle.weekday-ranker="")
					span.fas.fa-chevron-down(v-if="groupVisibility['weekday-ranker-group']")
					span.fas.fa-chevron-up(v-else)
					span.ml-2
					| {{ $t('poll_editor.weekday_ranks_group') }}
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
					ranker(:elements="$t('date_picker.days').map((day, index) => ({name: day, rank: 0}))")

			.card-footer

</template>
<script>
import dateFns from 'date-fns'
import { showToolTip } from '../globals'

const errorsMap = {
	// maps, for each input group, the fields in the vue model to
	// the error fields and the error keys received by the back end
	'participant-group': {
		pollParticipant: {
			errorField: 'pollParticipantError',
			errorKeys: 'participant'
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
	data: () => ({
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
				//self.$refs.welcomeModal.show();
			}
		});

		if (this.pollId) {
			console.log("we should fetch an existing poll here");
		}
	},
	methods: {
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
					self[errorField] = !self[field] ? self.$i18n.t('errors.required_field') : null;
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
		timeWindow() {
			return dateFns.format(this.eventTimeWindowFrom, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')})
			 + " - " +
			 dateFns.format(this.eventTimeWindowTo, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')});
		}
	}
}
</script>