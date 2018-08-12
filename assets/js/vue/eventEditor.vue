<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal(ref="copiedToClipboardModal" hide-header ok-only)
			p.my-4 {{ $t('event_editor.link_copied') }}
		b-modal(ref="eventCreatedModal" hide-header ok-only)
			p.my-4 {{ $t('event_editor.event_created_short') }}
		.card
			.card-header
				event-header(
					:name="eventName"
					:organizer="eventOrganizer"
					:timeWindowFrom="eventTimeWindowFrom"
					:timeWindowTo="eventTimeWindowTo"
				)
			.card-body
				ul.list-group.list-group-flush(v-if="createdEvent")
					li.list-group-item
						.alert.alert-success
							| {{ $t('event_editor.event_created', {eventName: createdEvent.name, eventOrganizer: createdEvent.organizer, organizerEmail: createdEvent.email}) }}
					li.list-group-item
						.alert.alert-info {{ $t('event_editor.share_link') }}
						.row.justify-content-center
							.col-md-8
								.input-group.border.border-success
									input.form-control(:value="createdEvent.share_link" readonly @success="clipboard")
									.input-group-append
										button.btn.btn-sm.btn-outline-secondary(
											v-clipboard:copy="createdEvent.share_link"
											v-clipboard:success="clipboard"
										)
											span.fas.fa-clipboard

				div(v-else)
					.alert.alert-info
						i.fas.fa-calendar-alt.fa-lg
						| &nbsp; {{ $t('event_editor.welcome') }}

					hr.mb-3
					form(ref="form" @submit.prevent="" novalidate)
						b-btn.btn-block.d-flex(
							v-b-toggle.organizer-group=""
							:variant="groupVariant('organizer-group')"
						)
							span.fas.fa-chevron-down(v-if="groupVisibility['organizer-group']")
							span.fas.fa-chevron-up(v-else)
							span.ml-2.mr-auto {{ $t('event_editor.organizer_group') }}
							div(v-if="showGroupErrorIcon('organizer-group')").fas.fa-exclamation
							div(v-else-if="showGroupOkIcon('organizer-group')").fas.fa-check
						b-collapse#organizer-group(accordion="event-creation" v-model="groupVisibility['organizer-group']")
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
									label.col-md-3.col-form-label(for="organizerEmail") {{ $t('event_editor.event.organizer_email') }}
									.col-md-9
										small.form-text.text-muted {{ $t('event_editor.event.organizer_email_help') }}
										input#organizerEmail.form-control(
											v-model.trim="organizerEmail"
											@change="localValidation"
											@blur="localValidation"
											:disabled="createdEvent"
											:class="inputFieldClass('organizerEmail')"
										)
										.invalid-feedback {{ organizerEmailError }}

						b-btn.btn-block.d-flex.mt-2(
							v-b-toggle.general-info-group=""
							:variant="groupVariant('general-info-group')"
						)
							span.fas.fa-chevron-down(v-if="groupVisibility['general-info-group']")
							span.fas.fa-chevron-up(v-else)
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
							span.fas.fa-chevron-down(v-if="groupVisibility['dates-group']")
							span.fas.fa-chevron-up(v-else)
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
											v-model="eventTimeWindow"
											:min-date="today"
											:input-props="{readonly: true, placeholder: $t('event_editor.dates_placeholder'), class: [ 'form-control', inputFieldClass('eventTimeWindow') ]}"
											:is-double-paned="true"
											popover-visibility="focus"
											@input="localValidation"
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
						button.btn.btn-primary(@click="createEvent")
							i.fas.fa-plus
							| &nbsp; {{ $t('event_editor.create_event') }}

				.row.justify-content-center(v-else)
					.col-auto.mt-1
						router-link.btn.btn-success(
							role="button"
							:to="{ name: 'poll', params: {eventId: createdEvent.id}}"
						)
							i.fas.fa-question
							| &nbsp; {{ $t('event_editor.poll_event') }}

</template>

<script>
import dateFns from 'date-fns'
import { accordionGroupsMixin } from '../globals'

const today = new Date();
const InvalidDate = 'Invalid Date';

export default {
	mixins: [accordionGroupsMixin],
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
				organizerEmail: {
					required: true,
					errorField: 'organizerEmailError',
					errorKeys: 'email'
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
		eventName: null,
		eventNameError: null,
		eventOrganizer: null,
		eventOrganizerError: null,
		organizerEmail: null,
		organizerEmailError: null,
		eventDesc: null,
		eventDescError: null,
		eventTimeWindow: null,
		eventTimeWindowError: null,
		today,
		showThisWeekButton: (dateFns.getDay(today) > 0 && dateFns.getDay(today) < 4), // betewn Mon and Wed
		createdEvent: null /*{
						id: 'd8763187-ed3d-4572-ae50-02d5cc874804',
						name: "Dinner party",
						organizer: "Max",
						share_link: "http://localhost:4000/event/967d9e9b-ad9f-4312-863f-c760a52db4e2",
						owner_link: "http://share"
					}*/
 	}),
	computed: {
		eventTimeWindowFrom() {
			return this.eventTimeWindow && this.eventTimeWindow.start;
		},
		eventTimeWindowTo() {
			return this.eventTimeWindow && this.eventTimeWindow.end;
		},
		eventData() {
			return {
				name: this.eventName,
				desc: this.eventDesc,
				organizer: this.eventOrganizer,
				time_window_from: dateFns.format(this.eventTimeWindowFrom, 'YYYY-MM-DD'),
				time_window_to: dateFns.format(this.eventTimeWindowTo, 'YYYY-MM-DD'),
				email: this.organizerEmail
			};
		}
	},
	methods: {
		clipboard(e) {
      this.$refs.copiedToClipboardModal.show();
		},
		applyDates(from, to) {
			this.eventTimeWindow = {
				start: from,
				end: to
			};
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
		createEvent() {
			let self = this;
			this.$http.post("/v1/events", {
				event: self.eventData
			}, {
				headers: { 'Accept-Language': this.$i18n.locale }
			})
			.then(function(result) {
				self.setServerErrors();
				self.createdEvent = result.data.data;
				self.collapseAllGroups();
				self.$refs.eventCreatedModal.show();
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
	}
}
</script>

