import VueApp from '../app.js'

import {
	shallowMount
} from '@vue/test-utils'

it('can mount the app', () => {
	const wrapper = shallowMount(VueApp)

	expect(wrapper.isVueInstance()).toBe(true)
})
