<template lang="pug">
    b-card(no-body :border-variant="borderVariant")
        b-card-header
            .d-flex.justify-content-between
                div.text-left
                    b-card-title {{ formattedDate }}
                    b-card-sub-title
                        b-badge.mr-1(v-if="dateEntry.optimal" variant="primary") {{ $i18n.t('event_viewer.optimal_date') }}
                        b-badge(:variant="dateEntry.negative_rank < 0 ? 'danger' : 'success'") {{ this.textForDate(dateEntry, true, true) }}
                button.btn.btn-outline-dark(@click="$emit('close')")
                    i.fas.fa-times
        b-row(no-gutters)
            b-col(v-if="dateEntry.negative_rank < 0")
                b-card-body
                    i.icon.fas.fa-thumbs-down.text-danger
                    | &nbsp; {{ negativeParticipantsText(dateEntry) }}
            b-col(v-if="dateEntry.positive_rank > 0 || dateEntry.negative_rank == 0")
                b-card-body
                    i.icon.fas.fa-thumbs-up.text-success
                    | &nbsp; {{ positiveParticipantsText(dateEntry) }}

        b-card-footer(v-if="isOrganizer")
            button.btn.btn-primary(@click="$emit('schedule', dateEntry.date)")
                i.fas.fa-calendar-alt
                | &nbsp; {{ $t('event_viewer.schedule_event') }}

</template>
<script>
    import * as dateFns from 'date-fns'
    import {colorCodes} from '../constants'
    import EventHelpersMixin from '../mixins/event-helpers'

    export default {
        mixins: [EventHelpersMixin],
        props: {
            isOrganizer: Boolean,
            calendarAttribute: Object
        },
        data: () => ({
            colorCodes
        }),
        computed: {
            backgroundColor() {
                return this.calendarAttribute.highlight.backgroundColor
            },
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
        }
    }
</script>
