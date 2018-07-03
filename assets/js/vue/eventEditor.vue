<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		b-modal(ref="copiedToClipboardModal" hide-header ok-only)
			p.my-4 {{ $t('event_editor.link_copied') }}
		b-modal(ref="eventCreatedModal" hide-header ok-only)
			p.my-4 {{ $t('event_editor.event_created_short') }}
		.card
			.card-header.d-flex(:class="{'bg-success': createdEvent, 'text-white': createdEvent}")
				h5 {{ eventName || $t('event_editor.title') }}
				h5.d-none.d-lg-block {{ (dateRange && eventName) ? ': ' + dateRange : '' }}

			.card-body
				.row.justify-content-center(v-if="createdEvent")
					.col-md-8.text-center
						h5 {{ $t('event_editor.event_created', {eventName: createdEvent.name, eventOrganizer: createdEvent.organizer}) }}
						p {{ $t('event_editor.share_link') }}
						.input-group.border.border-success
							input.form-control(:value="createdEvent.share_link" readonly @success="clipboard")
							.input-group-append
								button.btn.btn-sm.btn-outline-secondary(
									v-clipboard:copy="createdEvent.share_link"
									v-clipboard:success="clipboard"
								)
									span.oi.oi-clipboard

				.row.justify-content-center(v-else)
					.col-md-8.text-center
						h5 {{ $t('event_editor.welcome') }}

				hr.mb-3

				form(ref="form" @submit.prevent="" novalidate)
					b-btn.btn-block.d-flex(
						v-b-toggle.organizer-group=""
						:variant="groupVariant('organizer-group')"
					)
						span.oi.oi-chevron-bottom(v-if="groupVisibility['organizer-group']")
						span.oi.oi-chevron-top(v-else)
						span.ml-2.mr-auto {{ $t('event_editor.organizer_group') }}
						div(v-if="showGroupErrorIcon('organizer-group')").oi.oi-x
						div(v-else-if="showGroupOkIcon('organizer-group')").oi.oi-check
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


					b-btn.btn-block.d-flex.mt-2(
						v-b-toggle.general-info-group=""
						:variant="groupVariant('general-info-group')"
					)
						span.oi.oi-chevron-bottom(v-if="groupVisibility['general-info-group']")
						span.oi.oi-chevron-top(v-else)
						span.ml-2.mr-auto {{ $t('event_editor.general_info_group') }}
						div(v-if="showGroupErrorIcon('general-info-group')").oi.oi-x
						div(v-else-if="showGroupOkIcon('general-info-group')").oi.oi-check
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
						span.oi.oi-chevron-bottom(v-if="groupVisibility['dates-group']")
						span.oi.oi-chevron-top(v-else)
						span.ml-2.mr-auto {{ $t('event_editor.dates_group') }}
						div(v-if="showGroupErrorIcon('dates-group')").oi.oi-x
						div(v-else-if="showGroupOkIcon('dates-group')").oi.oi-check
					b-collapse#dates-group(
						accordion="event-creation"
						v-model="groupVisibility['dates-group']"
					)
						b-card
							.form-group.row
								label.col-md-4.col-form-label(for="eventDates") {{ $t('event_editor.event.dates') }}
								.col-md-4.mb-3
									.datepicker-trigger
										input#eventDates.form-control(
										:disabled="createdEvent"
										:value="dateRange"
										:class="inputFieldClass('dateRange')"
										:placeholder="$t('event_editor.dates_placeholder')"
										readonly
										)
										.invalid-feedback {{ eventDatesError }}

										div(v-if="!createdEvent")
											AirbnbStyleDatepicker(
												:trigger-element-id="'eventDates'"
													:mode="'range'"
													:fullscreen-mobile="true"
													:date-one="dateFrom"
													:date-two="dateTo"
													:min-date="today"
													@closed="localValidation"
													@date-one-selected="val => { dateFrom = val }"
													@date-two-selected="val => { dateTo = val }"
											)

								.col-md-auto
									b-dropdown(:text="$t('event_editor.dates_quick_selection')" :disabled="createdEvent != null")
										b-dropdown-item(v-if="showThisWeekButton" @click="pickThisWeek") {{ $t('event_editor.this_week') }}
										b-dropdown-item(@click="pickNextWeek(); localValidation();") {{ $t('event_editor.next_week') }}
										b-dropdown-item(@click="pickNextMonths(1); localValidation();") {{ $tc('event_editor.within_months') }}
										b-dropdown-item(@click="pickNextMonths(3); localValidation();") {{ $tc('event_editor.within_months', 3, {count: 3}) }}

			.card-footer
				.row.justify-content-center
					.col-auto(v-if="!createdEvent")
						button.btn.btn-primary(@click="createEvent") Create Event

					.row.justify-content-center(v-else)
						.col-md-auto.mt-1.text-center
							router-link.btn.btn-success(
								role="button"
								:to="{ name: 'poll', params: {eventId: createdEvent.id}}"
							) {{ $t('event_editor.poll_event') }}
						.col-md-auto.mt-1.text-center
							button.btn.btn-primary {{ $t('event_editor.manage_event') }}

</template>

<script>
import dateFns from 'date-fns'

const today = new Date();
const InvalidDate = 'Invalid Date';

const errorsMap = {
	// maps, for each input group, the fields in the vue model to
	// the error fields and the error keys received by the back end
	'organizer-group': {
		eventOrganizer: {
			errorField: 'eventOrganizerError',
			errorKeys: 'organizer'
		}
	},
	'general-info-group': {
		eventName: {
			errorField: 'eventNameError',
			errorKeys: 'name'
		},
		eventDesc: {
			errorField: 'eventDescError',
			errorKeys: 'desc'
		}
	},
	'dates-group': {
		dateRange: {
			errorField: 'eventDatesError',
			errorKeys: ['time_window_to', 'time_window_from', 'time_window']
		}
	}
};

export default {
	data: () => ({
		eventName: null,
		eventNameError: null,
		eventOrganizer: null,
		eventOrganizerError: null,
		eventDesc: null,
		eventDescError: null,
		dateFrom: null,
		dateTo: null,
		eventDatesError: null,
		today,
		wasServerValidated: false,
		wasLocalValidated: false,
		groupVisibility: {
			'general-info-group': false,
			'dates-group': false,
			'organizer-group': true
		},
		showThisWeekButton: (dateFns.getDay(today) > 0 && dateFns.getDay(today) < 4), // betewn Mon and Wed
		createdEvent: null/* {
						id: 'd8763187-ed3d-4572-ae50-02d5cc874804',
						name: "Dinner party",
						organizer: "Max",
						share_link: "http://share",
						owner_link: "http://share"
					}*/
 	}),
	computed: {
		dateRange() {
			let fromDate_s = dateFns.format(this.dateFrom, 'DD/MM/YYYY', {locale: this.$i18n.t('date_fns_locale')});
			let toDate_s = dateFns.format(this.dateTo, 'DD/MM/YYYY', {locale: this.$i18n.t('date_fns_locale')});

			if (fromDate_s == InvalidDate || toDate_s == InvalidDate) {
				return null;
			} else {
				return fromDate_s + ' - ' + toDate_s;
			}
		},
		eventData() {
			return {
				name: this.eventName,
				desc: this.eventDesc,
				organizer: this.eventOrganizer,
				time_window_from: this.dateFrom,
				time_window_to: this.dateTo
			};
		},
		eventHeader() {
			if (this.eventName) {
				return this.eventName + (this.dateRange ? ': ' + this.dateRange : '');
			}
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
		clipboard(e) {
      this.$refs.copiedToClipboardModal.show();
		},
		setServerErrors(errors={}) {
			let groupShownBecauseOfErrors = null;
			for (let group in errorsMap) {
				let fieldMap = errorsMap[group];
				for (let field in fieldMap) {
					let errorKeys = fieldMap[field].errorKeys;
					let errorField = fieldMap[field].errorField;
					errorKeys = errorKeys instanceof Array ? errorKeys : [errorKeys];
					let key_with_error = errorKeys.find(key => errors[key]);
					// only show first error
					this[errorField] = (key_with_error ? errors[key_with_error].join(', ') : null);
					if (key_with_error && !groupShownBecauseOfErrors) {
						this.groupVisibility[group] = true;
						groupShownBecauseOfErrors = group;
					}
				}
			}
		},
		applyDates(from, to) {
			this.dateFrom = from;
			this.dateTo = to;
		},
		pickThisWeek() {
			this.applyDates(
				dateFns.startOfWeek(today, {weekStartsOn: 1}),
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

