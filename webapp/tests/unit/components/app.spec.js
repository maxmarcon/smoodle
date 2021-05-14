import app from '@/components/app'
import {NavbarPlugin} from 'bootstrap-vue'
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
  localVue.use(NavbarPlugin);
  localVue.use(VueRouter);

  wrapper = mount(app, {
    mocks: {
      $t: (text) => text,
      $i18n: {
        locale: 'default'
      },
      $bvModal: {
        msgBoxOk: jest.fn()
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

    it('does not show the notification modal', () => {
      expect(wrapper.vm.$bvModal.msgBoxOk).not.toHaveBeenCalled()
    })
  })

  describe('if notifications are granted', () => {

    beforeEach(() => {
      global.Notification = {permission: 'granted'}
      mountComponent()
    })

    it('does not show the notification modal', () => {
      expect(wrapper.vm.$bvModal.msgBoxOk).not.toHaveBeenCalled()
    })
  })

  describe('if notifications are denied', () => {

    beforeEach(() => {
      global.Notification = {permission: 'denied'}
      mountComponent()
    })

    it('does not show the enable notification modal', () => {
      expect(wrapper.vm.$bvModal.msgBoxOk).not.toHaveBeenCalled()
    })
  })

  describe('if notifications are default', () => {

    beforeEach(() => {
      global.Notification = {
        permission: 'default',
        requestPermission: jest.fn()
      }
      mountComponent()
    })

    it('does show the notification modal', () => {
      expect(wrapper.vm.$bvModal.msgBoxOk).toHaveBeenCalledWith("notification_prompt")
    })

    it('does request permission for notifications', () => {
      expect(global.Notification.requestPermission).toHaveBeenCalled()
    })
  })
});
