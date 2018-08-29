<template lang="pug">
	div
		.d-flex.justify-content-between
			h5.card-title {{ name || $t('event_header.no_name') }}
			small {{ organizer ? $t('event_header.by', {organizer: organizer}) : '' }}
		.d-flex.justify-content-between
			h6.card-subtitle {{ stateDesc }}
</template>
<script>
import { eventHelpersMixin } from '../globals'

export default {
	mixins: [eventHelpersMixin],
	props: {
		name: String,
		organizer: String,
		eventTimeWindowFrom: [String, Date],
		eventTimeWindowTo: [String, Date],
		eventScheduledFrom: [String, Date],
		eventScheduledTo: [String, Date],
		eventState: String
	},
	computed: {
		stateDesc() {
			if (this.eventOpen) {
				if (this.eventTimeWindow) {
					return this.$i18n.t('event_header.open', {dates: this.eventTimeWindow});
				} else {
					return this.$i18n.t('event_header.no_dates');
				}
			} else if (this.eventScheduled) {
				return this.$i18n.t('event_header.scheduled', {time: this.eventScheduledDateTime});
			} else {
				return this.$i18n.t('event_header.canceled');
			}
		}
	}
}

</script>
