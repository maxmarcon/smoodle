import rootVue from '../../vue/root.vue'
import BootstrapVue from 'bootstrap-vue'
import VueRouter from 'vue-router'

import {
	mount,
	createLocalVue,
	RouterLinkStub
} from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue);
localVue.use(VueRouter);

const router = new VueRouter({
	mode: 'history',
	routes: [{
		path: '/home',
		name: 'home'
	}, {
		path: '/events/new',
		name: 'new_event'
	}]
});

describe('rootVue', () => {

	let wrapper;

	beforeEach(() => {
		wrapper = mount(rootVue, {
			mocks: {
				$t: () => "",
				$i18n: {
					locale: 'default'
				}
			},
			stubs: {
				RouterLink: RouterLinkStub
			},
			localVue,
			router
		});
	})

	it('renders a link to the home route', () => {
		expect(wrapper.findAll(RouterLinkStub).at(0).props().to).toEqual({
			name: 'home'
		})
	});

	it('renders a link to the new_event route', () => {
		expect(wrapper.findAll(RouterLinkStub).at(1).props().to).toEqual({
			name: 'new_event'
		})
	});

	it('can change the locale to en', () => {
		wrapper.findAll('button.dropdown-item').at(0).trigger('click');
		expect(wrapper.vm.$i18n.locale).toBe('en');
	})

	it('can change the locale to de', () => {
		wrapper.findAll('button.dropdown-item').at(1).trigger('click');
		expect(wrapper.vm.$i18n.locale).toBe('de');
	})

	it('can change the locale to it', () => {
		wrapper.findAll('button.dropdown-item').at(2).trigger('click');
		expect(wrapper.vm.$i18n.locale).toBe('it');
	})

	it('can retrieve the locale', () => {
		expect(wrapper.vm.getLocale()).toBe(wrapper.vm.$i18n.locale);
	})
});
