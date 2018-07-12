<template lang="pug">
ul.list-group
	li.d-flex.list-group-item.p-2.align-items-center(v-for="el in elements")
		h6.text-info.mr-auto {{ el.name }}
		p-radio.p-icon.p-plain(:name="el.name" :value="1" v-model="el.rank" toggle)
			i.icon.fas.fa-heart.text-success(slot="extra")
			i.icon.far.fa-heart(slot="off-extra")
			label(slot="off-label")
		p-radio.p-icon.p-plain(:name="el.name" :value="0" v-model="el.rank" toggle)
			i.icon.fas.fa-thumbs-up.text-warning(slot="extra")
			i.icon.far.fa-thumbs-up(slot="off-extra")
			label(slot="off-label")
		p-radio.p-icon.p-plain(:name="el.name" :value="-1" v-model="el.rank" toggle)
			i.icon.fas.fa-thumbs-down.text-danger(slot="extra")
			i.icon.far.fa-thumbs-down(slot="off-extra")
			label(slot="off-label")
</template>
<script>
export default {
	props: {
		elements: {
			type: Array,
			required: true,
			validator: (value) => {
				return value.every((el) =>
					el instanceof Object && el.hasOwnProperty('rank') && el.hasOwnProperty('name')
				);
			}
		}
	}
}
</script>