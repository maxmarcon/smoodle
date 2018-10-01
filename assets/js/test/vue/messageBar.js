import messageBar from '../../vue/messageBar.vue'
import BootstrapVue from 'bootstrap-vue'

import {
	mount,
	createLocalVue,
	shallowMount
} from '@vue/test-utils'


const localVue = createLocalVue();
localVue.use(BootstrapVue)

const MESSAGE = "I'm a message"
const VARIANT = 'danger'
const SECONDS = 10

describe('messageBar', () => {

	let wrapper
	let alert

	describe('without countdown', () => {

		beforeEach(() => {

			wrapper = shallowMount(messageBar, {
				localVue,
				propsData: {
					seconds: 0,
					variant: VARIANT
				}
			})

			wrapper.vm.show(MESSAGE)

			alert = wrapper.find('balert-stub')
		})

		it('shows a permanent dismissable message', () => {
			expect(alert.attributes('show')).toBe('true')
			expect(alert.attributes('dismissible')).toBeTruthy()
			expect(alert.attributes('variant')).toBe(VARIANT)
			expect(alert.text()).toBe(MESSAGE)
		})
	})

	describe('with countdown', () => {

		beforeEach(() => {

			wrapper = shallowMount(messageBar, {
				localVue,
				propsData: {
					seconds: SECONDS,
					variant: VARIANT
				}
			})

			wrapper.vm.show(MESSAGE)

			alert = wrapper.find('balert-stub')
		})

		it('shows a message with countdown', () => {
			expect(alert.attributes('show')).toEqual(SECONDS.toString())
			expect(alert.attributes('dismissible')).toBeFalsy()
			expect(alert.attributes('variant')).toBe(VARIANT)
			expect(alert.text()).toBe(MESSAGE)
		})
	})

	describe('the countdoown', () => {

		beforeEach(() => {

			jasmine.clock().install();

			wrapper = mount(messageBar, {
				localVue,
				propsData: {
					seconds: SECONDS,
					variant: VARIANT
				}
			})

			wrapper.vm.show(MESSAGE)

			jasmine.clock().tick(SECONDS * 1010)
		})

		afterEach(() => {
			jasmine.clock().uninstall()
		})

		it('can count down', () => {
			expect(wrapper.vm.dismissCountDown).toBeFalsy()
		})
	})
})