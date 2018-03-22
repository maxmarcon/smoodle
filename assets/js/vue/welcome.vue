<template lang="pug">
	button(v-on:click="schedule" class="btn btn-lg btn-primary" type="button") {{ scheduleButtonText }}
</template>

<script>
export default {
	props: ['scheduleButtonText'],
	methods: {
		schedule: (event) => alert('schedule!!!')
	}
}
</script>