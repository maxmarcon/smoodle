<template lang="pug">
ul.list-group
	li.d-flex.list-group-item.p-2.align-items-center(v-for="el in elements" :class="{disabled: el.disabled}" @click="clicked(el)")
		h6.mr-auto {{ $t(el.name) }}
		p-check.p-switch.p-fill(v-if="boolean" v-model="el.value" color="success" :disabled="el.disabled || disabled" @change="changed")
		.d-flex(v-else)
			p-radio.p-icon.p-plain(:name="el.name" :value="el.disabled ? null : 1" v-model="el.value" :disabled="el.disabled || disabled" toggle @change="changed")
				i.icon.fas.fa-thumbs-up.text-success(slot="extra")
				i.icon.far.fa-thumbs-up(slot="off-extra")
				label(slot="off-label")
			p-radio.p-icon.p-plain(:name="el.name" :value="el.disabled ? null : 0" v-model="el.value" :disabled="el.disabled || disabled" toggle @change="changed")
				i.icon.fas.fa-circle.text-warning(slot="extra")
				i.icon.far.fa-circle(slot="off-extra")
				label(slot="off-label")
			p-radio.p-icon.p-plain(:name="el.name" :value="el.disabled ? null : -1" v-model="el.value" :disabled="el.disabled || disabled" toggle @change="changed")
				i.icon.fas.fa-thumbs-down.text-danger(slot="extra")
				i.icon.far.fa-thumbs-down(slot="off-extra")
				label(slot="off-label")

</template>
<script>
export default {
	props: {
		boolean: {
			type: Boolean,
			default: false
		},
		disabled: {
			type: Boolean,
			default: false
		},
		elements: {
			type: Array,
			required: true,
			validator: (value) => {
				return value.every((el) =>
					el instanceof Object && el.hasOwnProperty('value') && el.hasOwnProperty('name')
				);
			}
		}
	},
	methods: {
		changed() {
			this.$emit('change')
		},
        clicked(el) {
		    if (!el.disabled && !this.disabled && this.boolean) {
		        el.value = !el.value
            }
        }
	}
}
</script>
