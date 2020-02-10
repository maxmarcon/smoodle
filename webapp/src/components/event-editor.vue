<template lang="pug">
  div
    message-bar(ref="errorBar" variant="danger")
    b-modal#clipboard-modal(static=true hide-header ok-only)
      p {{ $t('event_editor.link_copied') }}
    b-modal#event-created-modal(static=true hide-header ok-only)
      p {{ $t('event_editor.event_created_short') }}
    b-modal#event-updated-modal(static=true hide-header ok-only :ok-title="$t('event_editor.back_to_event')" @ok="backToEvent")
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
            v-if="!eventId && step === errorsMap['organizer-group'].step"
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
            v-if="step === errorsMap['general-info-group'].step"
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
            .form-group.row
              .col-md-9.offset-md-3
                p-check#publicParticipants.p-switch.p-fill(color="success" v-model="eventPublicParticipants") {{ $t('event_editor.event.public_participants') }}
                small.form-text.text-muted {{ $t('event_editor.event.public_participants_help') }}

          b-card(
            v-if="step === errorsMap['dates-group'].step"
            :header-bg-variant="groupBgVariant('dates-group')"
            header-text-variant="white"
          )
            .d-flex(slot="header")
              .flex-grow-1 {{ $t('event_editor.dates_group') }}
              .fas.fa-exclamation(v-if="showGroupErrorIcon('dates-group')")
              .fas.fa-check(v-else-if="showGroupOkIcon('dates-group')")

            .form-group.row.justify-content-center.justify-content-md-between.justify-content-lg-center
              .col-md-9.mb-3.text-center
                .d-flex.justify-content-center.align-items-end
                  label {{ $t(!hasDateRange ? 'event_editor.event.dates_range' : 'event_editor.event.dates_single') }}

                v-date-picker#eventPossibleDates(
                  :mode="!hasDateRange ? 'range' : 'single'"
                  v-model="dateSelection"
                  nav-visibility="hidden"
                  :min-date="today"
                  :is-inline="true"
                  :from-page="initialFromPage"
                  :is-required="true"
                  :columns="$screens({default: 1, md: 2})"
                  :attributes="datePickerAttributes"
                  popover-visibility="hidden"
                  @input="newDate"
                  :is-expanded="true"
                  :locale="$i18n.locale"
                  :drag-attribute="dragAttribute"
                )
                .small.text-danger(name="event-possible-dates-error") {{ eventPossibleDatesError }}

                .d-flex.mt-2.justify-content-center.align-items-center
                  .form-check
                    button.btn.btn-sm.btn-outline-secondary(@click="clearDateInfo" :disabled="!hasDateRange && !undoData")
                      i.fas.fa-undo(v-if="undoData")
                      i.fas.fa-trash-alt(v-else)

              .col-11.col-md-3
                ranker#eventWeekdays(:elements="eventWeekdays" boolean=true :disabled="!hasDateRange" @change="eventWeekdaysChanged")
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
            button.btn.btn-block.btn-secondary(@click="prevStep" :disabled="step === minStep || requestOngoing" name="back-button")
              i.fas.fa-arrow-circle-left
              | &nbsp {{ $t('actions.prev')}}
          .col-12.col-sm-2.mt-1(v-if="eventId && step === minStep")
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
  import * as dateFns from 'date-fns'

  import restMixin from '../mixins/rest';
  import stepValidation from "../mixins/step-validation";
  import errorBar from "../mixins/error-bar";
  import eventData from "../mixins/event-data";
  import eventHelpers from "../mixins/event-helpers";
  import {scrollToTopMixin, whatsAppHelpersMixin} from "../mixins/utils";

  const today = new Date()

  export default {
    mixins: [
      stepValidation,
      restMixin,
      scrollToTopMixin,
      errorBar,
      eventData,
      eventHelpers,
      whatsAppHelpersMixin
    ],
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
        hasDateRange: false,
        dateSelection: null,
        undoData: null,
        step: this.forceStep || 1,
        minStep: 1,
        maxStep: 3,
        dragAttribute: {
          highlight: {
            class: 'bg-success smoodle-opacity-60'
          }
        }
      }
    },
    async created() {
      if (this.eventId) {
        if (this.secret) {
          try {
            const result = await this.restRequest(['events', this.eventId].join('/'), {
              params: {
                secret: this.secret
              }
            })
            this.assignEventData(result.data.data)
            if (this.eventDomain.length === 0) {
              // this could happen if the original possible dates are all in the past
              this.eventPossibleDates = []
            } else {
              this.hasDateRange = true
            }
            this.loadedSuccessfully = true
            this.minStep = 2
            this.step = this.forceStep || this.minStep
          } finally {
            this.loaded = true
          }
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
              class: `${this.classForRank(rank)} ${rank === 0 ? 'smoodle-opacity-60' : 'smoodle-opacity-100'}`,
            },
            order: (rank === 0 ? 0 : 2)
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
            class: `${this.classForRank(-1)} smoodle-opacity-60`
          },
          order: 1
        }])
      }
    },
    methods: {
      classForRank: (rank) => (rank >= 0 ? 'bg-success' : 'bg-danger'),
      customValidate(fieldName, fieldVal) {
        if (fieldName === 'eventWeekdays') {
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
        // done in the next update cycle otherwise ineffective
        // when called from the newDate handler
        setTimeout(() => this.dateSelection = null, 0)
      },
      clearDateInfo() {
        this.clearDateSelection()
        if (this.undoData) {
          this.eventPossibleDates = this.undoData.eventPossibleDates
          this.eventWeekdays = this.undoData.eventWeekdays
          this.hasDateRange = true
          this.undoData = null
        } else {
          this.undoData = {
            eventPossibleDates: this.eventPossibleDates,
            eventWeekdays: this.eventWeekdays
          }
          this.eventPossibleDates = []
          this.eventWeekdays = this.initialWeekdays()
          this.hasDateRange = false
        }
      },
      newDate(value) {
        // console.log("newDate = " + value)
        // console.log("dateSelection = " + this.dateSelection)

        if (!value) {
          return
        }

        if (!this.hasDateRange && value.start && value.end) {

          this.eventPossibleDates = [{
            date_from: value.start,
            date_to: value.end,
            rank: 0
          }]
          this.hasDateRange = true
          this.undoData = null
          this.clearDateSelection()
          this.localValidation()

        } else if (value instanceof Date) {

          let containingIndex = this.eventPossibleDates.findIndex(
            ({
               date_from,
               date_to
             }) => dateFns.isWithinInterval(value, {
              start: date_from,
              end: date_to
            }))

          const insertDay = !this.isInDomain(value);

          if (containingIndex > -1) {

            let containingElement = this.eventPossibleDates[containingIndex]

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

          if (insertDay) {
            this.eventPossibleDates.push({
              date_from: value,
              date_to: value,
              rank: 1
            })
          }

          if (this.eventPossibleDates.length === 0) {
            this.hasDateRange = false
          }

          this.clearDateSelection()

          this.normalizePossibleDates()
        }

        //DEBUG
        // console.dir(this.eventPossibleDates)
        // console.dir(this.eventDomain)
        // console.log("dateSelection = " + this.dateSelection)
      },
      clipboard() {
        this.$bvModal.show('clipboard-modal')
      },
      async saveEvent(dry_run = false) {
        let dataForRequest = this.eventDataForRequest
        if (this.eventId) {
          /// updating, let us not resent email or organizer
          delete dataForRequest['organizer']
          delete dataForRequest['email']
        }
        try {
          const result = await this.restRequest(
            (this.eventId ? ["events", this.eventId].join('/') : "events"), {
              data: {
                event: Object.assign(dataForRequest, {
                  secret: this.secret
                }),
                dry_run
              },
              method: (this.eventId ? 'patch' : 'post'),
              ignoreErrorCodes: [429]
            })
          this.setServerErrors()
          this.scrollToTop();

          if (result.status !== 204) {
            // not just validating...
            if (this.eventId) {
              this.$bvModal.show('event-updated-modal')
            } else {
              this.eventCreated = true
              this.createdEventId = result.data.data.id
              this.createdEventSecret = result.data.data.secret
              this.assignEventData(result.data.data)
              this.$bvModal.show('event-created-modal')
            }
          }
        } catch (error) {
          if (error.response) {
            if (error.response.status === 422) {
              this.setServerErrors(error.response.data.errors)
              if (this.firstStepWithErrors && this.firstStepWithErrors <= this.step) {
                this.showErrorCodeInErrorBar(error.response.status)
              }
            } else if (error.response.status === 429) {
              this.showInErrorBar(this.$i18n.t('event_editor.too_many_requests_error', {
                email: dataForRequest["email"]
              }))
            }
          } else {
            throw error
          }
        }
      },
      async nextStep() {
        await this.saveEvent(this.step < this.maxStep)
        this.step = Math.min(this.step + 1, this.maxStep, this.firstStepWithErrors || this.maxStep)
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

