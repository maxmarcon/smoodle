<template lang="pug">
	.card
		.card-header
			strong You can change your availability here for {{ eventName }}
</template>
<script>

function fetchEvent() {
	let self = this;
	this.$http.get("/v1/events/" + this.$route.params.event_id
	,{
		headers: { 'Accept-Language': this.$i18n.locale }
	}).then(function(result) {
		self.eventName = result.data.data.name;
	}, function(result) {
		console.dir(result);
	});
}

export default {
	data: () => ({
		eventName: null
	}),
	created() {
		fetchEvent.call(this);
	}
}
</script>