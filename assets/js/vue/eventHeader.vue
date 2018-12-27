<template lang="pug">
	div
		.d-flex.justify-content-between
			h5.card-title(:class="{'text-muted': !eventName, 'font-italic': !eventName}") {{ eventName || $t('event_header.no_name') }}
			small {{ eventOrganizer ? $t('event_header.by', {organizer: eventOrganizer }) : '' }}
		.d-flex.justify-content-between
			h6.card-subtitle(:class="{'text-muted': noDates, 'font-italic': noDates}") {{ stateDesc }}
</template>
<script>
import {
	eventHelpersMixin
} from '../globals'

export default {
	mixins: [eventHelpersMixin],
	props: {
		eventName: String,
		eventOrganizer: String,
		eventTimeWindow: String,
		eventScheduledFrom: [String, Date],
		eventScheduledTo: [String, Date],
		eventState: String
	},
	computed: {
		noDates() {
			return (this.eventOpen && !this.eventTimeWindow);
		},
		stateDesc() {
			if (this.eventOpen) {
				if (this.eventTimeWindow) {
					return this.$i18n.t('event_header.open', {
						dates: this.eventTimeWindow
					});
				} else {
					return this.$i18n.t('event_header.no_dates');
				}
			} else if (this.eventScheduled) {
				return this.$i18n.t('event_header.scheduled', {
					time: this.eventScheduledDateTime
				});
			} else {
				return this.$i18n.t('event_header.canceled');
			}
		}
	}
}
</script>
