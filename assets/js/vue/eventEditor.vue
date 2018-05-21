<template lang="pug">
	.card
		.card-header
			.row.align-items-center
				.col-md-2.text-center.align-items-center
					strong.h5 {{ $t('event_editor.title') }}
				.col
					b-progress(:max="lastStep")
						b-progress-bar(:value="parseInt($route.query.step)" variant="success")
							| {{ $t('event_editor.step', {step: $route.query.step, lastStep: lastStep}) }}

		.card-body
			form(:key="$route.query.step" @submit.prevent="" novalidate)
				div(v-if="$route.query.step == 1")
					.form-group.row.mt-md-3
						label.col-md-3.col-form-label(for="eventName") {{ $t('event_editor.event.name') }}
						.col-md-9
							small.form-text.text-muted(id="eventNameHelp") {{ $t('event_editor.event.name_help') }}
							input#eventName.form-control(v-model.trim="eventName" type="text"
							:disabled="createdEvent"
							:class="{'is-invalid': eventNameError}")
							.invalid-feedback {{ eventNameError }}
					.form-group.row
						label.col-md-3.col-form-label(for="eventDesc") {{ $t('event_editor.event.desc') }}
						.col-md-9
							small.form-text.text-muted(id="eventDescHelp") {{ $t('event_editor.event.desc_help') }}
							textarea#eventDesc.form-control(v-model.trim="eventDesc"
							:disabled="createdEvent"
							:class="{'is-invalid': eventDescError}")
							.invalid-feedback {{ eventDescError }}
					.form-group.row
						label.col-md-3.col-form-label(for="eventOrganizer") {{ $t('event_editor.event.organizer') }}
						.col-md-9
							small.form-text.text-muted(id="eventDescHelp") {{ $t('event_editor.event.organizer_help') }}
							input#eventOrganizer.form-control(v-model.trim="eventOrganizer"
							:disabled="createdEvent"
							:class="{'is-invalid': eventOrganizerError}")
							.invalid-feedback {{ eventOrganizerError }}


				div(v-else-if="$route.query.step == 2")
					.form-group.row.mt-md-3.date-picker-trigger
						label.col-md-4.col-form-label(for="eventDates") {{ $t('event_editor.event.dates') }}
						.col-md-4
							.datepicker-trigger
								input#eventDates.form-control(
								:disabled="createdEvent"
								:value="dateRange"
								:class="{'is-invalid': eventDatesError}"
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

					.form-group.row
						.col.offset-md-4
							b-dropdown(:text="$t('event_editor.dates_quick_selection')" :disabled="createdEvent != null")
								b-dropdown-item(v-if="showThisWeekButton" @click="pickThisWeek") {{ $t('event_editor.this_week') }}
								b-dropdown-item(@click="pickNextWeek") {{ $t('event_editor.next_week') }}
								b-dropdown-item(@click="pickNextMonths(1)") {{ $tc('event_editor.within_months', 1) }}

				div(v-else-if="$route.query.step == 3")
					p.text-center
						strong {{ $t('event_editor.event_created', {eventName: createdEvent.name, organizer: createdEvent.organizer}) }}
					hr.mb-3
					.row.justify-content-center
						.col-md-8.text-center
							p {{ $t('event_editor.share_link') }}
					.row.justify-content-center.mb-5
						.col-md-6
							.input-group.border.border-success
								input.form-control(:value="createdEvent.share_link" readonly @success="clipboard")
								.input-group-append
									button.btn.btn-sm.btn-outline-secondary(
										v-clipboard:copy="createdEvent.share_link"
										v-clipboard:success="clipboard"
									)
										span.oi.oi-clipboard

		.card-footer
			.row(v-if="$route.query.step < lastStep")
				.col.text-left
					router-link.btn.btn-primary(
						v-if="$route.query.step > firstStep"
						role="button"
						:to="{ name: 'new_event', query: {step: ($route.query.step == firstStep ? $route.query.step : parseInt($route.query.step) - 1) }}"
						:class="{disabled: $route.query.step == firstStep}"
					)
						span.oi.oi-arrow-thick-left
						span &nbsp; {{ $t('event_editor.prev') }}
				.col.text-right
					router-link.btn.btn-primary.btn-(
						role="button"
						:to="{ name: 'new_event', query: {step: parseInt($route.query.step) + 1 }}"
					)
						span {{ $t('event_editor.next') }} &nbsp;
						span.oi.oi-arrow-thick-right

			.row.justify-content-end(v-else)
				.col-md-auto.text-center.mt-1
					router-link.btn.btn-success(
						role="button"
						:to="{ name: 'poll', params: {event_id: createdEvent.id}}"
					) {{ $t('event_editor.poll_event') }}
				.col-md-auto.text-center.mt-1
					button.btn.btn-primary {{ $t('event_editor.manage_event') }}

		b-modal(ref="copiedToClipboardModal" hide-header ok-only)
			p.my-4 {{ $t('event_editor.link_copied') }}
</template>

<script>
import dateFns from 'date-fns'

const firstStep = 1;
const lastStep = 3;
const today = new Date();
const InvalidDate = 'Invalid Date';

const sanitizeParameters = (to, forceFirstStep=false) => {
	let step = parseInt(to.query.step);
	if (isNaN(step) || step < firstStep || step > lastStep || (forceFirstStep && step != firstStep)) {
		return { path: to.path, query: {step: firstStep} };
	} else {
		return true;
	}
}

function beforeRouteUpdate(to, from, next) {
	let res = sanitizeParameters(to);
	if (res != true) {
		next(res);
	} else {
		if (from.query.step > to.query.step) {
			// going back
			next();
		} else {
			// going forward
			if (this.createdEvent) {
				// event was already created
				next();
			} else {
				// we still have to create it...
			 	let self = this;
				this.$http.post("/v1/events", {
					dry_run: from.query.step < 2,
					partial: from.query.step < 2,
					event: self.eventDataForStep(from.query.step)
				}, {
					headers: { 'Accept-Language': this.$i18n.locale }
				})
				.then(function(result) {
					self.setErrorsForStep({}, from.query.step);
					if (from.query.step == 2) {
						self.createdEvent = result.data.data;
					}
					next();
				}, function(result) {
					self.setErrorsForStep(result.response.data.errors, from.query.step);
					next(false);
				});
			}
		}
	}
}

const errorsMap = {
	// maps, for each step, the error fields in the vue model to
	// the error keys received by the back end
	1: {
		eventNameError: "name",
		eventDescError: "desc",
		eventOrganizerError: "organizer"
	},
	2: {
		eventDatesError: ["time_window_to", "time_window_from", "time_window"]
	}
};

export default {
	data: () => ({
		eventName: '',
		eventNameError: null,
		eventOrganizer: '',
		eventOrganizerError: null,
		eventDesc: '',
		eventDescError: null,
		dateFrom: '',
		dateTo: '',
		eventDatesError: null,
		firstStep,
		lastStep,
		today,
		showThisWeekButton: (dateFns.getDay(today) > 0 && dateFns.getDay(today) < 4), // betewn Mon and Wed
		createdEvent: null/*{
						name: "Dinner party",
						share_link: "http://share",
						owner_link: "http://share"
					}*/
 	}),
	beforeRouteEnter: (to, from, next) => {
		next(sanitizeParameters(to, true));
	},
	beforeRouteUpdate,
	computed: {
		dateRange() {
			let fromDate_s = dateFns.format(this.dateFrom, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')});
			let toDate_s = dateFns.format(this.dateTo, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')});

			if (fromDate_s == InvalidDate || toDate_s == InvalidDate) {
				return '';
			} else {
				return fromDate_s + ' - ' + toDate_s;
			}
		}
	},
	methods: {
		clipboard(e) {
      this.$refs.copiedToClipboardModal.show();
		},
		eventDataForStep(step) {
			let data = {};
			if (step >= 1) {
				Object.assign(data, {
					name: this.eventName,
					desc: this.eventDesc,
					organizer: this.eventOrganizer
				});
			}
			if (step >= 2) {
				Object.assign(data, {
					time_window_from: this.dateFrom,
					time_window_to: this.dateTo
				});
			}
			return data;
		},
		setErrorsForStep(errors, step) {
			let map = errorsMap[step];
			if (map) {
				for (let error_field in map) {
					let error_keys = (map[error_field] instanceof Array ? map[error_field] : [map[error_field]]);
					let key_with_error = error_keys.find(key => errors[key]);
					this[error_field] = (key_with_error ? errors[key_with_error][0] : null);
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
		}
	}
}
</script>

