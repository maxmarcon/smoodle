<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal(ref="copiedToClipboardModal" hide-header ok-only)
			p {{ $t('event_editor.link_copied') }}
		b-modal(ref="eventCreatedModal" hide-header ok-only)
			p {{ $t('event_editor.event_created_short') }}
		b-modal#eventUpdatedModal(ref="eventUpdatedModal" hide-header ok-only :ok-title="$t('event_editor.back_to_event')" @ok="backToEvent")
			p {{ $t('event_editor.event_updated') }}
		.card(v-if="!eventId || loadedSuccessfully || eventCreated")
			.card-header
				event-header#event-header(
					:eventName="eventName"
					:eventOrganizer="eventOrganizer"
					:eventTimeWindowFrom="eventTimeWindowFrom"
					:eventTimeWindowTo="eventTimeWindowTo"
					eventState="OPEN"
				)
			ul.list-group.list-group-flush(v-if="eventCreated")
				li.list-group-item
					.alert.alert-success
						| {{ $t('event_editor.event_created', {eventName, eventOrganizer, eventOrganizerEmail}) }}
				li.list-group-item
					.row.justify-content-center
						label.col-md-auto.col-form-label  {{ $t('event_editor.share_link') }}
						.col-md
							.input-group
								input#shareLink.form-control(:value="eventShareLink" readonly)
								.input-group-append
									a.btn.bdn-sm.btn-outline-secondary(
										target="_blank"
										:href="whatsAppMessageURL(eventShareLink)"
									)
										span.fab.fa-lg.fa-whatsapp
									button.btn.btn-sm.btn-outline-secondary(
										name="share-button"
										v-clipboard:copy="eventShareLink"
										v-clipboard:success="clipboard"
									)
										span.fas.fa-lg.fa-share-alt

			.card-body(v-else)
				.alert.alert-info(v-if="eventId")
					i.fas.fa-edit.fa-lg
					| &nbsp; {{ $t('event_editor.welcome_again', {organizer: eventOrganizer}) }}
				.alert.alert-info(v-else)
					i.fas.fa-calendar-alt.fa-lg
					| &nbsp; {{ $t('event_editor.welcome') }}

				hr.mb-3
				form(ref="form" @submit.prevent="" novalidate)
					b-btn.btn-block.d-flex(
						v-b-toggle.organizer-group=""
						:variant="groupVariant('organizer-group')"
						v-if="!eventId"
					)
						span.fas.fa-chevron-up(v-if="groupVisibility['organizer-group']")
						span.fas.fa-chevron-down(v-else)
						span.ml-2.mr-auto {{ $t('event_editor.organizer_group') }}
						div(v-if="showGroupErrorIcon('organizer-group')").fas.fa-exclamation
						div(v-else-if="showGroupOkIcon('organizer-group')").fas.fa-check
					b-collapse#organizer-group(
						accordion="event-creation"
						v-model="groupVisibility['organizer-group']"
						v-if="!eventId"
					)
						b-card
							.form-group.row
								label.col-md-3.col-form-label(for="eventOrganizer") {{ $t('event_editor.event.organizer') }}
								.col-md-9
									small.form-text.text-muted {{ $t('event_editor.event.organizer_help') }}
									input#eventOrganizer.form-control(
										v-model.trim="eventOrganizer"
										@change="localValidation"
										@blur="localValidation"
										:disabled="eventCreated"
										:class="inputFieldClass('eventOrganizer')"
									)
									.invalid-feedback(name="event-organizer-error") {{ eventOrganizerError }}

							.form-group.row
								label.col-md-3.col-form-label(for="eventOrganizerEmail") {{ $t('event_editor.event.organizer_email') }}
								.col-md-9
									small.form-text.text-muted {{ $t('event_editor.event.organizer_email_help') }}
									input#eventOrganizerEmail.form-control(
										v-model.trim="eventOrganizerEmail"
										@change="localValidation"
										@blur="localValidation"
										:disabled="eventCreated"
										:class="inputFieldClass('eventOrganizerEmail')"
									)
									.invalid-feedback(name="event-organizer-email-error") {{ eventOrganizerEmailError }}

									small.form-text.text-muted {{ $t('event_editor.event.organizer_email_confirmation_help') }}
									input#eventOrganizerEmailConfirmation.form-control(
										v-model.trim="eventOrganizerEmail_confirmation"
										@change="localValidation"
										@blur="localValidation"
										:disabled="eventCreated"
										:class="inputFieldClass('eventOrganizerEmail_confirmation')"
									)
									.invalid-feedback(name="event-organizer-email-confirmation-error") {{ eventOrganizerEmailError_confirmation }}


					b-btn.btn-block.d-flex.mt-2(
						v-b-toggle.general-info-group=""
						:variant="groupVariant('general-info-group')"
					)
						span.fas.fa-chevron-up(v-if="groupVisibility['general-info-group']")
						span.fas.fa-chevron-down(v-else)
						span.ml-2.mr-auto {{ $t('event_editor.general_info_group') }}
						div(v-if="showGroupErrorIcon('general-info-group')").fas.fa-exclamation
						div(v-else-if="showGroupOkIcon('general-info-group')").fas.fa-check
					b-collapse#general-info-group(
						accordion="event-creation"
						v-model="groupVisibility['general-info-group']"
					)
						b-card
							.form-group.row
								label.col-md-3.col-form-label(for="eventName") {{ $t('event_editor.event.name') }}
								.col-md-9
									small.form-text.text-muted {{ $t('event_editor.event.name_help') }}
									input#eventName.form-control(v-model.trim="eventName" type="text"
									:disabled="eventCreated"
									@change="localValidation"
									@blur="localValidation"
									:class="inputFieldClass('eventName')"
									)
									.invalid-feedback(name="event-name-error") {{ eventNameError }}
							.form-group.row
								label.col-md-3.col-form-label(for="eventDesc") {{ $t('event_editor.event.desc') }}
								.col-md-9
									small.form-text.text-muted {{ $t('event_editor.event.desc_help') }}
									textarea#eventDesc.form-control(v-model.trim="eventDesc"
									:disabled="eventCreated"
									@change="localValidation"
									@blur="localValidation"
									:class="inputFieldClass('eventDesc')"
									)
									.invalid-feedback(name="event-desc-error") {{ eventDescError }}


					b-btn.btn-block.d-flex.mt-2(
						v-b-toggle.dates-group=""
						:variant="groupVariant('dates-group')"
					)
						span.fas.fa-chevron-up(v-if="groupVisibility['dates-group']")
						span.fas.fa-chevron-down(v-else)
						span.ml-2.mr-auto {{ $t('event_editor.dates_group') }}
						div(v-if="showGroupErrorIcon('dates-group')").fas.fa-exclamation
						div(v-else-if="showGroupOkIcon('dates-group')").fas.fa-check
					b-collapse#dates-group(
						accordion="event-creation"
						v-model="groupVisibility['dates-group']"
					)
						b-card
							.form-group.row
								label.col.text-center.col-form-label(for="eventTimeWindow") {{ $t('event_editor.event.dates') }}
							.form-group.row.justify-content-center.justify-content-md-between.justify-content-lg-center
								.col-md-6.mb-4.text-center
									v-date-picker#eventTimeWindow(
										mode="range"
										v-model="eventTimeWindow"
										nav-visibility="hidden"
										:min-date="today"
										:is-inline="true"
										:is-double-paned="true"
										:is-linked="true"
										:show-caps="true"
										:attributes="datePickerAttributes"
										popover-visibility="hidden"
										:drag-attribute="dragAndSelectionAttribute"
										:select-attribute="dragAndSelectionAttribute"
										@input="datesSelected"
									)
									.small.text-danger(name="event-time-window-error") {{ eventTimeWindowError }}

								.col-11.col-md-3.offset-md-1
									ranker#eventWeekdays(:elements="eventWeekdays" boolean=true @change="localValidation")
									.small.text-danger(name="event-weekdays-error") {{ eventWeekdaysError }}

			.card-footer
				.row.justify-content-center(v-if="!eventCreated")
					.col-12.col-sm-auto.mt-1
						button.btn.btn-block.btn-primary(@click="saveEvent" :disabled="requestOngoing" name="save-event")
							i.fas(v-bind:class="{'fa-save': eventId, 'fa-plus': !eventId}")
							| &nbsp; {{ $t(eventId ? 'event_editor.update_event' : 'event_editor.create_event') }}
					.col-12.col-sm-auto.mt-1(v-if="eventId")
						button.btn.btn-block.btn-secondary(@click="backToEvent" :disabled="requestOngoing" name="cancel")
							i.fas.fa-ban
							| &nbsp; {{ $t('actions.cancel') }}

				.row.justify-content-center(v-else)
					.col-12.col-sm-auto.mt-1
						router-link.btn.btn-block.btn-success(
							role="button"
							name="manage-event"
							:to="{ name: 'event', params: {eventId: computedEventId, secret: computedSecret}, query: {s: computedSecret}}"
						)
							i.fas.fa-key
							| &nbsp; {{ $t('event_editor.manage_event') }}

		error-page(
			v-else-if="loaded"
			:message="$t('errors.not_found')"
		)
</template>
<script>
import dateFns from 'date-fns'
import {
	accordionGroupsMixin,
	scrollToTopMixin,
	restMixin,
	eventDataMixin,
	whatsAppHelpersMixin,
	colorCodes
} from '../globals'

const today = new Date();
const InvalidDate = 'Invalid Date';

export default {
	mixins: [accordionGroupsMixin, restMixin, scrollToTopMixin, eventDataMixin, whatsAppHelpersMixin],
	props: {
		eventId: String,
		secret: String
	},
	data: () => ({
		errorsMap: {
			// maps, for each input group, the fields in the vue model to
			// the error fields and the error keys received by the back end
			'organizer-group': {
				eventOrganizer: {
					required: true,
					errorField: 'eventOrganizerError',
					errorKeys: 'organizer'
				},
				eventOrganizerEmail: {
					required: true,
					confirmation: true,
					errorField: 'eventOrganizerEmailError',
					errorKeys: 'email'
				},
				eventOrganizerEmail_confirmation: {
					required: true,
					errorField: 'eventOrganizerEmailError_confirmation',
					errorKeys: 'email_confirmation'
				}
			},
			'general-info-group': {
				eventName: {
					required: true,
					errorField: 'eventNameError',
					errorKeys: 'name'
				},
				eventDesc: {
					required: true,
					errorField: 'eventDescError',
					errorKeys: 'desc'
				}
			},
			'dates-group': {
				eventTimeWindow: {
					required: true,
					errorField: 'eventTimeWindowError',
					errorKeys: ['time_window_to', 'time_window_from', 'time_window']
				},
				eventWeekdays: {
					errorField: 'eventWeekdaysError',
					errorKeys: 'preferences.weekdays',
					customValidation: true
				}
			}
		},
		groupVisibility: {
			'general-info-group': false,
			'dates-group': false,
			'organizer-group': true
		},
		eventNameError: null,
		eventOrganizerError: null,
		eventOrganizerEmailError: null,
		eventOrganizerEmailError_confirmation: null,
		eventDescError: null,
		eventTimeWindow: null,
		eventTimeWindowError: null,
		eventWeekdaysError: null,
		today,
		loadedSuccessfully: false,
		loaded: false,
		showThisWeekButton: (dateFns.getDay(today) > 0 && dateFns.getDay(today) < 4), // betewn Mon and Wed
		eventCreated: false,
		createdEventId: null,
		createdEventSecret: null,
		dragAndSelectionAttribute: {
			highlight: {
				backgroundColor: colorCodes.green
			},
			popover: {
				visibility: 'hidden'
			},
			order: 0
		},
	}),
	created() {
		if (this.eventId) {
			if (this.secret) {
				let self = this
				this.restRequest(['events', this.eventId].join('/'), {
					params: {
						secret: this.secret
					}
				}).then(function(result) {
					self.assignEventData(result.data.data)
					self.applyDates(self.eventTimeWindowFrom, self.eventTimeWindowTo)
					self.loadedSuccessfully = true
					self.groupVisibility['dates-group'] = true
				}).finally(function() {
					self.loaded = true
				})
			} else {
				this.loaded = true
			}
		}
	},
	computed: {
		computedEventId() {
			return this.eventId || this.createdEventId
		},
		computedSecret() {
			return this.secret || this.createdEventSecret
		},
		datePickerAttributes() {
			return [{
				dates: {
					start: this.eventTimeWindowFrom,
					end: this.eventTimeWindowTo,
					weekdays: this.eventWeekdays.filter(({
						value
					}) => !value).map(({
						day
					}) => ((day + 1) % 7) + 1) // from 0=Mon...6=Sun to v-calendar's 1=Sun... 7=Sat,
				},
				highlight: {
					animated: true,
					backgroundColor: colorCodes.red,
					opacity: 1
				},
				order: 1
			}]
		},
	},
	methods: {
		customValidate(fieldName, fieldVal) {
			if (fieldName == 'eventWeekdays') {
				if (fieldVal.every(({value}) => !value)) {
					return this.$i18n.t('errors.enable_at_least_one_weekday')
				}
			}
		},
		datesSelected() {
			this.eventTimeWindowFrom = this.eventTimeWindow.start;
			this.eventTimeWindowTo = this.eventTimeWindow.end;
			this.localValidation();
		},
		clipboard() {
			this.$refs.copiedToClipboardModal.show()
		},
		applyDates(from, to) {
			this.eventTimeWindow = {
				start: from,
				end: to
			}
		},
		saveEvent() {
			let self = this;
			let dataForRequest = self.eventDataForRequest;
			if (self.eventId) {
				/// updating, let us not resent email or organizer
				delete dataForRequest['organizer'];
				delete dataForRequest['email'];
			}
			this.restRequest(
				(this.eventId ? ["events", this.eventId].join('/') : "events"), {
					data: {
						event: Object.assign(dataForRequest, {
							secret: this.secret
						})
					},
					method: (this.eventId ? 'patch' : 'post'),
					ignoreErrorCodes: [429]
				}).then(function(result) {
				self.setServerErrors();
				self.collapseAllGroups();
				self.$scrollTo('#event-header');
				self.wasServerValidated = true;

				if (self.eventId) {
					self.$refs.eventUpdatedModal.show();
				} else {
					self.eventCreated = true;
					self.createdEventId = result.data.data.id
					self.createdEventSecret = result.data.data.secret
					self.assignEventData(result.data.data)
					self.$refs.eventCreatedModal.show();
				}
			}, function(error) {
				if (error.response) {
					if (error.response.status == 422) {
						self.setServerErrors(error.response.data.errors);
						self.wasServerValidated = true;
					} else if (error.response.status == 429) {
						self.$refs.errorBar.show(self.$i18n.t('event_editor.too_many_requests_error', {
							email: dataForRequest["email"]
						}));
						self.scrollToTop();
					}
				} else {
					throw error;
				}
			});
		},
		backToEvent() {
			this.$router.push({
				name: 'event',
				params: {
					eventId: this.computedEventId,
					secret: this.computedSecret
				},
				query: {
					s: this.computedSecret
				}
			});
		}
	}
}
</script>

