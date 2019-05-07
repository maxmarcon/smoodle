import errorPage from '../../vue/errorPage.vue'
import BootstrapVue from 'bootstrap-vue'
import VueRouter from 'vue-router'

import {
	mount,
	createLocalVue,
	RouterLinkStub
} from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue);

const ERROR_MSG = "This is an error"

describe('errorPage', () => {

	let wrapper

	beforeEach(() => {

		wrapper = mount(errorPage, {
			mocks: {
				$t: (k) => k
			},
			localVue,
			propsData: {
				message: ERROR_MSG
			},
			stubs: {
				'router-link': RouterLinkStub
			}
		})
	})

	it('displays the error message', () => {
		expect(wrapper.find('.card-body h5').html()).toBe(`<h5 class="mt-3"><strong>${ERROR_MSG}</strong></h5>`)
	})

	it('displays a link to the home route', () => {
		expect(wrapper.find(RouterLinkStub).props('to')).toEqual({
			'name': 'home'
		})
	})
})
