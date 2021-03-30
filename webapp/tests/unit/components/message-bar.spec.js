import messageBar from '@/components/message-bar.vue'
import BootstrapVue from 'bootstrap-vue'

import {createLocalVue, shallowMount} from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue)

const MESSAGE = "I'm a message"
const VARIANT = 'danger'
const SECONDS = 10

let wrapper
let alert


describe('messageBar', () => {

  beforeEach(() => {
    global.Notification = jest.fn(() => {})
  })
  
  describe('without countdown', () => {

    beforeEach(() => {

      wrapper = shallowMount(messageBar, {
        localVue,
        propsData: {
          seconds: 0,
          variant: VARIANT
        },
        mocks: {
          $notification: {
            show: jest.fn()
          },
          $i18n: {
            t: () => "Let's meet"
          }
        }
      })

      wrapper.vm.show(MESSAGE)
    })

    it('shows a permanent dismissable message', () => {
      alert = wrapper.find('b-alert-stub')

      expect(alert.attributes('show')).toBe('true')
      expect(alert.attributes('dismissible')).toBeTruthy()
      expect(alert.attributes('variant')).toBe(VARIANT)
      expect(alert.text()).toBe(MESSAGE)
    })

    it('does not show native notifications', () => {
      expect(global.Notification).not.toHaveBeenCalled()
    })
  })

  describe('with countdown', () => {

    beforeEach(() => {

      wrapper = shallowMount(messageBar, {
        localVue,
        propsData: {
          seconds: SECONDS,
          variant: VARIANT
        },
        mocks: {
          $notification: {
            show: jest.fn()
          },
          $i18n: {
            t: () => "Let's meet"
          }
        }
      })

      wrapper.vm.show(MESSAGE)
    })

    it('shows a message with countdown', () => {
      alert = wrapper.find('b-alert-stub')

      expect(alert.attributes('show')).toEqual(SECONDS.toString())
      expect(alert.attributes('dismissible')).toBeFalsy()
      expect(alert.attributes('variant')).toBe(VARIANT)
      expect(alert.text()).toBe(MESSAGE)
    })

    it('does not show native notifications', () => {
      expect(global.Notification).not.toHaveBeenCalled()
    })
  })

  describe('when requesting native notifications', () => {
    beforeEach(() => {

      wrapper = shallowMount(messageBar, {
        localVue,
        propsData: {
          seconds: 0,
          variant: VARIANT
        },
        mocks: {
          $notification: {
            show: jest.fn()
          },
          $i18n: {
            t: () => "Let's meet"
          }
        }
      })

      wrapper.vm.show(MESSAGE, true)
    })

    it('shows a message', () => {
      alert = wrapper.find('b-alert-stub')

      expect(alert.attributes('show')).toBe('true')
      expect(alert.attributes('dismissible')).toBeTruthy()
      expect(alert.attributes('variant')).toBe(VARIANT)
      expect(alert.text()).toBe(MESSAGE)
    })

    it('shows native notifications', () => {
      expect(global.Notification).toHaveBeenCalledWith("Let's meet", {
        icon: '/favicon.ico', body: MESSAGE
      })
    })
  })
})
