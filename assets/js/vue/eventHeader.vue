<template lang="pug">
	div
		.d-flex.justify-content-between
			h5.card-title {{ name || $t('event_header.no_name') }}
			small.text-muted {{ organizer ? $t('event_header.by', {organizer: organizer}) : '' }}
		h6.card-subtitle.text-muted {{ timeWindow || $t('event_header.no_dates') }}
</template>
<script>
import { timeWindowMixin } from '../globals'

export default {
	mixins: [timeWindowMixin],
	props: {
		name: String,
		organizer: String,
		timeWindowFrom: [String, Date],
		timeWindowTo: [String, Date]
	}
}

</script>
