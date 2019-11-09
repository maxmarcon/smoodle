import errorPage from '../../src/components/error-page.vue'
import BootstrapVue from 'bootstrap-vue'
import i18nMock from "../test-utils/i18n-mock";
import {
	mount,
	createLocalVue,
	RouterLinkStub
} from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue);

const ERROR_MSG = "This is an error"

let wrapper

describe('errorPage', () => {

	beforeEach(() => {

		wrapper = mount(errorPage, {
			mocks: {
				$t: i18nMock.t,
				$tc: i18nMock.tc,
				$18n: i18nMock
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
