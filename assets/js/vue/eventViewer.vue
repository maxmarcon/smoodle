<template lang="pug">
	div
		message-bar(ref="errorBar" variant="danger")
		.card
			.card-header
				.row.justify-content-center
					.col-auto
						h5 {{ eventName }}
				.row
					.col-md-4
						h6.text-muted Organizer:
					.col-md-8
						h6 {{ eventOrganizer }}
				.row
					.col-md-4
						h6.text-muted Event description:
					.col-md-8
						h6 {{ eventDesc }}
				.row
					.col-md-4
						h6.text-muted When can it take place:
					.col-md-8
						h6 {{ timeWindow }}
				hr.my-3

</template>
<script>
import dateFns from 'date-fns'
import { fetchEventMixin } from '../globals'

export default {
	mixins: [fetchEventMixin],
	props: {
		eventId: {
			type: String,
			required: true
		},
	},
	data: () => ({
		eventName: null,
		eventOrganizer: null,
		evendDesc: null,
		eventTimeWindowFrom: null,
		eventTimeWindowTo: null,
	}),
	created() {
		let self = this;
		this.fetchEvent(this.eventId).then(function(eventData) {
			if (eventData) {
				self.eventName = eventData.name;
				self.eventOrganizer = eventData.organizer;
				self.eventDesc = eventData.desc;
				self.eventTimeWindowFrom = eventData.time_window_from;
				self.eventTimeWindowTo = eventData.time_window_to;
				//self.$refs.welcomeModal.show();
			}
		});
	},
	computed: {
		timeWindow() {
			return dateFns.format(this.eventTimeWindowFrom, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')})
			 + " - " +
			 dateFns.format(this.eventTimeWindowTo, 'DD/MM/YYYY (ddd)', {locale: this.$i18n.t('date_fns_locale')});
		}
	}
}
</script>