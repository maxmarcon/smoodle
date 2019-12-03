<template lang="pug">
    div
        message-bar(ref="errorBar" variant="danger")
        b-modal#update-answer-modal(
            static=true
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

        b-modal#clipboard-modal(staic=true hide-header ok-only)
            p {{ $t('event_editor.link_copied') }}

        b-modal#cancel-event-modal(
            static=true
            :title="$t('event_viewer.cancel_event')"
            :ok-title="$t('event_viewer.cancel_event')"
            :cancel-title="$t('actions.do_not_cancel')"
            @ok="cancelEvent"
        )
            p {{ $t('event_viewer.really_cancel_event') }}

            .form-group
                label(for=cancelOrganizerMessage) {{ $t('event_viewer.organizer_message') }}
                textarea#cancelOrganizerMessage.form-control(v-model.trim="organizerMessage")

        b-modal#event-canceled-modal(
            static=true
            :title="$t('event_viewer.cancel_event')"
            ok-only
        )
            p {{ $t('event_viewer.event_canceled_ok') }}

        b-modal#event-cancel-error-modal(
            static=true
            :title="$t('errors.error')"
            ok-only
        )
            p {{ $t('event_viewer.cancel_event_error') }}

        b-modal#event-opened-modal(
            static=true
            :title="$t('event_viewer.open_event')"
            ok-only
        )
            p {{ $t('event_viewer.event_opened_ok') }}

        b-modal#event-open-error-modal(
            static=true
            :title="$t('errors.error')"
            ok-only
        )
            p {{ $t('event_viewer.open_event_error') }}

        b-modal#participants-list-modal(
            static=true
            :title="$t('event_viewer.current_participants')"
            ok-only
        )
            p {{ nameList(eventScheduleParticipants) }}

        b-modal#schedule-event-modal(
            static=true
            :title="$t('event_viewer.schedule_event')"
            :cancel-title="$t('actions.cancel')"
            :ok-disabled="requestOngoing"
            @ok="scheduleEvent"
        )
            div(v-if="selectedDate")
                .alert.alert-danger(v-if="selectedDateNegativeRank < 0")
                    | {{ $tc('event_viewer.warning_bad_date', -selectedDateNegativeRank, {participants: -selectedDateNegativeRank}) }}
                .alert.alert-info {{ $t('event_viewer.about_to_schedule', {date: selectedDateFormatted}) }}

                .justify-content-center
                    .form-group
                        label {{ $t('event_viewer.select_time') }}
                        date-picker#timePicker(
                            v-model="selectedTime"
                            :config="timePickerOptions"
                        )
                .form-group
                    label(for=scheduleOrganizerMessage) {{ $t('event_viewer.organizer_message') }}
                    textarea#scheduleOrganizerMessage.form-control(v-model.trim="organizerMessage")


        b-modal#scheduled-event-modal(
            satic=true
            :title="$t('event_viewer.schedule_event')"
            ok-only
        )
            p {{ $t('event_viewer.event_scheduled_organizer', {datetime: eventScheduledDateTime, time_distance: eventScheduledDateTimeRelative}) }}

        b-modal#schedule-rvent-rrror-modal(
            static=true
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
                        div(v-else-if="loaded")
                            .alert.alert-info(v-if="eventScheduleParticipantsCount")
                                i18n(:path="isOrganizer ? 'event_viewer.event_open_organizer' : 'event_viewer.event_open_public_participants'" v-if="eventPublicParticipants || isOrganizer")
                                    template(v-slot:calendar_icon)
                                        i.fas.fa-calendar-check.fa-lg
                                    template(v-slot:participants)
                                        a(href="#" v-b-modal.participants-list-modal="")
                                            | {{ $tc('event_viewer.nof_participants', eventScheduleParticipantsCount, {participants: eventScheduleParticipantsCount}) }}

                                i18n(path="event_viewer.event_open" v-else)
                                    template(v-slot:calendar_icon)
                                        i.fas.fa-calendar-check.fa-lg
                                    template(v-slot:answers)
                                        span {{ $tc('event_viewer.answers', eventScheduleParticipantsCount, {count: eventScheduleParticipantsCount}) }}
                            div.alert.alert-primary(v-else)
                                i18n(path="event_viewer.no_participants_organizer" v-if="isOrganizer")
                                    template(v-slot="icon")
                                        i.fas.fa-thermometer-empty.fa-lg
                                i18n(path="event_viewer.no_participants" v-else)
                                    template(v-slot="icon")
                                        i.fas.fa-trophy.fa-lg
                            .row.justify-content-md-between.justify-content-lg-center
                                .col-md-3.offset-md-1.order-md-last.text-justify(v-if="eventScheduleParticipantsCount")
                                    .form-group
                                        i18n.small.text-muted(
                                            :path="isOrganizer ? 'event_viewer.date_selection_help_organizer' : 'event_viewer.date_selection_help'"
                                            tag="p"
                                        )
                                            template(v-slot:best)
                                                span.text-success {{ $t('event_viewer.best') }}
                                            template(v-slot:worst)
                                                span.text-danger {{ $t('event_viewer.worst') }}
                                            template(v-slot:green)
                                                span.text-success {{ $t('event_viewer.green') }}
                                            template(v-slot:red)
                                                span.text-danger {{ $t('event_viewer.red') }}
                                            template(v-slot:blue_underlined)
                                                span.text-primary {{ $t('event_viewer.blue_underlined') }}

                                .col-md-6.text-center
                                    .form-group
                                        b-carousel(ref="calendarCarousel" :interval="0" no-touch)
                                            b-carousel-slide
                                                template(v-slot:img)
                                                    v-calendar(
                                                        :is-linked="true"
                                                        nav-visibility="hidden"
                                                        :attributes="scheduleCalendarAttributes"
                                                        :min-page="fromPage"
                                                        :max-page="toPage"
                                                        :is-double-paned="differentMonths"
                                                        :is-expanded="true"
                                                        :theme-styles="calThemeStyles"
                                                        @dayclick="dayclicked"
                                                    )
                                            b-carousel-slide
                                                template(v-slot:img)
                                                    date-details(
                                                        v-if="dayDetailsCalendarAttribute"
                                                        :isOrganizer="isOrganizer"
                                                        :calendarAttribute="dayDetailsCalendarAttribute"
                                                        @close="$refs.calendarCarousel.prev()"
                                                        @schedule="openScheduleEventModal"
                                                    )




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
                    .col-12.col-sm-auto.mt-1(v-if="eventOpen && isOrganizer")
                        router-link.btn.btn-block.btn-success(
                            name="edit-button"
                            role="button"
                            :to="{ name: 'edit_event', params: {eventId: eventId, secret: secret}, query: {s: secret} }"
                        )
                            i.fas.fa-edit
                            | &nbsp; {{ $t('event_viewer.edit_event') }}
                    .col-12.col-sm-auto.mt-1(v-if="eventOpen && !emptyDomain && isOrganizer")
                        button.btn.btn-block.btn-block.btn-warning(v-b-modal.cancel-event-modal="" :disabled="requestOngoing"
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
                        button.btn.btn-block.btn-primary(v-b-modal.update-answer-modal="" :disabled="requestOngoing" name="edit-poll-button")
                            i.fas.fa-edit
                            | &nbsp; {{ $t('event_viewer.update_poll') }}


        error-page(
            v-else-if="loaded"
            :message="$t('errors.not_found')"
        )
</template>
<script>
    import * as dateFns from 'date-fns'
    import {calThemeStyles, colorCodes} from '../constants'
    import eventHelpersMixin from '../mixins/event-helpers'
    import eventDataMixin from '../mixins/event-data'
    import restMixin from '../mixins/rest'
    import dateDetails from './date-details'
    import {scrollToTopMixin, whatsAppHelpersMixin} from '../mixins/utils'

    const SCHEDULE_DATES_LIMIT = null;
    const EVENT_RELOAD_INTERVAL_MSEC = 15000;

    export default {
        mixins: [
            restMixin,
            eventHelpersMixin,
            eventDataMixin,
            scrollToTopMixin,
            whatsAppHelpersMixin
        ],
        components: {
            'date-details': dateDetails
        },
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
            reloadIntervalId: null,
            dayDetailsCalendarAttribute: null,
            organizerMessage: null
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
                return !!this.secret;
            },
            scheduleCalendarAttributes() {
                if (this.eventScheduleParticipantsCount === 0) {
                    return [{
                        dates: {
                            start: this.minDate,
                            end: this.maxDate
                        },
                        highlight: {
                            backgroundColor: colorCodes.green,
                            opacity: 0.6
                        }
                    }];
                }

                const scheduleDates = this.eventScheduleDates.length;
                let minNegativeRank;
                let maxPositiveRank;
                if (scheduleDates > 0) {
                    minNegativeRank = this.eventScheduleDates[scheduleDates - 1].negative_rank;
                    maxPositiveRank = this.eventScheduleDates[0].positive_rank;
                }
                const limit = (SCHEDULE_DATES_LIMIT !== null ? SCHEDULE_DATES_LIMIT : this.eventScheduleDates.length);
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
                    dates: date_entry.date,
                    highlight: {
                        backgroundColor: (date_entry.negative_rank < 0 ? colorCodes.red : colorCodes.green),
                        opacity: this.opacityForDate(date_entry, minNegativeRank, maxPositiveRank)
                    },
                    bar: (is_top_rank(date_entry) ? {
                        backgroundColor: colorCodes.blue
                    } : false),
                    popover: {
                        label: (attribute) => this.textForDate(attribute.customData, 5)
                    },
                    customData: Object.assign(date_entry, {optimal: is_top_rank(date_entry)})
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
                return dateFns.format(this.selectedDate, this.$i18n.t('date_format_long'), {locale: this.$i18n.t('date_fns_locale')});
            },
            selectedDateNegativeRank() {
                return (this.eventScheduleDates.find(({date}) => dateFns.isEqual(date, this.selectedDate)) || {}).negative_rank
            }
        },
        methods: {
            dayclicked(day) {
                if (this.isInDomain(day.date) && this.eventScheduleParticipantsCount) {
                    this.dayDetailsCalendarAttribute = day.attributes[0]
                    this.$refs.calendarCarousel.next()
                }
            },
            async loadEvent() {
                if (this.loading) {
                    return
                }
                try {
                    this.loading = true;
                    const [eventResult, scheduleResult] = await Promise.all([
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
                    this.assignEventData(eventResult.data.data);
                    this.eventScheduleDates = scheduleResult.data.data.dates.map(({
                                                                                      date,
                                                                                      positive_rank,
                                                                                      positive_participants,
                                                                                      negative_rank,
                                                                                      negative_participants
                                                                                  }) => ({
                        date: dateFns.parseISO(date),
                        positive_rank,
                        positive_participants,
                        negative_rank,
                        negative_participants
                    }));
                    this.eventScheduleParticipants = scheduleResult.data.data.participants;
                    this.eventScheduleParticipantsCount = scheduleResult.data.data.participants_count;
                    this.loadedSuccessfully = true;
                } finally {
                    this.loaded = true
                    this.loading = false
                }
            },
            opacityForDate(date_entry, minNegativeRank, maxPositiveRank) {
                return (date_entry.negative_rank < 0
                    ? date_entry.negative_rank / minNegativeRank
                    : Math.max(date_entry.positive_rank, 0.5) / maxPositiveRank);
            },
            clipboard() {
                this.$bvModal.show('clipboard-modal');
            },
            async loadPoll(bvEvt) {
                bvEvt.preventDefault();
                if (this.pollParticipant) {
                    try {
                        const result = await this.restRequest(['events', this.eventId, 'polls'].join('/'), {
                            params: {
                                participant: this.pollParticipant
                            }
                        })
                        this.pollParticipantError = null
                        this.$router.push({name: 'edit_poll', params: {pollId: result.data.data.id}});
                    } catch (error) {
                        if (error.response && error.response.status === 404) {
                            this.pollParticipantError = this.$i18n.t('event_viewer.update.poll_not_found');
                        } else {
                            throw error;
                        }
                    }
                }
            },
            async openEvent() {
                try {
                    const result = await this.restRequest(['events', this.eventId].join('/'), {
                        method: 'patch',
                        data: {
                            event: {
                                state: "OPEN",
                                secret: this.secret,
                                scheduled_from: null,
                                scheduled_to: null
                            }
                        }
                    })
                    this.assignEventData(result.data.data);
                    this.$bvModal.show('event-opened-modal');
                } catch (error) {
                    this.$bvModal.show('event-open-error-modal');
                    throw error;
                }
            },
            async cancelEvent() {
                try {
                    const result = await this.restRequest(['events', this.eventId].join('/'), {
                        method: 'patch',
                        data: {
                            event: {
                                state: "CANCELED",
                                secret: this.secret,
                                organizer_message: this.organizerMessage
                            }
                        }
                    })
                    this.assignEventData(result.data.data);
                    this.$bvModal.show('event-canceled-modal');
                } catch
                    (error) {
                    this.$bvModal.show('event-cancel-error-modal');
                    throw error;
                }
            },
            openScheduleEventModal(date) {
                this.selectedDate = date;
                this.$bvModal.show('schedule-event-modal');
            },
            async scheduleEvent() {
                if (!this.selectedDate) {
                    return;
                }

                this.dayDetailsCalendarAttribute = null;

                const [hours, minutes] = this.selectedTime.split(':');
                this.selectedDate = dateFns.setHours(
                    dateFns.setMinutes(this.selectedDate, Number(minutes)),
                    Number(hours)
                );

                try {
                    const result = await this.restRequest(['events', this.eventId].join('/'), {
                        method: 'patch',
                        data: {
                            event: {
                                state: 'SCHEDULED',
                                secret: this.secret,
                                scheduled_from: this.selectedDate.toISOString(),
                                scheduled_to: dateFns.addHours(this.selectedDate, 6).toISOString(),
                                organizer_message: this.organizerMessage
                            }
                        }
                    });
                    this.assignEventData(result.data.data);
                    this.$bvModal.show('scheduled-event-modal');
                } catch (error) {
                    this.$bvModal.show('schedule-event-error-modal');
                    throw error;
                }
            }
        }
    }
</script>
