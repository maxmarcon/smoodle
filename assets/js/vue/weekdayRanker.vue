<template lang="pug">
div
	li.list-group-item.d-flex.justify-content-between(v-for="(day, index) in days")
		h5(:class="isWeekend(index) ? 'text-success' : 'text-info'") {{ day }}
		toggle-button(
			v-model="rankedDays[index]"
			@change="ppp"
			:color="isWeekend(index) ? '#28a745' : '#17a2b8'"
		)

</template>
<script>
export default {
	props: {
		days: {
			type: Array,
			required: true
		}
	},
	computed: {
		rankedDays() {
			return this.days.map(() => false);
		}
	},
	methods: {
		isWeekend: (index) => {
			return index >= 5;
		},
		ppp() {
			console.dir(this.rankedDays);
		}
	}
}


</script>