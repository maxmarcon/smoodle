<template lang="pug">
    b-card(no-body :border-variant="borderVariant")
        b-modal#name-list-modal(
            v-if="participantsList"
            static=true
            ok-only
        )
            template(v-slot:modal-header)
                .d-flex
                    b
                        i.icon.fas.fa-thumbs-up.text-success(v-if="positive")
                        i.icon.fas.fa-thumbs-down.text-danger(v-else)
                        | &nbsp; {{ formattedDate }}
            p {{ nameList(participantsList) }}

        b-card-header
            .d-flex
                b-button.mr-3(pill variant="light" @click="$emit('close')") &nbsp;
                    i.fas.fa-2x.fa-arrow-circle-left
                    | &nbsp;
                div.text-left
                    b-card-title {{ formattedDate }}
                    b-card-sub-title
                        b-badge.mr-1(v-if="dateEntry.optimal" variant="primary") {{ $i18n.t('event_viewer.optimal_date') }}
                        b-badge(:variant="dateEntry.negative_rank < 0 ? 'danger' : 'success'") {{ this.textForDate(dateEntry, 0) }}
        b-card-body
            b-row(no-gutters)
                b-col(v-if="dateEntry.negative_rank < 0")
                    i.icon.fas.fa-thumbs-down.text-danger
                    | &nbsp; {{ negativeParticipantsText(dateEntry, MAX_NAMES) }}
                    button.btn.btn-link(
                        v-if="excessParticipants(dateEntry.negative_participants)"
                        @click="showAllParticipants(dateEntry.negative_participants, false)"
                    ) {{ $t('actions.show_all') }}
                b-col(v-if="dateEntry.positive_rank > 0 || dateEntry.negative_rank == 0")
                    i.icon.fas.fa-thumbs-up.text-success
                    | &nbsp; {{ positiveParticipantsText(dateEntry, MAX_NAMES) }}
                    button.btn.btn-link(
                        v-if="excessParticipants(dateEntry.positive_participants)"
                        @click="showAllParticipants(dateEntry.positive_participants, true)"
                    ) {{ $t('actions.show_all') }}

        b-card-footer(v-if="isOrganizer")
            button.btn.btn-primary(@click="$emit('schedule', dateEntry.date)")
                i.fas.fa-calendar-alt
                | &nbsp; {{ $t('event_viewer.schedule_event') }}

</template>
<script>
    import * as dateFns from 'date-fns'
    import EventHelpersMixin from '../mixins/event-helpers'

    const MAX_NAMES = 5

    export default {
        mixins: [EventHelpersMixin],
        props: {
            isOrganizer: Boolean,
            calendarAttribute: Object
        },
        data: () => ({
            participantsList: null,
            positive: true,
            MAX_NAMES
        }),
        computed: {
            opacity() {
                return this.calendarAttribute.highlight.opacity
            },
            dateEntry() {
                return this.calendarAttribute.customData
            },
            borderVariant() {
                if (this.dateEntry.optimal) {
                    return "primary"
                }
                if (this.dateEntry.negative_rank < 0) {
                    return "danger"
                }
                return "success";
            },
            formattedDate() {
                return dateFns.format(this.dateEntry.date, this.$i18n.t('date_format_long'), {locale: this.$i18n.t('date_fns_locale')});
            }
        },
        methods: {
            excessParticipants(participants) {
                return participants && participants.length > MAX_NAMES
            },
            showAllParticipants(participants, positive) {
                this.participantsList = participants;
                this.positive = positive
                this.$bvModal.show('name-list-modal')
            }
        }
    }
</script>
