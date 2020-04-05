import progressHeader from '@/components/progress-header.vue'
import BootstrapVue from 'bootstrap-vue'

import {
  createLocalVue,
  shallowMount
} from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue)

let wrapper

describe('progressHeader', () => {

  describe('when hideLabel = false', () => {

    beforeEach(() => {

      wrapper = shallowMount(progressHeader, {
        localVue,
        propsData: {
          step: 2,
          maxStep: 3
        },
        mocks: {
          $t: (text) => text
        }
      })
    })

    it('renders the label', () => {

      expect(wrapper.find('[name="progress-label"]').text()).toBeTruthy()
    })

    it('renders the progress bar', () => {

      expect(wrapper.find('b-progress-stub').exists()).toBeTruthy()
    })

    it('correclty computes displayStep', () => {
      expect(wrapper.vm.displayStep).toBe(2)
    })

    it('correclty computes displayMaxStep', () => {
      expect(wrapper.vm.displayMaxStep).toBe(3)
    })
  })

  describe('when hideLabel = true', () => {

    beforeEach(() => {

      wrapper = shallowMount(progressHeader, {
        localVue,
        propsData: {
          step: 2,
          maxStep: 3,
          minStep: 2,
          hideLabel: true
        },
        mocks: {
          $t: (text) => text
        }
      })
    })

    it('does not render the label', () => {

      expect(wrapper.find('[name="progress-label"]').exists()).toBeFalsy()
    })

    it('renders the progress bar', () => {

      expect(wrapper.find('b-progress-stub').exists()).toBeTruthy()
    })

    it('correclty computes displayStep', () => {
      expect(wrapper.vm.displayStep).toBe(1)
    })

    it('correclty computes displayMaxStep', () => {
      expect(wrapper.vm.displayMaxStep).toBe(2)
    })

  })

  describe('when minStep = maxStep', () => {

    beforeEach(() => {

      wrapper = shallowMount(progressHeader, {
        localVue,
        propsData: {
          step: 3,
          maxStep: 3,
          minStep: 3
        },
        mocks: {
          $t: (text) => text
        }
      })
    })

    it('does not render the label', () => {

      expect(wrapper.find('[name="progress-label"]').exists()).toBeFalsy()
    })

    it('does not render the progress bar', () => {

      expect(wrapper.find('b-progress-stub').exists()).toBeFalsy()
    })

    it('correclty computes displayStep', () => {
      expect(wrapper.vm.displayStep).toBe(1)
    })

    it('correclty computes displayMaxStep', () => {
      expect(wrapper.vm.displayMaxStep).toBe(1)
    })
  })
})
