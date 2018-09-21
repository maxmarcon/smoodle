import rootVue from '../../vue/root.vue'
import BootstrapVue from 'bootstrap-vue'
import VueRouter from 'vue-router'
import { mount, createLocalVue } from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue);
localVue.use(VueRouter);

const router = new VueRouter({
	mode: 'history',
	routes: [
		{
			path: '/home',
			name: 'home'
		},
		{
	  	path: '/events/new',
	  	name: 'new_event'
	  }
	]
});

describe('rootVue', () => {

	const wrapper = mount(rootVue, {
		mocks: {
			$t: () => "",
			$i18n: { locale: 'default' }
		},
		localVue,
		router
	});

	it('renders a link to the home route', () => {
		expect(wrapper.find('a[href="/home"]').exists()).toBeTruthy()
	});

	it('renders a link to the new_event route', () => {
		expect(wrapper.find('a[href="/events/new"]').exists()).toBeTruthy()
	});

	it('can change the locale to en', () => {
		wrapper.find('button.dropdown-item:nth-of-type(1)').trigger('click');
		expect(wrapper.vm.$i18n.locale).toBe('en');
	})

	it('can change the locale to de', () => {
		wrapper.find('button.dropdown-item:nth-of-type(2)').trigger('click');
		expect(wrapper.vm.$i18n.locale).toBe('de');
	})

	it('can change the locale to it', () => {
		wrapper.find('button.dropdown-item:nth-of-type(3)').trigger('click');
		expect(wrapper.vm.$i18n.locale).toBe('it');
	})

	it('can retrieve the locale', () => {
		expect(wrapper.vm.getLocale()).toBe(wrapper.vm.$i18n.locale);
	})
});