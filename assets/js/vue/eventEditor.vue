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

				form(@submit.prevent="" novalidate)
					b-btn.btn-block.d-flex.justify-content-between(
						v-b-toggle.organizer-group=""
						:variant="groupVariant('organizer-group')"
					)
						div
							span.oi.oi-chevron-bottom(v-if="groupVisibility['organizer-group']")
							span.oi.oi-chevron-top(v-else)
							span.ml-2 {{ $t('event_editor.organizer_group') }}
						div(v-if="showGroupErrorIcon('organizer-group')").oi.oi-x
						div(v-else-if="showGroupOkIcon('organizer-group')").oi.oi-check
					b-collapse#organizer-group(accordion="event-creation" v-model="groupVisibility['organizer-group']")
						.form-group.row.mt-md-3
							label.col-md-3.col-form-label(for="eventOrganizer") {{ $t('event_editor.event.organizer') }}
							.col-md-9
								small.form-text.text-muted(id="eventDescHelp") {{ $t('event_editor.event.organizer_help') }}
								input#eventOrganizer.form-control(v-model.trim="eventOrganizer"
								:disabled="createdEvent"
								:class="{'is-invalid': eventOrganizerError, 'is-valid': !eventOrganizerError && wasValidated}")
								.invalid-feedback {{ eventOrganizerError }}


					b-btn.btn-block.d-flex.justify-content-between.mt-2(
						v-b-toggle.general-info-group=""
						:variant="groupVariant('general-info-group')"
					)
						div
							span.oi.oi-chevron-bottom(v-if="groupVisibility['general-info-group']")
							span.oi.oi-chevron-top(v-else)
							span.ml-2 {{ $t('event_editor.general_info_group') }}
						div(v-if="showGroupErrorIcon('general-info-group')").oi.oi-x
						div(v-else-if="showGroupOkIcon('general-info-group')").oi.oi-check
					b-collapse#general-info-group(
						accordion="event-creation"
						v-model="groupVisibility['general-info-group']"
					)
						.form-group.row.mt-md-3
							label.col-md-3.col-form-label(for="eventName") {{ $t('event_editor.event.name') }}
							.col-md-9
								small.form-text.text-muted(id="eventNameHelp") {{ $t('event_editor.event.name_help') }}
								input#eventName.form-control(v-model.trim="eventName" type="text"
								:disabled="createdEvent"
								:class="{'is-invalid': eventNameError, 'is-valid': !eventNameError && wasValidated}")
								.invalid-feedback {{ eventNameError }}
						.form-group.row
							label.col-md-3.col-form-label(for="eventDesc") {{ $t('event_editor.event.desc') }}
							.col-md-9
								small.form-text.text-muted(id="eventDescHelp") {{ $t('event_editor.event.desc_help') }}
								textarea#eventDesc.form-control(v-model.trim="eventDesc"
								:disabled="createdEvent"
								:class="{'is-invalid': eventDescError, 'is-valid': !eventDescError && wasValidated}")
								.invalid-feedback {{ eventDescError }}


					b-btn.btn-block.d-flex.justify-content-between.mt-2(
						v-b-toggle.dates-group=""
						:variant="groupVariant('dates-group')"
					)
						div
							span.oi.oi-chevron-bottom(v-if="groupVisibility['dates-group']")
							span.oi.oi-chevron-top(v-else)
							span.ml-2 {{ $t('event_editor.dates_group') }}
						div(v-if="showGroupErrorIcon('dates-group')").oi.oi-x
						div(v-else-if="showGroupOkIcon('dates-group')").oi.oi-check
					b-collapse#dates-group(
						accordion="event-creation"
						v-model="groupVisibility['dates-group']"
					)
						.form-group.row.mt-md-3.date-picker-trigger
							label.col-md-4.col-form-label(for="eventDates") {{ $t('event_editor.event.dates') }}
							.col-md-4.mb-3
								.datepicker-trigger
									input#eventDates.form-control(
									:disabled="createdEvent"
									:value="dateRange"
									:class="{'is-invalid': eventDatesError, 'is-valid': !eventDatesError && wasValidated}"
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
												@date-one-selected="val => { dateFrom = val }"
												@date-two-selected="val => { dateTo = val }"
										)

							.col-md-auto
								b-dropdown(:text="$t('event_editor.dates_quick_selection')" :disabled="createdEvent != null")
									b-dropdown-item(v-if="showThisWeekButton" @click="pickThisWeek") {{ $t('event_editor.this_week') }}
									b-dropdown-item(@click="pickNextWeek") {{ $t('event_editor.next_week') }}
									b-dropdown-item(@click="pickNextMonths(1)") {{ $tc('event_editor.within_months', 1) }}

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
	// maps, for each input group, the error fields in the vue model to
	// the error keys received by the back end
	'organizer-group': {
		eventOrganizerError: "organizer"
	},
	'general-info-group': {
		eventNameError: "name",
		eventDescError: "desc"
	},
	'dates-group': {
		eventDatesError: ["time_window_to", "time_window_from", "time_window"]
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
		wasValidated: false,
		groupVisibility: {
			'general-info-group': false,
			'dates-group': false,
			'organizer-group': false
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
		collapseAllGroups() {
			for (let group in this.groupVisibility) {
				this.groupVisibility[group] = false;
			}
		},
		showGroupOkIcon(group) {
			return this.wasValidated && !this.groupHasErrors(group);
		},
		showGroupErrorIcon(group) {
			return this.groupHasErrors(group);
		},
		groupVariant(group) {
			return (this.groupHasErrors(group) ? 'danger' : (this.wasValidated ? 'success' : ''));
		},
		groupHasErrors(group) {
			let groupErrorsMap = errorsMap[group] || {}
			for (let key in groupErrorsMap) {
				if (this[key]) {
					return true
				}
			}
			return false;
		},
		clipboard(e) {
      this.$refs.copiedToClipboardModal.show();
		},
		setErrors(errors={}) {
			let noGroupShownBecauseOfErrors = true;
			for (let group in errorsMap) {
				let map = errorsMap[group];
				for (let error_field in errorsMap[group]) {
					let error_keys = (map[error_field] instanceof Array ? map[error_field] : [map[error_field]]);
					let key_with_error = error_keys.find(key => errors[key]);
					// only show first error
					this[error_field] = (key_with_error ? errors[key_with_error].join(', ') : null);
					if (key_with_error && noGroupShownBecauseOfErrors) {
						this.groupVisibility[group] = true;
						noGroupShownBecauseOfErrors = false;
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
			this.applyDates(today, dateFns.addMonths(today,1));
		},
		createEvent() {
			let self = this;
			this.$http.post("/v1/events", {
				event: self.eventData
			}, {
				headers: { 'Accept-Language': this.$i18n.locale }
			})
			.then(function(result) {
				self.setErrors();
				self.createdEvent = result.data.data;
				self.collapseAllGroups();
				self.$refs.eventCreatedModal.show();
			}, function(result) {
				if (result.response && result.response.status == 422) {
					self.setErrors(result.response.data.errors);
				} else {
					self.$refs.errorBar.show(self.$i18n.t('errors.network'));
				}
			})
			.finally(function() {
				self.wasValidated = true;
			});
		}
	}
}
</script>

