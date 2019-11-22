<template lang="pug">
    b-card(no-body :border-variant="borderAndHeaderVariant")
        b-card-header(:header-bg-variant="borderAndHeaderVariant")
            .d-flex.justify-content-between
                em.font-weight-bold {{ header }}
                button.btn.btn-outline-dark(@click="$emit('close')")
                    i.fas.fa-times
        b-card-body(:style="{background: backgroundColor, opacity}") {{ textForDate(dateEntry, isOrganizer) }}
        b-card-footer(v-if="isOrganizer")
            button.btn.btn-primary(@click="$emit('schedule', dateEntry.date)")
                i.fas.fa-clock
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
            borderAndHeaderVariant() {
                if (this.calendarAttribute.bar) {
                    return "primary"
                }
                return null;
            },
            header() {
                return dateFns.format(this.dateEntry.date, this.$i18n.t('date_format_long'), {locale: this.$i18n.t('date_fns_locale')});
            }
        }
    }
</script>
