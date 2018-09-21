import Home from '../../vue/home.vue'
import BootstrapVue from 'bootstrap-vue'
import VueRouter from 'vue-router'

import {
	mount,
	createLocalVue
} from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue);
localVue.use(VueRouter);

const router = new VueRouter({
	mode: 'history',
	routes: [{
		path: '/events/new',
		name: 'new_event'
	}]
});

describe('Home', () => {

	const wrapper = mount(Home, {
		mocks: {
			$t: () => "",
			$tc: () => ""
		},
		localVue,
		router,
		stubs: [
			'i18n'
		]
	});

	it('renders a link to the new_event route', () => {
		expect(wrapper.find('a[href="/events/new"]').exists()).toBeTruthy()
	});
});