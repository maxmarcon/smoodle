<template lang="pug">
  div
    message-bar(ref="errorBar" variant="danger")
    b-modal(ref="copiedToClipboardModal" hide-header ok-only)
      p {{ $t('event_editor.link_copied') }}
    b-modal(ref="eventCreatedModal" hide-header ok-only)
      p {{ $t('event_editor.event_created_short') }}
    b-modal#eventUpdatedModal(ref="eventUpdatedModal" hide-header ok-only :ok-title="$t('event_editor.back_to_event')" @ok="backToEvent")
      p {{ $t('event_editor.event_updated') }}
    .card(v-if="!eventId || loadedSuccessfully || eventCreated" name="main-card")
      .card-header
        event-header#event-header(
          :eventName="eventName"
          :eventOrganizer="eventOrganizer"
          :eventTimeWindow="formattedEventTimeWindow"
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
          | &nbsp {{ $t('event_editor.welcome_again', {organizer: eventOrganizer}) }}
        .alert.alert-info(v-else)
          i.fas.fa-calendar-alt.fa-lg
          | &nbsp {{ $t('event_editor.welcome') }}

        hr.mb-3
        div(@keyup.enter="nextStep")
          progress-header.mb-1(
            :step="step"
            :maxStep="maxStep"
            :minStep="minStep"
          )
          b-card(
            v-if="!eventId && step == errorsMap['organizer-group'].step"
            :header-bg-variant="groupBgVariant('organizer-group')"
            header-text-variant="white"
          )
            .d-flex(slot="header")
              .flex-grow-1 {{ $t('event_editor.organizer_group') }}
              .fas.fa-exclamation(v-if="showGroupErrorIcon('organizer-group')")
              .fas.fa-check(v-else-if="showGroupOkIcon('organizer-group')")
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
                  type="email"
                )
                .invalid-feedback(name="event-organizer-email-error") {{ eventOrganizerEmailError }}

                small.form-text.text-muted {{ $t('event_editor.event.organizer_email_confirmation_help') }}
                input#eventOrganizerEmailConfirmation.form-control(
                  v-model.trim="eventOrganizerEmail_confirmation"
                  @change="localValidation"
                  @blur="localValidation"
                  :disabled="eventCreated"
                  :class="inputFieldClass('eventOrganizerEmail_confirmation')"
                  type="email"
                )
                .invalid-feedback(name="event-organizer-email-confirmation-error") {{ eventOrganizerEmailError_confirmation }}

          b-card(
            v-if="step == errorsMap['general-info-group'].step"
            :header-bg-variant="groupBgVariant('general-info-group')"
            header-text-variant="white"
          )
            .d-flex(slot="header")
              .flex-grow-1 {{ $t('event_editor.general_info_group') }}
              .fas.fa-exclamation(v-if="showGroupErrorIcon('general-info-group')")
              .fas.fa-check(v-else-if="showGroupOkIcon('general-info-group')")

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

          b-card(
            v-if="step == errorsMap['dates-group'].step"
            :header-bg-variant="groupBgVariant('dates-group')"
            header-text-variant="white"
          )
            .d-flex(slot="header")
              .flex-grow-1 {{ $t('event_editor.dates_group') }}
              .fas.fa-exclamation(v-if="showGroupErrorIcon('dates-group')")
              .fas.fa-check(v-else-if="showGroupOkIcon('dates-group')")

            .form-group.row.justify-content-center.justify-content-md-between.justify-content-lg-center
              .col-md-6.mb-3.text-center
                .d-flex.justify-content-center.align-items-end
                  label {{ $t(selectedDateRank == 0 ? 'event_editor.event.dates_range' : 'event_editor.event.dates_single') }}

                v-date-picker#eventPossibleDates(
                  :mode="selectedDateRank == 0 ? 'range' : 'single'"
                  v-model="datesSelection"
                  nav-visibility="hidden"
                  :min-date="today"
                  :is-inline="true"
                  :is-double-paned="true"
                  :from-page="initialFromPage"
                  :is-linked="true"
                  :show-caps="true"
                  :is-required="true"
                  :attributes="datePickerAttributes"
                  popover-visibility="hidden"
                  :select-attribute="selectAttribute"
                  :drag-attribute="selectAttribute"
                  @input="newDate"
                  :is-expanded="true"
                )
                .small.text-danger(name="event-possible-dates-error") {{ eventPossibleDatesError }}

                .d-flex.mt-2.justify-content-center.align-items-end(@click="clearDateSelection")
                  .form-check
                    p-radio.p-icon.p-plain(:disabled="selectedDateRank == 0" name="selectedDateRank" :value="1" v-model="selectedDateRank" toggle)
                      i.icon.fas.fa-thumbs-up.text-success(slot="extra")
                      i.icon.far.fa-thumbs-up(slot="off-extra")
                      label(slot="off-label")
                  .form-check
                    p-radio.p-icon.p-plain(:disabled="selectedDateRank == 0" name="selectedDateRank" :value="-1" v-model="selectedDateRank" toggle)
                      i.icon.fas.fa-thumbs-down.text-danger(slot="extra")
                      i.icon.far.fa-thumbs-down(slot="off-extra")
                      label(slot="off-label")
                  .form-check
                    button.btn.btn-sm.btn-outline-secondary(@click="clearDateInfo" :disabled="selectedDateRank == 0 && !undoData")
                      i.fas.fa-undo(v-if="undoData")
                      i.fas.fa-trash-alt(v-else)

              .col-11.col-md-3.offset-md-1
                ranker#eventWeekdays(:elements="eventWeekdays" boolean=true :disabled="selectedDateRank == 0" @change="eventWeekdaysChanged")
                .small.text-danger(name="event-weekdays-error") {{ eventWeekdaysError }}

      .card-footer
        .row.justify-content-around(v-if="!eventCreated")
          .col-12.col-sm-2.order-sm-last.mt-1
            button.btn.btn-block.btn-primary(@click="nextStep" :disabled="requestOngoing")
              span(v-if="step < maxStep" name="forward-button")
                i.fas.fa-arrow-circle-right
                | &nbsp {{ $t('actions.next')}}
              span(v-else name="save-event-button")
                i.fas(:class="{'fa-save': eventId, 'fa-plus': !eventId}")
                | &nbsp {{ $t(eventId ? 'event_editor.update_event' : 'event_editor.create_event') }}
          .col-12.col-sm-2.mt-1(v-if="(!eventId && maxStep > minStep) || step > minStep")
            button.btn.btn-block.btn-secondary(@click="prevStep" :disabled="step == minStep || requestOngoing" name="back-button")
              i.fas.fa-arrow-circle-left
              | &nbsp {{ $t('actions.prev')}}
          .col-12.col-sm-2.mt-1(v-if="eventId && step == minStep")
            button.btn.btn-block.btn-secondary(@click="backToEvent" :disabled="requestOngoing" name="cancel-button")
              i.fas.fa-ban
              | &nbsp {{ $t('actions.cancel') }}
        .row.justify-content-center(v-else)
          .col-12.col-sm-auto.mt-1
            router-link.btn.btn-block.btn-success(
              role="button"
              name="manage-event-button"
              :to="{ name: 'event', params: {eventId: computedEventId, secret: computedSecret}, query: {s: computedSecret}}"
            )
              i.fas.fa-key
              | &nbsp {{ $t('event_editor.manage_event') }}

    error-page(
      v-else-if="loaded"
      :message="$t('errors.not_found')"
    )
</template>
<script>
import dateFns from 'date-fns'
import {
  stepValidationMixin,
  scrollToTopMixin,
  errorBarMixin,
  restMixin,
  eventDataMixin,
  eventHelpersMixin,
  whatsAppHelpersMixin,
  colorCodes
} from '../globals'

const today = new Date()

export default {
  mixins: [stepValidationMixin, restMixin, scrollToTopMixin, errorBarMixin, eventDataMixin, eventHelpersMixin, whatsAppHelpersMixin],
  props: {
    eventId: String,
    secret: String,
    forceStep: Number // for testing
  },
  data() {
    return {
      errorsMap: {
        // maps, for each input group, the fields in the vue model to
        // the error fields and the error keys received by the back end
        'organizer-group': {
          step: 1,
          fields: {
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
          }
        },
        'general-info-group': {
          step: 2,
          fields: {
            eventName: {
              required: true,
              errorField: 'eventNameError',
              errorKeys: 'name'
            },
            eventDesc: {
              required: false,
              errorField: 'eventDescError',
              errorKeys: 'desc'
            }
          }
        },
        'dates-group': {
          step: 3,
          fields: {
            eventPossibleDates: {
              required: true,
              errorField: 'eventPossibleDatesError',
              errorKeys: ['possible_dates']
            },
            eventWeekdays: {
              errorField: 'eventWeekdaysError',
              errorKeys: 'preferences.weekdays',
              customValidation: true
            }
          }
        }
      },
      eventNameError: null,
      eventOrganizerError: null,
      eventOrganizerEmailError: null,
      eventOrganizerEmailError_confirmation: null,
      eventDescError: null,
      eventPossibleDatesError: null,
      eventWeekdaysError: null,
      today,
      loadedSuccessfully: false,
      loaded: false,
      initialFromPage: null,
      eventCreated: false,
      createdEventId: null,
      createdEventSecret: null,
      selectedDateRank: 0,
      datesSelection: null,
      undoData: null,
      step: this.forceStep || 1,
      minStep: 1,
      maxStep: 3
    }
  },
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
          if (self.eventDomain.length == 0) {
            // this could happen if the original possible dates are all in the past
            self.eventPossibleDates = []
          } else {
            self.selectedDateRank = 1
          }
          self.loadedSuccessfully = true
          self.minStep = 2
          self.step = self.forceStep || self.minStep

        }).finally(function() {
          self.loaded = true
        })
      } else {
        this.loaded = true
      }
    }
    // we compute fromPage only once at the very beginning, because we don't want
    // adding/removing dates to bring the user back to the first calendar page containing
    // the event dates
    this.initialFromPage = this.fromPage
  },
  computed: {
    computedEventId() {
      return this.eventId || this.createdEventId
    },
    computedSecret() {
      return this.secret || this.createdEventSecret
    },
    datePickerAttributes() {
      return this.eventPossibleDates.map(({
        date_from,
        date_to,
        rank
      }) => {
        return {
          dates: {
            start: date_from,
            end: date_to,
          },
          highlight: {
            animated: false,
            backgroundColor: this.colorForRank(rank),
            opacity: (rank == 0 ? 0.6 : 1)
          },
          order: (rank == 0 ? 0 : 2)
        }
      }).concat([{
        dates: {
          start: today,
          end: null,
          weekdays: this.eventWeekdays.filter(({
            value
          }) => !value).map(({
            day
          }) => ((day + 1) % 7) + 1)
          // from 0=Mon...6=Sun to v-calendars's 1=Sun...7=Sat
        },
        highlight: {
          animated: false,
          backgroundColor: this.colorForRank(-1),
          opacity: 0.6
        },
        order: 1
      }])
    },
    selectedDateRankColor() {
      return this.colorForRank(this.selectedDateRank)
    },
    selectAttribute() {
      return {
        highlight: {
          backgroundColor: this.selectedDateRankColor
        },
        popover: {
          visibility: 'hidden'
        }
      }
    }
  },
  methods: {
    colorForRank: (rank) => (rank >= 0 ? colorCodes.green : colorCodes.red),
    customValidate(fieldName, fieldVal) {
      if (fieldName == 'eventWeekdays') {
        if (fieldVal.every(({
            value
          }) => !value)) {
          return this.$i18n.t('errors.enable_at_least_one_weekday')
        }
      }
    },
    eventWeekdaysChanged() {
      this.normalizePossibleDates()
      this.localValidation()
    },
    clearDateSelection() {
      this.datesSelection = null
    },
    clearDateInfo() {
      if (this.undoData) {
        this.eventPossibleDates = this.undoData.eventPossibleDates
        this.eventWeekdays = this.undoData.eventWeekdays
        this.selectedDateRank = -1
        this.undoData = null
      } else {
        this.undoData = {
          eventPossibleDates: this.eventPossibleDates,
          eventWeekdays: this.eventWeekdays
        }
        this.eventPossibleDates = []
        this.eventWeekdays = this.initialWeekdays()
        this.selectedDateRank = 0
      }
    },
    newDate(value) {
      if (value) {
        if (this.selectedDateRank == 0 && value.start && value.end) {

          this.eventPossibleDates = [{
            date_from: value.start,
            date_to: value.end,
            rank: 0
          }]
          this.selectedDateRank = -1
          this.undoData = null
          this.clearDateSelection()
          this.localValidation()

        } else if (this.selectedDateRank != 0 && value instanceof Date) {

          let containingIndex = this.eventPossibleDates.findIndex(({
            date_from,
            date_to,
            rank
          }) => dateFns.isWithinRange(value, date_from, date_to))

          let insertElement = false

          if (containingIndex > -1) {

            let containingElement = this.eventPossibleDates[containingIndex]
            if (containingElement.rank != this.selectedDateRank) {

              insertElement = (this.selectedDateRank >= 0)

              this.eventPossibleDates.splice(containingIndex, 1)

              if (dateFns.isAfter(value, containingElement.date_from)) {
                this.eventPossibleDates.push({
                  date_from: containingElement.date_from,
                  date_to: dateFns.subDays(value, 1),
                  rank: containingElement.rank
                })
              }
              if (dateFns.isBefore(value, containingElement.date_to)) {
                this.eventPossibleDates.push({
                  date_from: dateFns.addDays(value, 1),
                  date_to: containingElement.date_to,
                  rank: containingElement.rank
                })
              }
            }
          } else {
            insertElement = (this.selectedDateRank >= 0)
          }

          if (insertElement) {
            this.eventPossibleDates.push({
              date_from: value,
              date_to: value,
              rank: this.selectedDateRank
            })
          }

          this.clearDateSelection()

          this.normalizePossibleDates()
        }

        //DEBUG
        //console.dir(this.eventPossibleDates)
        //console.dir(this.eventDomain)
      }
    },
    clipboard() {
      this.$refs.copiedToClipboardModal.show()
    },
    saveEvent(dry_run = false) {
      let self = this
      let dataForRequest = self.eventDataForRequest
      if (self.eventId) {
        /// updating, let us not resent email or organizer
        delete dataForRequest['organizer']
        delete dataForRequest['email']
      }
      return this.restRequest(
        (this.eventId ? ["events", this.eventId].join('/') : "events"), {
          data: {
            event: Object.assign(dataForRequest, {
              secret: this.secret
            }),
            dry_run
          },
          method: (this.eventId ? 'patch' : 'post'),
          ignoreErrorCodes: [429]
        }).then(function(result) {
        self.setServerErrors()
        self.$scrollTo('#event-header')

        if (result.status != 204) {
          // not just validating...
          if (self.eventId) {
            self.$refs.eventUpdatedModal.show()
          } else {
            self.eventCreated = true
            self.createdEventId = result.data.data.id
            self.createdEventSecret = result.data.data.secret
            self.assignEventData(result.data.data)
            self.$refs.eventCreatedModal.show()
          }
        }
      }, function(error) {
        if (error.response) {
          if (error.response.status == 422) {
            self.setServerErrors(error.response.data.errors)
            if (self.firstStepWithErrors && self.firstStepWithErrors <= self.step) {
              self.showErrorCodeInErrorBar(error.response.status)
            }
          } else if (error.response.status == 429) {
            self.showInErrorBar(self.$i18n.t('event_editor.too_many_requests_error', {
              email: dataForRequest["email"]
            }))
          }
        } else {
          throw error
        }
      })
    },
    nextStep() {
      this.saveEvent(this.step < this.maxStep).then(() => {
        this.step = Math.min(this.step + 1, this.maxStep, this.firstStepWithErrors || this.maxStep)
      })
    },
    prevStep() {
      if (this.step > this.minStep) {
        this.step--
      }
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
      })
    }
  }
}
</script>

