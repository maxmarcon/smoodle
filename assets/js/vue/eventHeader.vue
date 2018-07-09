<template lang="pug">
	div
		.d-flex.justify-content-between
			h5.card-title {{ name }}
			small.text-muted {{ $t('event_by', {organizer: organizer}) }}
		h6.card-subtitle.text-muted {{ timeWindow }}
</template>
<script>
import { timeWindowMixin } from '../globals'

export default {
	mixins: [timeWindowMixin],
	props: {
		name: {
			type: String,
			required: true
		},
		organizer: {
			type: String,
			required: true
		},
		timeWindowFrom: String,
		timeWindowTo: String
	}
}

</script>
