import eventEditor from '@/components/event-editor.vue'
import BootstrapVue from 'bootstrap-vue'
import PrettyCheckbox from 'pretty-checkbox-vue'
import VueClipboard from 'vue-clipboard2'
import messageBar from '@/components/message-bar.vue'
import i18nMock from '../test-utils/i18n-mock'
import {createLocalVue, mount, RouterLinkStub} from '@vue/test-utils'

const routerSpy = {
  push: jest.fn()
}

const CANT_BE_BLANK = 'can\'t be blank'

function mountEventEditor(restRequest, propsData) {

  const localVue = createLocalVue();
  localVue.use(BootstrapVue);
  localVue.use(VueClipboard);
  localVue.use(PrettyCheckbox);

  const config = {
    mixins: [{
      methods: {
        restRequest
      }
    }],
    mocks: {
      $t: i18nMock.t,
      $tc: i18nMock.t,
      $i18n: i18nMock,
      $scrollTo: () => null,
      $router: routerSpy,
      $screens: () => 2
    },
    stubs: {
      'progress-header': true,
      'event-header': true,
      'ranker': true,
      'p-radio': true,
      'v-date-picker': true,
      'error-page': true,
      'router-link': RouterLinkStub,
      messageBar
    },
    propsData,
    localVue
  }

  return mount(eventEditor, config)
}

const inputElements = [
  ['input#eventOrganizer',
    'input#eventOrganizerEmail',
    'input#eventOrganizerEmailConfirmation'
  ],
  ['input#eventName',
    'textarea#eventDesc',
    'div#publicParticipants[p-checkbox]'
  ],
  ['v-date-picker-stub#eventPossibleDates',
    'ranker-stub#eventWeekdays'
  ]
]

const errorElements = [
  ['.invalid-feedback[name="event-organizer-error"]',
    '.invalid-feedback[name="event-organizer-email-error"]',
    '.invalid-feedback[name="event-organizer-email-confirmation-error"]'
  ],
  ['.invalid-feedback[name="event-name-error"]',
    '.invalid-feedback[name="event-desc-error"]'
  ],
  ['.small.text-danger[name="event-possible-dates-error"]',
    '.small.text-danger[name="event-weekdays-error"]'
  ]
]

const EVENT_ID = "bf6747d5-7b32-4bde-8e2d-c055d9bb02d3"
const EVENT_SECRET = "NGQ4NkdBQWVTd0U9"

const EVENT_DATA = {
  "updated_at": "2018-09-20T17:06:20.000000Z",
  "possible_dates": [{
    "date_to": "2119-12-01",
    "date_from": "2119-06-01",
  }],
  "state": "OPEN",
  "share_link": "http://localhost:4000/events/bf6747d5-7b32-4bde-8e2d-c055d9bb02d3",
  "secret": EVENT_SECRET,
  "scheduled_to": null,
  "scheduled_from": null,
  "owner_link": "http://localhost:4000/events/bf6747d5-7b32-4bde-8e2d-c055d9bb02d3?s=NGQ4NkdBQWVTd0U9",
  "organizer": "Max",
  "name": "Party",
  "inserted_at": "2018-09-20T17:06:20.000000Z",
  "id": EVENT_ID,
  "email": "maxmarcon@gmx.net",
  "desc": "Be our guest!",
  "public_participants": false
}

let wrapper
let restRequest

describe('eventEditor', () => {

  beforeEach(() => {
    restRequest = jest.fn().mockResolvedValue({
      data: {
        data: EVENT_DATA
      }
    })
  })

  describe('without an eventId', () => {

    describe('at the first step after loading', () => {

      beforeEach(() => {
        wrapper = mountEventEditor(restRequest, {})
      })

      it('renders the event header', () => {
        let eventHeader = wrapper.find('event-header-stub')
        expect(eventHeader.exists()).toBeTruthy();
        expect(eventHeader.attributes('eventname')).toBeUndefined()
        expect(eventHeader.attributes('eventorganizer')).toBeUndefined()
        expect(eventHeader.attributes('eventstate')).toBe('OPEN')
        expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
        expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
        expect(eventHeader.attributes('eventtimewindowfrom')).toBeUndefined()
        expect(eventHeader.attributes('eventtimewindowto')).toBeUndefined()
      })

      it('renders the main card', () => {
        expect(wrapper.find('div.card[name="main-card"]').exists()).toBeTruthy()
      })

      it('renders the progress header', () => {
        expect(wrapper.find('progress-header-stub').exists()).toBeTruthy()
        expect(wrapper.find('progress-header-stub').attributes('step')).toBe('1')
        expect(wrapper.find('progress-header-stub').attributes('minstep')).toEqual('1')
        expect(wrapper.find('progress-header-stub').attributes('maxstep')).toEqual('3')
      })

      it('renders the card body', () => {
        expect(wrapper.find('div.card[name="main-card"] div.card-body').exists()).toBeTruthy();
      })

      it('renders one alert', () => {
        expect(wrapper.findAll('.alert').length).toBe(1)
      })

      inputElements[0].forEach(selector => {
        it(`renders input element ${selector}`, () => {
          expect(wrapper.find(selector).exists()).toBeTruthy()
        })
      })

      it('renders the right buttons', () => {
        expect(wrapper.find('button[name="back-button"]').exists()).toBeTruthy()
        expect(wrapper.find('button span[name="forward-button"]').exists()).toBeTruthy()
        expect(wrapper.find('button span[name="save-event-button"]').exists()).toBeFalsy()
        expect(wrapper.find('button[name="cancel-button"]').exists()).toBeFalsy()
        expect(wrapper.find(RouterLinkStub).exists()).toBeFalsy()
      })
    })

    describe('at the second step', () => {

      beforeEach(() => {
        wrapper = mountEventEditor(restRequest, {
          forceStep: 2
        })
      })

      it('renders the event header', () => {
        let eventHeader = wrapper.find('event-header-stub')
        expect(eventHeader.exists).toBeTruthy();
        expect(eventHeader.attributes('eventname')).toBeUndefined()
        expect(eventHeader.attributes('eventorganizer')).toBeUndefined()
        expect(eventHeader.attributes('eventstate')).toBe('OPEN')
        expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
        expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
        expect(eventHeader.attributes('eventtimewindowfrom')).toBeUndefined()
        expect(eventHeader.attributes('eventtimewindowto')).toBeUndefined()
      })

      it('renders the main card', () => {
        expect(wrapper.find('div.card[name="main-card"]').exists()).toBeTruthy()
      })

      it('renders the progress header', () => {
        expect(wrapper.find('progress-header-stub').exists()).toBeTruthy()
        expect(wrapper.find('progress-header-stub').attributes('step')).toBe('2')
        expect(wrapper.find('progress-header-stub').attributes('minstep')).toEqual('1')
        expect(wrapper.find('progress-header-stub').attributes('maxstep')).toEqual('3')
      })

      it('renders the card body', () => {
        expect(wrapper.find('div.card[name="main-card"] div.card-body').exists()).toBeTruthy();
      })

      it('renders one alert', () => {
        expect(wrapper.findAll('.alert').length).toBe(1)
      })

      inputElements[1].forEach(selector => {
        it(`renders input element ${selector}`, () => {
          expect(wrapper.find(selector).exists()).toBeTruthy()
        })
      })

      it('renders the right buttons', () => {
        expect(wrapper.find('button[name="back-button"]').exists()).toBeTruthy()
        expect(wrapper.find('button span[name="forward-button"]').exists()).toBeTruthy()
        expect(wrapper.find('button span[name="save-event-button"]').exists()).toBeFalsy()
        expect(wrapper.find('button[name="cancel-button"]').exists()).toBeFalsy()
        expect(wrapper.find(RouterLinkStub).exists()).toBeFalsy()
      })
    })

    describe('at the third step', () => {

      beforeEach(() => {
        wrapper = mountEventEditor(restRequest, {
          forceStep: 3
        })
      })

      it('renders the event header', () => {
        let eventHeader = wrapper.find('event-header-stub')
        expect(eventHeader.exists).toBeTruthy();
        expect(eventHeader.attributes('eventname')).toBeUndefined()
        expect(eventHeader.attributes('eventorganizer')).toBeUndefined()
        expect(eventHeader.attributes('eventstate')).toBe('OPEN')
        expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
        expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
        expect(eventHeader.attributes('eventtimewindowfrom')).toBeUndefined()
        expect(eventHeader.attributes('eventtimewindowto')).toBeUndefined()
      })

      it('renders the main card', () => {
        expect(wrapper.find('div.card[name="main-card"]').exists()).toBeTruthy()
      })

      it('renders the progress header', () => {
        expect(wrapper.find('progress-header-stub').exists()).toBeTruthy()
        expect(wrapper.find('progress-header-stub').attributes('step')).toBe('3')
        expect(wrapper.find('progress-header-stub').attributes('minstep')).toEqual('1')
        expect(wrapper.find('progress-header-stub').attributes('maxstep')).toEqual('3')
      })

      it('renders the card body', () => {
        expect(wrapper.find('div.card[name="main-card"] div.card-body').exists()).toBeTruthy();
      })

      it('renders one alert', () => {
        expect(wrapper.findAll('.alert').length).toBe(1)
      })

      inputElements[2].forEach(selector => {
        it(`renders input element ${selector}`, () => {
          expect(wrapper.find(selector).exists()).toBeTruthy()
        })
      })

      it('renders the right buttons', () => {
        expect(wrapper.find('button[name="back-button"]').exists()).toBeTruthy()
        expect(wrapper.find('button span[name="forward-button"]').exists()).toBeFalsy()
        expect(wrapper.find('button span[name="save-event-button"]').exists()).toBeTruthy()
        expect(wrapper.find('button[name="cancel-button"]').exists()).toBeFalsy()
        expect(wrapper.find(RouterLinkStub).exists()).toBeFalsy()
      })
    })

    describe('when blurring input', () => {

      beforeEach(async () => {
        wrapper = mountEventEditor(restRequest, {})
        wrapper.find('input#eventOrganizer').trigger('blur')

      })

      it('triggers local validation', () => {
        expect(wrapper.find('.invalid-feedback[name="event-organizer-error"]').text()).toBe("errors.required_field")
      })
    })

    describe('when saving the event with errors', () => {

      beforeEach(async () => {
        restRequest = jest.fn().mockRejectedValue({
          response: {
            status: 422,
            data: {
              errors: {
                "organizer": [CANT_BE_BLANK],
                "email": [CANT_BE_BLANK],
                "email_confirmation": [CANT_BE_BLANK],
                "desc": [CANT_BE_BLANK],
                "name": [CANT_BE_BLANK],
                "possible_dates": [CANT_BE_BLANK],
                "preferences": {
                  "weekdays": [CANT_BE_BLANK]
                }
              }
            }
          }
        })

        wrapper = mountEventEditor(restRequest, {
          forceStep: 3
        })
        wrapper.find('button span[name="save-event-button"]').trigger("click")
      })

      // back to first step
      errorElements[0].forEach(selector => {
        it(`renders error in ${selector}`, () => {
          expect(wrapper.find(selector).text()).toBe(CANT_BE_BLANK)
        })
      })
    })

    describe('when successfully creating an event', () => {

      beforeEach(async () => {
        wrapper = mountEventEditor(restRequest, {
          forceStep: 3
        })
        wrapper.find('button span[name="save-event-button"]').trigger("click")
      })

      it('renders one alert', () => {
        expect(wrapper.findAll('.alert').length).toBe(1)
      })

      it('renders the event header', () => {
        const eventHeader = wrapper.find('event-header-stub')
        expect(eventHeader.exists()).toBeTruthy();
        expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
        expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
        expect(eventHeader.attributes('eventstate')).toBe(EVENT_DATA.state)
        expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
        expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
        expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
      })

      it('renders the main card', () => {
        expect(wrapper.find('div.card[name="main-card"]').exists()).toBeTruthy();
      })

      it('does not render the card body', () => {
        expect(wrapper.find('div.card[name="main-card"] div.card-body').exists()).toBeFalsy();
      })

      inputElements.flat().forEach(selector => {
        it(`does not render input element ${selector}`, () => {
          expect(wrapper.find(selector).exists()).toBeFalsy()
        })
      })

      it('renders the share link input field', () => {
        expect(wrapper.find('input#shareLink').element.value).toBe(EVENT_DATA.share_link)
      })

      it('renders the share button', () => {
        expect(wrapper.find('button[name="share-button"]').exists()).toBeTruthy()
      })

      it('renders the share via Whatsapp button', () => {
        expect(wrapper.find(`a[href="https://wa.me/?text=http%3A%2F%2Flocalhost%3A4000%2Fevents%2F${EVENT_ID}"]`).exists()).toBeTruthy()
      })

      it('renders only the manage event button', () => {
        expect(wrapper.find('button[name="back-button"]').exists()).toBeFalsy()
        expect(wrapper.find('button span[name="forward-button"]').exists()).toBeFalsy()
        expect(wrapper.find('button span[name="save-event-button"]').exists()).toBeFalsy()
        expect(wrapper.find('button[name="cancel-button"]').exists()).toBeFalsy()
        expect(wrapper.find(RouterLinkStub).props('to')).toEqual({
          name: 'event',
          params: {
            eventId: EVENT_ID,
            secret: EVENT_SECRET
          },
          query: {
            s: EVENT_SECRET
          }
        })
      })
    })
  })

  describe('with an eventId', () => {

    describe('when loading an existing event', () => {

      beforeEach(async () => {
        wrapper = mountEventEditor(restRequest, {
          eventId: EVENT_ID,
          secret: EVENT_SECRET
        })
      })

      it('renders the event header', () => {
        let eventHeader = wrapper.find('event-header-stub')
        expect(eventHeader.exists).toBeTruthy();
        expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
        expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
        expect(eventHeader.attributes('eventstate')).toBe(EVENT_DATA.state)
        expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
        expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
        expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
      })

      it('renders the main card', () => {
        expect(wrapper.find('div.card[name="main-card"]').exists()).toBeTruthy();
      })

      it('renders the card body', () => {
        expect(wrapper.find('div.card[name="main-card"] div.card-body').exists()).toBeTruthy();
      })

      it('renders one alert', () => {
        expect(wrapper.findAll('.alert').length).toBe(1)
      })

      inputElements[0]
        .forEach(selector => {
          it(`does not render input element ${selector}`, () => {
            expect(wrapper.find(selector).exists()).toBeFalsy()
          })
        })

      inputElements[1].forEach(selector => {
        it(`renders input element ${selector}`, () => {
          expect(wrapper.find(selector).exists()).toBeTruthy()
        })
      })

      it('user can go back to the event', () => {

        wrapper.find('button[name="cancel-button"]').trigger("click")

        expect(routerSpy.push).toHaveBeenCalledWith({
          name: 'event',
          params: {
            eventId: EVENT_ID,
            secret: EVENT_SECRET
          },
          query: {
            s: EVENT_SECRET
          }
        })
      })

      it('renders the right buttons', () => {

        expect(wrapper.find('button[name="back-button"]').exists()).toBeFalsy()
        expect(wrapper.find('button span[name="forward-button"]').exists()).toBeTruthy()
        expect(wrapper.find('button span[name="save-event-button"]').exists()).toBeFalsy()
        expect(wrapper.find('button[name="cancel-button"]').exists()).toBeTruthy()
        expect(wrapper.find(RouterLinkStub).exists()).toBeFalsy()
      })

      describe('when blurring input', () => {

        beforeEach(async () => {
          wrapper.vm.eventName = '';
          wrapper.find('input#eventName').trigger('blur')

        })

        it('triggers local validation', () => {
          expect(wrapper.find('.invalid-feedback[name="event-name-error"]').text()).toBe("errors.required_field")
        })
      })
    })

    describe('when trying to load an event without using the secret', () => {

      beforeEach(() => {

        wrapper = mountEventEditor(restRequest, {
          eventId: EVENT_ID
        })
      })

      it('does not render the main card', () => {
        expect(wrapper.find('div.card[name="main-card"]').exists()).toBeFalsy();
      })

      it('renders an error page', () => {
        expect(wrapper.find('error-page-stub').exists()).toBeTruthy();
      })
    })

    describe('when trying to load an non-existent event', () => {

      beforeEach(async () => {
        restRequest = jest.fn().mockRejectedValue({
          response: {
            status: 404
          }
        })

        wrapper = mountEventEditor(restRequest, {
          eventId: EVENT_ID,
          secret: EVENT_SECRET
        })
      })

      it('does not render the main card', () => {
        expect(wrapper.find('div.card[name="main-card"]').exists()).toBeFalsy();
      })

      it('renders an error page', () => {
        expect(wrapper.find('error-page-stub').exists()).toBeTruthy();
      })
    })

    describe('when saving an existing event with errors', () => {

      beforeEach(async () => {

        restRequest = jest.fn().mockResolvedValueOnce(
          {
            data: {
              data: EVENT_DATA
            }
          }).mockRejectedValueOnce(
          {
            response: {
              status: 422,
              data: {
                errors: {
                  "desc": [CANT_BE_BLANK],
                  "name": [CANT_BE_BLANK],
                  "possible_dates": [CANT_BE_BLANK],
                  "preferences": {
                    "weekdays": [CANT_BE_BLANK]
                  }
                }
              }
            }
          })

        wrapper = mountEventEditor(restRequest, {
          eventId: EVENT_ID,
          secret: EVENT_SECRET,
          forceStep: 3
        })
      })

      beforeEach(async () => {
        wrapper.find('button span[name="save-event-button"]').trigger("click")
      })

      errorElements[1].forEach(selector => {
        it(`renders error in ${selector}`, () => {
          expect(wrapper.find(selector).text()).toBe(CANT_BE_BLANK)
        })
      })
    })

    describe('when saving an existing event', () => {

      beforeEach(async () => {
        restRequest = jest.fn().mockResolvedValueOnce({
          data: {
            data: EVENT_DATA
          }
        }).mockResolvedValueOnce(
          {
            data: {
              data: EVENT_DATA
            }
          })

        wrapper = mountEventEditor(restRequest, {
          eventId: EVENT_ID,
          secret: EVENT_SECRET,
          forceStep: 3
        })


      })

      beforeEach(async () => {
        wrapper.find('button span[name="save-event-button"]').trigger('click')

      })

      errorElements[2].forEach(selector => {
        it(`no error in ${selector}`, () => {
          expect(wrapper.find(selector).text()).toBeFalsy()
        })
      })

      it('opens the eventu-updated-modal modal', () => {
        expect(wrapper.find('#event-updated-modal').isVisible()).toBeTruthy()
      })

      // All buttons in the modal appear as disabled. Could be a bug in bootstrap-vue (2.2.2)
      // Try again after a new version becomes available
      xit('the event-updated-modal has a button that takes the user back to the event', async () => {
        wrapper.find('#event-updated-modal button.btn-primary').trigger('click')

        expect(routerSpy.push).toHaveBeenCalledWith({
          name: 'event',
          params: {
            eventId: EVENT_ID,
            secret: EVENT_SECRET
          },
          query: {
            s: EVENT_SECRET
          }
        })
      })
    })
  })
})
