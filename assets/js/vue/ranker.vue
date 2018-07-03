<template lang="pug">
ul.list-group
	li.d-flex.list-group-item.p-2(v-for="(el,index) in elements")
		h6.text-info.mr-auto.align-self-center {{ el.name }}
		p-radio.p-plain(:name="el.name" :value="2" v-model="el.rank" toggle)
			i.icon.oi.oi-heart.text-success(slot="extra")
			i.icon.oi.oi-heart(slot="off-extra")
		p-radio.p-plain(:name="el.name" :value="1" v-model="el.rank" toggle)
			i.icon.oi.oi-thumb-up.text-warning(slot="extra")
			i.icon.oi.oi-thumb-up(slot="off-extra")
		p-radio.p-plain(:name="el.name" :value="0" v-model="el.rank" toggle)
			i.icon.oi.oi-thumb-down.text-danger(slot="extra")
			i.icon.oi.oi-thumb-down(slot="off-extra")

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
	},
	methods: {
		ppp() {
			console.dir(this.rankedDays);

		}
	}
}
</script>