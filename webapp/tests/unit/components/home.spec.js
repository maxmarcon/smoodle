import Home from '@/components/home.vue'
import BootstrapVue from 'bootstrap-vue'

import {
	mount,
	createLocalVue,
	RouterLinkStub
} from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue);

describe('Home', () => {

	const wrapper = mount(Home, {
		mocks: {
			$t: () => "",
			$tc: () => ""
		},
		localVue,
		stubs: {
			'i18n': true,
			'router-link': RouterLinkStub
		}
	});

	it('renders a link to the new_event route', () => {
		expect(wrapper.find(RouterLinkStub).props('to')).toEqual({
			name: 'new_event'
		})
	});
});
