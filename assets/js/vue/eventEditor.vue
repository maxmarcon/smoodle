<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal(ref="copiedToClipboardModal" hide-header ok-only)
			p {{ $t('event_editor.link_copied') }}
		b-modal(ref="eventCreatedModal" hide-header ok-only)
			p {{ $t('event_editor.event_created_short') }}
		b-modal(ref="eventUpdatedModal" hide-header ok-only :ok-title="$t('event_editor.back_to_event')" @ok="backToEvent")
			p {{ $t('event_editor.event_updated') }}
		.card(v-if="!eventId || loadedSuccessfully")
			.card-header
				event-header#event-header(
					:eventName="eventName"
					:eventOrganizer="eventOrganizer"
					:eventTimeWindowFrom="eventTimeWindowFrom"
					:eventTimeWindowTo="eventTimeWindowTo"
					eventState="OPEN"
				)
			ul.list-group.list-group-flush(v-if="createdEvent")
				li.list-group-item
					.alert.alert-success
						| {{ $t('event_editor.event_created', {eventName: createdEvent.name, eventOrganizer: createdEvent.organizer, organizerEmail: createdEvent.email}) }}
				li.list-group-item
					.row.justify-content-center
						label.col-md-auto.col-form-label  {{ $t('event_editor.share_link') }}
						.col-md
							.input-group
								input.form-control(:value="createdEvent.share_link" readonly)
								.input-group-append
									button.btn.btn-sm.btn-outline-secondary(
										v-clipboard:copy="createdEvent.share_link"
										v-clipboard:success="clipboard"
									)
										span.fas.fa-share-alt

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
										:disabled="createdEvent"
										:class="inputFieldClass('eventOrganizer')"
									)
									.invalid-feedback {{ eventOrganizerError }}

							.form-group.row
								label.col-md-3.col-form-label(for="eventOrganizerEmail") {{ $t('event_editor.event.organizer_email') }}
								.col-md-9
									small.form-text.text-muted {{ $t('event_editor.event.organizer_email_help') }}
									input#eventOrganizerEmail.form-control(
										v-model.trim="eventOrganizerEmail"
										@change="localValidation"
										@blur="localValidation"
										:disabled="createdEvent"
										:class="inputFieldClass('eventOrganizerEmail')"
									)
									.invalid-feedback {{ eventOrganizerEmailError }}

									small.form-text.text-muted {{ $t('event_editor.event.organizer_email_confirmation_help') }}
									input#eventOrganizerEmailConfirmation.form-control(
										v-model.trim="eventOrganizerEmail_confirmation"
										@change="localValidation"
										@blur="localValidation"
										:disabled="createdEvent"
										:class="inputFieldClass('eventOrganizerEmail_confirmation')"
									)
									.invalid-feedback {{ eventOrganizerEmailError_confirmation }}


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
									:disabled="createdEvent"
									@change="localValidation"
									@blur="localValidation"
									:class="inputFieldClass('eventName')"
									)
									.invalid-feedback {{ eventNameError }}
							.form-group.row
								label.col-md-3.col-form-label(for="eventDesc") {{ $t('event_editor.event.desc') }}
								.col-md-9
									small.form-text.text-muted {{ $t('event_editor.event.desc_help') }}
									textarea#eventDesc.form-control(v-model.trim="eventDesc"
									:disabled="createdEvent"
									@change="localValidation"
									@blur="localValidation"
									:class="inputFieldClass('eventDesc')"
									)
									.invalid-feedback {{ eventDescError }}


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
								label.col-md-4.col-form-label(for="eventTimeWindow") {{ $t('event_editor.event.dates') }}
								.col-md-4.mb-3
									v-date-picker#eventTimeWindow(
										mode="range"
										:is-linked="true"
										v-model="eventTimeWindow"
										nav-visibility="hidden"
										:min-date="today"
										:input-props="{readonly: true, placeholder: $t('event_editor.dates_placeholder'), class: [ 'form-control', inputFieldClass('eventTimeWindow') ]}"
										:is-double-paned="true"
										:show-caps="true"
										popover-visibility="focus"
										@input="datesSelected"
									)
									//- invalid feedback won't work here because v-date-picker is not a form-control
									.small.text-danger {{ eventTimeWindowError }}

								.col-md-auto
									b-dropdown(:text="$t('event_editor.dates_quick_selection')" :disabled="createdEvent != null")
										b-dropdown-item(v-if="showThisWeekButton" @click="pickThisWeek") {{ $t('event_editor.this_week') }}
										b-dropdown-item(@click="pickNextWeek(); localValidation();") {{ $t('event_editor.next_week') }}
										b-dropdown-item(@click="pickNextMonths(1); localValidation();") {{ $tc('event_editor.within_months') }}
										b-dropdown-item(@click="pickNextMonths(3); localValidation();") {{ $tc('event_editor.within_months', 3, {count: 3}) }}

			.card-footer
				.row.justify-content-center(v-if="!createdEvent")
					.col-auto
						button.btn.btn-primary(v-if="!eventId" @click="saveEvent" :disabled="requestOngoing")
							i.fas.fa-plus
							| &nbsp; {{ $t('event_editor.create_event') }}
						button.btn.btn-primary(v-else @click="saveEvent" :disabled="requestOngoing")
							i.fas.fa-save
							| &nbsp; {{ $t('event_editor.update_event') }}
					.col-auto(v-if="eventId")
						button.btn.btn-secondary(@click="backToEvent" :disabled="requestOngoing")
							i.fas.fa-ban
							| &nbsp; {{ $t('actions.cancel') }}

				.row.justify-content-center(v-else)
					.col-auto.mt-1
						router-link.btn.btn-success(
							role="button"
							:to="{ name: 'event', params: {eventId: createdEvent.id, secret: createdEvent.secret}}"
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
import { accordionGroupsMixin, scrollToTopMixin, restMixin, eventDataMixin } from '../globals'

const today = new Date();
const InvalidDate = 'Invalid Date';

export default {
	mixins: [accordionGroupsMixin, restMixin, scrollToTopMixin, eventDataMixin],
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
				}
			}
		},
		groupVisibility: {
			'general-info-group': false,
			'dates-group': false,
			'organizer-group': true
		},
		eventError: null,
		eventName: null,
		eventNameError: null,
		eventOrganizer: null,
		eventOrganizerError: null,
		eventOrganizerEmail: null,
		eventOrganizerEmailError: null,
		eventOrganizerEmail_confirmation: null,
		eventOrganizerEmailError_confirmation: null,
		eventDesc: null,
		eventDescError: null,
		eventTimeWindow: null,
		eventTimeWindowError: null,
		requestOngoing: false,
		today,
		loadedSuccessfully: false,
		loaded: false,
		showThisWeekButton: (dateFns.getDay(today) > 0 && dateFns.getDay(today) < 4), // betewn Mon and Wed
		createdEvent: null/*{
						id: 'd8763187-ed3d-4572-ae50-02d5cc874804',
						name: "Dinner party",
						organizer: "Max",
						share_link: "http://localhost:4000/event/967d9e9b-ad9f-4312-863f-c760a52db4e2",
						owner_link: "http://share",
						secret: "dasdas",
						email: 'noname@nodomain.com'
					}*/
 	}),
 	created() {
 		if (this.eventId) {
 			if (this.secret) {
	 			let self = this;
		 		this.restRequest(['events', this.eventId].join('/'), { params: {secret: this.secret} }).then(function(result) {
					self.assignEventData(result.data.data);
					self.applyDates(self.eventTimeWindowFrom, self.eventTimeWindowTo, true);
					self.loadedSuccessfully = true;
				}).finally(function() { self.loaded = true; })
			} else {
				this.loaded = true;
			}
		}
 	},
	methods: {
		datesSelected() {
			this.eventTimeWindowFrom = this.eventTimeWindow.start;
			this.eventTimeWindowTo = this.eventTimeWindow.end;
			this.localValidation();
		},
		clipboard() {
      this.$refs.copiedToClipboardModal.show();
		},
		applyDates(from, to, skipDatesSelected = false) {
			this.eventTimeWindow = {
				start: from,
				end: to
			};
			if (!skipDatesSelected) {
				this.datesSelected();
			}
		},
		pickThisWeek() {
			this.applyDates(
				dateFns.max(today, dateFns.startOfWeek(today, {weekStartsOn: 1})),
				dateFns.endOfWeek(today, {weekStartsOn: 1})
			);
		},
		pickNextWeek() {
			let today_next_week = dateFns.addWeeks(today, 1);
			this.applyDates(
				dateFns.startOfWeek(today_next_week, {weekStartsOn: 1}),
				dateFns.endOfWeek(today_next_week, {weekStartsOn: 1})
			);
		},
		pickNextMonths(months) {
			this.applyDates(today, dateFns.addMonths(today,months));
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
				(this.eventId ? ["events", this.eventId].join('/') : "events"),
				{
					data: {
						event: Object.assign(dataForRequest, {secret: this.secret})
					},
					method: (this.eventId ? 'patch' : 'post'),
					errorCodeMessages: {
						429: this.$i18n.t('event_editor.too_many_requests_error', {email: dataForRequest['email']})
					}
			}).then(function(result) {
				self.setServerErrors();
				self.collapseAllGroups();
				self.$scrollTo('#event-header');
				self.wasServerValidated = true;
				if (self.eventId) {
					self.$refs.eventUpdatedModal.show();
				} else {
					self.createdEvent = result.data.data;
					self.$refs.eventCreatedModal.show();
				}
			}, function(error) {
				if (error.response && error.response.status == 422) {
					self.setServerErrors(error.response.data.errors);
					self.wasServerValidated = true;
				} else {
					throw error;
				}
			});
		},
		backToEvent() {
			this.$router.push({name: 'event', params: {eventId: this.eventId, secret: this.secret}});
		}
	}
}
</script>

