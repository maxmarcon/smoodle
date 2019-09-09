  <template lang="pug">
  div
    message-bar(ref="errorBar" variant="danger")
    b-modal#updateAnswerModal(
      :title="$t('event_viewer.update.title')"
      :ok-title="$t('event_viewer.update.load')"
      :cancel-title="$t('actions.cancel')"
      :ok-disabled="!pollParticipant || requestOngoing"
      :cancel-disabled="requestOngoing"
      @ok="loadPoll"
    )
      .form-group
        label(for="pollParticipant") {{ $t('event_viewer.update.how_to') }}
        input#pollParticipant.form-control(
          v-model.trim="pollParticipant"
          :class="{'is-invalid': pollParticipantError}"
          :placeholder="$t('event_viewer.update.name_placeholder')"
          @keyup.enter="loadPoll"
        )
        .invalid-feedback {{ pollParticipantError }}

    b-modal(ref="copiedToClipboardModal" hide-header ok-only)
      p {{ $t('event_editor.link_copied') }}

    b-modal#cancelEventModal(
      :title="$t('event_viewer.cancel_event')"
      :ok-title="$t('event_viewer.cancel_event')"
      :cancel-title="$t('actions.do_not_cancel')"
      @ok="cancelEvent"
    )
      p {{ $t('event_viewer.really_cancel_event') }}

      .form-group
        label(for=cancelOrganizerMessage) {{ $t('event_viewer.organizer_message') }}
        textarea#cancelOrganizerMessage.form-control(v-model.trim="eventOrganizerMessage")

    b-modal(ref="eventCanceledModal"
      :title="$t('event_viewer.cancel_event')"
      ok-only
    )
      p {{ $t('event_viewer.event_canceled_ok') }}

    b-modal(ref="eventCancelErrorModal"
      :title="$t('errors.error')"
      ok-only
    )
      p {{ $t('event_viewer.cancel_event_error') }}

    b-modal(ref="eventOpenedModal"
      :title="$t('event_viewer.open_event')"
      ok-only
    )
      p {{ $t('event_viewer.event_opened_ok') }}

    b-modal(ref="eventOpenErrorModal"
      :title="$t('errors.error')"
      ok-only
    )
      p {{ $t('event_viewer.open_event_error') }}

    b-modal#participantsListModal(
      :title="$t('event_viewer.current_participants')"
      ok-only
    )
      p {{ trimmedNameList(eventScheduleParticipants, 25) }}

    b-modal#scheduleEventModal(
      :title="$t('event_viewer.schedule_event')"
      :cancel-title="$t('actions.cancel')"
      :ok-disabled="requestOngoing"
      :ok-only="!selectedDate"
      @ok="scheduleEvent"
    )
      div(v-if="selectedDate")
        .alert.alert-danger(v-if="selectedDateNegativeRank < 0")
          | {{ $tc('event_viewer.warning_bad_date', -selectedDateNegativeRank, {participants: -selectedDateNegativeRank}) }}
        .alert.alert-info {{ $t('event_viewer.about_to_schedule', {date: selectedDateFormatted}) }}

        .justify-content-center
          .form-group
            label(for="timePicker") {{ $t('event_viewer.select_time') }}
            date-picker#timePicker(
              v-model="selectedTime"
              :config="timePickerOptions"
            )
        .form-group
          label(for=scheduleOrganizerMessage) {{ $t('event_viewer.organizer_message') }}
          textarea#scheduleOrganizerMessage.form-control(v-model.trim="eventOrganizerMessage")

      div(v-else)
        p {{ $t('event_viewer.select_date_first') }}

    b-modal#scheduledEventModal(
      ref="scheduledEventModal"
      :title="$t('event_viewer.schedule_event')"
      ok-only
    )
      p {{ $t('event_viewer.event_scheduled_organizer', {datetime: eventScheduledDateTime, time_distance: eventScheduledDateTimeRelative}) }}

    b-modal(ref="scheduleEventErrorModal"
      :title="$t('errors.error')"
      ok-only
    )
      p {{ $t('event_viewer.schedule_event_error') }}

    .card(v-if="loadedSuccessfully")
      .card-header(:class="eventBackgroundClass")
        event-header#event-header(
          v-bind="eventData"
        )
      ul.list-group.list-group-flush
        li.list-group-item(v-if="eventDesc")
          p(name="event-intro")
            em.text-muted {{ isOrganizer ? $t('event_viewer.description') : $t('event_viewer.organizer_says', {organizer: eventOrganizer}) }} &nbsp;
            | {{ eventDesc }}
        li.list-group-item(v-if="isOrganizer && !emptyDomain && (eventOpen || eventScheduled)")
          .alert.alert-success
            i.fas.fa-key
            | &nbsp; {{ $t('event_viewer.welcome_organizer') }}
          .form-group.row.justify-content-center
            label.col-md-auto.col-form-label {{ $t('event_viewer.share_link') }}
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
        li.list-group-item
          div(v-if="eventOpen")
            div(v-if="!isOrganizer")
              .alert.alert-warning(v-if="eventModified")
                i.fas.fa-cut
                | &nbsp; {{ $t('event_viewer.event_modified', {time_distance: eventModifiedRelative, organizer: eventOrganizer}) }}
              .alert.alert-success
                i.fas.fa-share-alt
                | &nbsp; {{ $t('event_viewer.welcome', {organizer: eventOrganizer}) }}
            .alert.alert-danger(v-if="emptyDomain")
                i.fas.fa-exclamation-triangle
                | &nbsp; {{ $t('event_viewer.empty_domain') }}
            div(v-else)
              div(v-if="eventScheduleParticipantsCount")
                .alert.alert-info
                  i18n(path="event_viewer.event_open_organizer" v-if="isOrganizer")
                    i.fas.fa-calendar-check.fa-lg(place="calendar_icon")
                    a(href="#" place="participants" v-b-modal.participantsListModal="")
                      | {{ $tc('event_viewer.nof_participants', eventScheduleParticipantsCount, {participants: eventScheduleParticipantsCount}) }}

                  i18n(path="event_viewer.event_open" v-else)
                    i.fas.fa-calendar-check.fa-lg(place="calendar_icon")
                    span(place="answers") {{ $tc('event_viewer.answers', eventScheduleParticipantsCount, {count: eventScheduleParticipantsCount}) }}
                .row.justify-content-md-between.justify-content-lg-center
                  .col-md-3.offset-md-1.order-md-last.text-justify
                    .form-group
                      i18n.small.text-muted(
                        :path="isOrganizer ? 'event_viewer.date_selection_help_organizer' : 'event_viewer.date_selection_help'"
                        tag="p"
                      )
                        span.text-success(place="best") {{ $t('event_viewer.best') }}
                        span.text-danger(place="worst") {{ $t('event_viewer.worst') }}
                        span.text-success(place="green") {{ $t('event_viewer.green') }}
                        span.text-danger(place="red") {{ $t('event_viewer.red') }}
                        span.text-primary(place="blue_underlined") {{ $t('event_viewer.blue_underlined') }}

                  .col-md-6.text-center
                    .form-group
                      v-date-picker(
                        v-if="isOrganizer"
                        mode="single"
                        v-model="selectedDate"
                        :attributes="scheduleCalendarAttributes"
                        :is-inline="true"
                        :is-linked="true"
                        :from-page="fromPage"
                        :min-page="fromPage"
                        :max-page="toPage"
                        :available-dates="eventDomain"
                        :is-double-paned="differentMonths"
                        :select-attribute="selectAttrubute"
                        nav-visibility="hidden"
                        :is-expanded="true"
                        :theme-styles="calThemeStyles"
                      )
                      v-calendar(
                        v-else
                        :is-linked="true"
                        nav-visibility="hidden"
                        :attributes="scheduleCalendarAttributes"
                        :min-page="fromPage"
                        :max-page="toPage"
                        :is-double-paned="differentMonths"
                        :is-expanded="true"
                        :theme-styles="calThemeStyles"
                      )

              div.alert.alert-primary(v-else-if="loaded")
                i18n(path="event_viewer.no_participants_organizer" v-if="isOrganizer")
                  i.fas.fa-thermometer-empty.fa-lg(place="icon")
                i18n(path="event_viewer.no_participants" v-else)
                  i.fas.fa-trophy.fa-lg(place="icon")

          div(v-else-if="eventScheduled")
            .alert.alert-success
              i.fas.fa-handshake.fa-lg
              | &nbsp; {{ $t(isOrganizer ? 'event_viewer.event_scheduled_organizer' : 'event_viewer.event_scheduled', {datetime: eventScheduledDateTime, organizer: eventOrganizer, time_distance: eventScheduledDateTimeRelative}) }}

            .row.justify-content-md-between.justify-content-lg-center
              .col-md-3.offset-md-1.text-justify(v-if="eventOrganizerMessage")
                p
                  em.text-muted {{ $t('event_viewer.organizer_says', {organizer: eventOrganizer}) }} &nbsp;
                  | {{ eventOrganizerMessage }}

              .col-md-6
                .form-group
                  v-calendar(
                    :is-linked="true"
                    nav-visibility="hidden"
                    :min-page="fromPage"
                    :max-page="toPage"
                    :attributes="scheduledEventCalendarAttributes"
                    :is-double-paned="differentMonths"
                    :is-expanded="true"
                    :theme-styles="calThemeStyles"
                  )

          div(v-else-if="eventCanceled")
            .alert.alert-warning
              i.fas.fa-ban.fa-lg
              | &nbsp; {{ $t(isOrganizer ? 'event_viewer.event_canceled_organizer' : 'event_viewer.event_canceled') }}

            div(v-if="eventOrganizerMessage")
              .d-flex.text-justify
                em.text-muted {{ $t('event_viewer.organizer_says', {organizer: eventOrganizer}) }} &nbsp;
                | {{ eventOrganizerMessage }}

      .card-footer(v-if="eventOpen || isOrganizer")
        .row.justify-content-center
          .col-12.col-sm-auto.mt-1(v-if="eventOpen && !emptyDomain && isOrganizer && eventScheduleParticipantsCount")
            button.btn.btn-block.btn-primary(v-b-modal.scheduleEventModal="" :disabled="requestOngoing" name="schedule-button")
              i.fas.fa-clock
              | &nbsp; {{ $t('event_viewer.schedule_event') }}
          .col-12.col-sm-auto.mt-1(v-if="eventOpen && isOrganizer")
            router-link.btn.btn-block.btn-success(
              name="edit-button"
              role="button"
              :to="{ name: 'edit_event', params: {eventId: eventId, secret: secret}, query: {s: secret} }"
            )
              i.fas.fa-edit
              | &nbsp; {{ $t('event_viewer.edit_event') }}
          .col-12.col-sm-auto.mt-1(v-if="eventOpen && !emptyDomain && isOrganizer")
            button.btn.btn-block.btn-block.btn-warning(v-b-modal.cancelEventModal="" :disabled="requestOngoing"
              name="cancel-button"
            )
              i.fas.fa-ban
              | &nbsp; {{ $t('event_viewer.cancel_event') }}
          .col-12.col-sm-auto.mt-1(v-if="!eventOpen && !emptyDomain && isOrganizer")
            button.btn.btn-block.btn-warning(@click="openEvent" :disabled="requestOngoing"
              name="open-button"
            )
              i.fas.fa-undo
              | &nbsp; {{ $t('event_viewer.open_event') }}
          .col-12.col-sm-auto.mt-1(v-if="eventOpen && !emptyDomain && !isOrganizer")
            router-link.btn.btn-block.btn-success(
              name="new-poll-button"
              role="button"
              :to="{ name: 'new_poll', params: {eventId: eventId}}"
            )
              i.fas.fa-question
              | &nbsp; {{ $t('event_viewer.create_poll') }}
          .col-12.col-sm-auto.mt-1(v-if="eventOpen && !emptyDomain && !isOrganizer && eventScheduleParticipantsCount")
            button.btn.btn-block.btn-primary(v-b-modal.updateAnswerModal="" :disabled="requestOngoing" name="edit-poll-button")
              i.fas.fa-edit
              | &nbsp; {{ $t('event_viewer.update_poll') }}


    error-page(
      v-else-if="loaded"
      :message="$t('errors.not_found')"
    )
</template>
<script>
import {
  colorCodes,
  eventHelpersMixin,
  eventDataMixin,
  scrollToTopMixin,
  restMixin,
  whatsAppHelpersMixin,
  nameListTrimmerMixin,
  calThemeStyles
} from '../globals'
import dateFns from 'date-fns'

const SCHEDULE_DATES_LIMIT = null;
const EVENT_RELOAD_INTERVAL_MSEC = 15000;

export default {
  mixins: [
    restMixin,
    eventHelpersMixin,
    eventDataMixin,
    scrollToTopMixin,
    whatsAppHelpersMixin,
    nameListTrimmerMixin
  ],
  props: {
    eventId: {
      type: String,
      required: true
    },
    secret: String
  },
  data: () => ({
    eventScheduleDates: [],
    eventScheduleParticipantsCount: 0,
    eventScheduleParticipants: [],
    pollParticipant: null,
    pollParticipantError: null,
    loaded: false,
    loadedSuccessfully: false,
    loading: false,
    requestOngoing: false,
    selectedDate: null,
    selectedTime: "19:30",
    timePickerOptions: {
      format: 'HH:mm',
      inline: true,
      icons: {
        up: "fas fa-sort-up fa-2x",
        down: "fas fa-sort-down fa-2x"
      }
    },
    selectAttrubute: {
      highlight: {
        backgroundColor: colorCodes.blue,
        opacity: 1,
        borderColor: colorCodes.black,
        borderWidth: "2px"
      }
    },
    calThemeStyles,
    reloadIntervalId: null
  }),
  created() {
    this.loadEvent()
    this.reloadIntervalId = setInterval(() => this.loadEvent(), EVENT_RELOAD_INTERVAL_MSEC)
  },
  beforeDestroy() {
    clearInterval(this.reloadIntervalId)
  },
  computed: {
    isOrganizer() {
      return this.secret;
    },
    scheduleCalendarAttributes() {
      // Hack: we add this otherwise unused locale variable
      // to triger a dependency on $i18n.locale. This will cause
      // the scheduleCalendarAttributes to be recomputed whenever the locale changes, thus
      // allowing live locale changes on the client side
      let _hack_dependency_on_locale = this.$i18n.locale;

      const scheduleDates = this.eventScheduleDates.length;
      let minNegativeRank;
      let maxPositiveRank;
      if (scheduleDates > 0) {
        minNegativeRank = this.eventScheduleDates[scheduleDates-1].negative_rank;
        maxPositiveRank = this.eventScheduleDates[0].positive_rank;
      }
      const limit = (SCHEDULE_DATES_LIMIT != null ? SCHEDULE_DATES_LIMIT : this.eventScheduleDates.length);
      let is_top_rank = ({negative_rank, positive_rank}) => {
        if (this.eventScheduleDates.length > 0) {
          const {negative_rank: top_negative_rank, positive_rank: top_positive_rank} = this.eventScheduleDates[0]
          if (top_negative_rank < 0) {
            return top_negative_rank === negative_rank
          } else {
            return negative_rank === 0 && top_positive_rank === positive_rank 
          }
        } else {
          return false
        }
      }
      return this.eventScheduleDates.slice(0, limit).map((date_entry) => ({
        dates: dateFns.parse(date_entry.date),
        highlight: {
          backgroundColor: (date_entry.negative_rank < 0 ? colorCodes.red : colorCodes.green),
					opacity: this.opacityForDate(date_entry, minNegativeRank, maxPositiveRank)
        },
        bar: (is_top_rank(date_entry) ? {
          backgroundColor: colorCodes.blue
        } : false),
        popover: {
          label: this.labelForDate
        },
        customData: date_entry
      }));
    },
    scheduledEventCalendarAttributes() {
      return [{
        dates: this.eventScheduledFrom,
        popover: {
          label: this.eventScheduledTime
        },
        highlight: {
          borderColor: colorCodes.black,
          opacity: 0.6,
          borderWidth: "2px",
          backgroundColor: colorCodes.blue
        }
      }]
    },
    selectedDateFormatted() {
      return dateFns.format(this.selectedDate, this.$i18n.t('date_format'), {locale: this.$i18n.t('date_fns_locale')});
    },
    selectedDateNegativeRank() {
      return (this.eventScheduleDates.find(({date}) => dateFns.isEqual(date, this.selectedDate)) || {}).negative_rank
    }
  },
  methods: {
    loadEvent() {
      if (this.loading) {
        return
      }
      this.loading = true
      Promise.all([
          this.restRequest(['events', this.eventId].join('/'), {
            params: {
              secret: this.secret,
            },
            background: this.loadedSuccessfully
          }),
          this.restRequest(['events', this.eventId, 'schedule'].join('/'), {
            params: {
              limit: SCHEDULE_DATES_LIMIT,
              secret: this.secret
            },
            background: this.loadedSuccessfully
          })
        ])
        .then(([eventResult, scheduleResult]) => {
          this.assignEventData(eventResult.data.data);
          this.eventScheduleDates = scheduleResult.data.data.dates;
          this.eventScheduleParticipants = scheduleResult.data.data.participants;
          this.eventScheduleParticipantsCount = scheduleResult.data.data.participants_count;
          this.loadedSuccessfully = true;
        })
        .finally(() => {
          this.loaded = true
          this.loading = false
        });
    },
    opacityForDate(date_entry, minNegativeRank, maxPositiveRank) {
      return (date_entry.negative_rank < 0
        ? date_entry.negative_rank / minNegativeRank
        : Math.max(date_entry.positive_rank, 0.5) / maxPositiveRank);
    },
    labelForDate(attribute) {
      let date_entry = attribute.customData;
      if (date_entry.negative_rank < 0) {
        if (this.isOrganizer) {
          return this.$i18n.tc('event_viewer.negative_participants_list_date',
            date_entry.negative_participants.length,
            {participants: this.trimmedNameList(date_entry.negative_participants)} );
        } else {
          return this.$i18n.tc('event_viewer.negative_participants_for_date', -date_entry.negative_rank);
        }
      } else {
        if (this.isOrganizer && date_entry.positive_rank > 0) {
          return this.$i18n.tc('event_viewer.positive_participants_list_date', date_entry.positive_participants.length,
            {participants: this.trimmedNameList(date_entry.positive_participants)} );
        } else {
          return this.$i18n.tc('event_viewer.positive_participants_for_date', date_entry.positive_rank);
        }
      }
    },
    clipboard() {
      this.$refs.copiedToClipboardModal.show();
    },
    loadPoll(bvEvt) {
      bvEvt.preventDefault();
      let self = this;
      if (this.pollParticipant) {
        this.restRequest(['events', this.eventId, 'polls'].join('/'), {
          params: {
            participant: this.pollParticipant
          }
        }).then(function(result) {
          self.pollParticipantError = null
          self.$router.push({name: 'edit_poll', params: {pollId: result.data.data.id}});
        }, function(error) {
          if (error.response && error.response.status == 404) {
            self.pollParticipantError = self.$i18n.t('event_viewer.update.poll_not_found');
          } else {
            throw error;
          }
        });
      }
    },
    openEvent() {
      let self = this;
      this.restRequest(['events', this.eventId].join('/'), {
        method: 'patch',
        data: {
          event: {
            state: "OPEN",
            secret: this.secret,
            scheduled_from: null,
            scheduled_to: null
          }
        }
      }).then(function(result) {
        self.assignEventData(result.data.data);
        self.$refs.eventOpenedModal.show();
      }, function(error) {
        self.$refs.eventOpenErrorModal.show();
        throw error;
      });
    },
    cancelEvent() {
      let self = this;
      this.restRequest(['events', this.eventId].join('/'), {
        method: 'patch',
        data: {
          event: {
            state: "CANCELED",
            secret: this.secret,
            organizer_message: this.eventOrganizerMessage
          }
        }
      }).then(function(result) {
        self.assignEventData(result.data.data);
        self.$refs.eventCanceledModal.show();
      }, function(error) {
        self.$refs.eventCancelErrorModal.show();
        throw error;
      });
    },
    scheduleEvent() {
      if (!this.selectedDate) {
        return;
      }

      let [hours, minutes] = this.selectedTime.split(':');
      this.selectedDate = dateFns.setHours(
        dateFns.setMinutes(this.selectedDate, minutes),
        hours
      );

      let self = this;
      this.restRequest(['events', this.eventId].join('/'), {
        method: 'patch',
        data: {
          event: {
            state: 'SCHEDULED',
            secret: this.secret,
            scheduled_from: this.selectedDate.toISOString(),
            scheduled_to: dateFns.addHours(this.selectedDate, 6).toISOString(),
            organizer_message: this.eventOrganizerMessage
          }
        }
      }).then(function(result) {
        self.assignEventData(result.data.data);
        self.$refs.scheduledEventModal.show();
      }, function(error) {
        self.$refs.scheduleEventErrorModal.show();
        throw error;
      });
    }
  }
}
</script>
