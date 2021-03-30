import app from '@/components/app'
import BootstrapVue from 'bootstrap-vue'
import VueRouter from 'vue-router'

import {createLocalVue, mount} from '@vue/test-utils'

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

let wrapper;

function mountComponent() {
  const localVue = createLocalVue();
  localVue.use(BootstrapVue);
  localVue.use(VueRouter);

  wrapper = mount(app, {
    mocks: {
      $t: () => "",
      $i18n: {
        locale: 'default'
      }
    },
    localVue,
    router
  });
}

describe('app', () => {

  beforeEach(() => {
    global.Notification = null
    mountComponent()
  })

  it('renders a link to the home route', () => {
    expect(wrapper.findAll('a').at(0).props().to).toEqual({
      name: 'home'
    })
  });

  it('renders a link to the new_event route', () => {
    expect(wrapper.findAll('a').at(1).props().to).toEqual({
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

  describe('if notifications are not available', () => {

    it('does not show the enable notification button', () => {
      expect(wrapper.find('button#enable-notifications').exists()).toBe(false)
    })
  })

  describe('if notifications are granted', () => {

    beforeEach(() => {
      global.Notification = {permission: 'granted'}
      mountComponent()
    })

    it('does not show the enable notification button', () => {
      expect(wrapper.find('button#enable-notifications').exists()).toBe(false)
    })
  })

  describe('if notifications are denied', () => {

    beforeEach(() => {
      global.Notification = {permission: 'denied'}
      mountComponent()
    })

    it('does not show the enable notification button', () => {
      expect(wrapper.find('button#enable-notifications').exists()).toBe(false)
    })
  })

  describe('if notifications are default', () => {

    beforeEach(() => {
      global.Notification = {
        permission: 'default'
      }
      mountComponent()
    })

    it('does show the enable notification button', () => {
      expect(wrapper.find('button#enable-notifications').exists()).toBe(true)
    })

    describe('if the user enables notifications', () => {
      beforeEach(() => {
        global.Notification = {
          permission: 'default',
          requestPermission: jest.fn().mockResolvedValue("granted")
        }
        mountComponent()
        wrapper.find('button#enable-notifications').trigger('click')
      })

      it('hides the button', () => {
        expect(wrapper.find('button#enable-notifications').exists()).toBe(false)
      })
    })

    describe('if the user denies notifications', () => {
      beforeEach(() => {
        global.Notification = {
          permission: 'default',
          requestPermission: jest.fn().mockResolvedValue("denied")
        }
        mountComponent()
        wrapper.find('button#enable-notifications').trigger('click')
      })

      it('hides the button', () => {
        expect(wrapper.find('button#enable-notifications').exists()).toBe(false)
      })
    })
  })
});
