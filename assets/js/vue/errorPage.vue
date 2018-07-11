<template lang="pug">
.card
	.card-body.text-center
		i.fas.fa-exclamation-triangle.fa-3x
		h5.mt-3
			strong {{ message }}
	.card-footer
		slot
			.text-center
				button.btn.btn-secondary
					i.fas.fa-ban
					| &nbsp; Back home but there is none yet...
</template>
<script>
export default {
	props: {
		message: {
			type: String,
			required: true
		}
	}
}
</script>