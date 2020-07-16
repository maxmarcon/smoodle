import pollEditor from '@/components/poll-editor.vue'
import messageBar from '@/components/message-bar.vue'
import i18nMock from '../test-utils/i18n-mock'
import {createLocalVue, mount} from '@vue/test-utils'
import {AlertPlugin, CardPlugin} from 'bootstrap-vue'

const CANT_BE_BLANK = "can't be blank"
const NO_LONGER_OPEN = "no longer open"

const EVENT_ID = '73b422e0-a1a1-4c42-9c91-833a82e76acd'
const EVENT_DATA = {
  "updated_at": "2118-09-04T18:47:21.000000Z",
  "possible_dates": [{
    "date_to": "2118-10-02",
    "date_from": "2118-09-02",
  }],
  "state": "OPEN",
  "scheduled_to": null,
  "scheduled_from": null,
  "organizer": "Max",
  "name": "Party",
  "inserted_at": "2018-09-02T19:11:19.000000Z",
  "id": EVENT_ID,
  "desc": "By the pool",
  "preferences": {
    "weekdays": [{
      "day": 0,
      "permitted": false
    }]
  }
}

const CANCELED_EVENT_DATA = {
  "updated_at": "2018-09-04T18:47:21.000000Z",
  "possible_dates": [{
    "date_to": "2118-10-02",
    "date_from": "2118-09-02",
  }],
  "state": "CANCELED",
  "scheduled_to": null,
  "scheduled_from": null,
  "organizer": "Max",
  "name": "Party",
  "inserted_at": "2018-09-02T19:11:19.000000Z",
  "id": EVENT_ID,
  "desc": "By the pool"
}

const POLL_ID = "599a1056-3cea-4c4e-b54c-5fd376f0f632";
const POLL_DATA = {
  "updated_at": "2018-09-21T14:55:22.000000Z",
  "preferences": {
    "weekday_ranks": [{
      rank: -1,
      day: 0
    }, {
      rank: 1,
      day: 6
    }, {
      rank: -1,
      day: 2
    }]
  },
  "participant": "Min",
  "inserted_at": "2018-09-21T14:55:22.000000Z",
  "id": POLL_ID,
  "event_id": EVENT_ID,
  "event": EVENT_DATA,
  "date_ranks": [{
    date_from: "2118-09-12",
    date_to: "2118-09-12",
    rank: 1
  }, {
    date_from: "2118-09-28",
    date_to: "2118-10-01",
    rank: -1
  }]
}

const CANCELED_EVENT_POLL_DATA = {
  "updated_at": "2018-09-21T14:55:22.000000Z",
  "preferences": {
    "weekday_ranks": []
  },
  "participant": "Min",
  "inserted_at": "2018-09-21T14:55:22.000000Z",
  "id": POLL_ID,
  "event_id": EVENT_ID,
  "event": CANCELED_EVENT_DATA,
  "date_ranks": []
}

const inputElements = [
  ['input#pollParticipant'],
  ['v-date-picker-stub#pollDateRanks', 'ranker-stub#pollWeekdayRanks']
]

const errorElements = [
  ['.invalid-feedback[name="poll-participant-error"]'],
  ['.small.text-danger[name="poll-date-ranks-error"]', '.small.text-danger[name="poll-weekday-rank-error"]']
]

function mountPollEditor(restRequest, propsData) {

  const localVue = createLocalVue()
  localVue.use(CardPlugin)
  localVue.use(AlertPlugin)

  const routerSpy = {
    push: jest.fn()
  }
  const newDateSpy = jest.fn()

  const bvModalSpy = {
    msgBoxOk: jest.fn().mockResolvedValue(true),
    msgBoxConfirm: jest.fn().mockResolvedValue(true)
  }

  return mount(pollEditor, {
    mixins: [{
      methods: {
        restRequest
      }
    }],
    methods: {
      newDate: newDateSpy
    },
    mocks: {
      $t: i18nMock.t,
      $tc: i18nMock.t,
      $i18n: i18nMock,
      $scrollTo: () => null,
      $router: routerSpy,
      $screens: () => 2,
      $bvModal: bvModalSpy
    },
    stubs: {
      'progress-header': true,
      'event-header': true,
      'ranker': true,
      'p-radio': true,
      'i18n': true,
      'error-page': true,
      'v-date-picker': true,
      messageBar
    },
    propsData,
    localVue
  })
}

let wrapper;
let restRequest;

describe('pollEditor', () => {

  describe('with an eventId', () => {

    it('loads the event', () => {
      restRequest = jest.fn().mockResolvedValue({
        data: {
          data: EVENT_DATA
        }
      })
      wrapper = mountPollEditor(restRequest, {
        eventId: EVENT_ID
      })
      expect(restRequest).toHaveBeenCalledWith(`events/${EVENT_ID}`)
    })

    describe('when loading a non-open event', () => {

      beforeEach(() => {
        restRequest = jest.fn().mockResolvedValueOnce(
          {
            data: {
              data: CANCELED_EVENT_DATA
            }
          }
        )

        wrapper = mountPollEditor(restRequest, {
          eventId: EVENT_ID
        })
      })

      it('shows an error modal', () => {
        expect(wrapper.vm.$bvModal.msgBoxOk).toHaveBeenCalledWith('poll_editor.event_invalid', expect.anything())
      })
    })

    describe('if loading is successful, at step 1', () => {

      beforeEach(() => {
        restRequest = jest.fn().mockResolvedValueOnce(
          {
            data: {
              data: EVENT_DATA
            }
          }
        )

        wrapper = mountPollEditor(restRequest, {
          eventId: EVENT_ID
        })
      })

      it('renders the main card', () => {
        expect(wrapper.find('div.card[name="main-card"]').exists()).toBeTruthy();
      })

      it('renders the progress header', () => {
        expect(wrapper.find('progress-header-stub').exists()).toBeTruthy()
        expect(wrapper.find('progress-header-stub').attributes('step')).toBe('1')
        expect(wrapper.find('progress-header-stub').attributes('minstep')).toEqual('1')
        expect(wrapper.find('progress-header-stub').attributes('maxstep')).toEqual('2')
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

      test.each(inputElements[0])('renders input element ${selector}', (selector) => {
        expect(wrapper.find(selector).exists()).toBeTruthy()
      })

      it('renders one alert', () => {
        expect(wrapper.findAll('.alert').length).toBe(1)
      })

      it('renders the right buttons', () => {
        expect(wrapper.find('button[name="back-button"]').exists()).toBeFalsy();
        expect(wrapper.find('button span[name="save-poll-button"]').exists()).toBeFalsy();
        expect(wrapper.find('button span[name="forward-button"]').exists()).toBeTruthy();
        expect(wrapper.find('button[name="delete-poll-button"]').exists()).toBeFalsy();
        expect(wrapper.find('button[name="back-to-event-button"]').exists()).toBeTruthy();
      })

      it('user can go back to event', () => {
        wrapper.find('button[name="back-to-event-button"]').trigger('click')
        expect(wrapper.vm.$router.push).toHaveBeenCalledWith({
          name: 'event',
          params: {
            eventId: EVENT_ID
          }
        });
      })

      describe('when blurring input', () => {

        beforeEach(() => {
          wrapper.find('input#pollParticipant').trigger('blur')
        })

        it('triggers local validation', () => {
          expect(wrapper.find('.invalid-feedback[name="poll-participant-error"]').text()).toBe("errors.required_field")
        })
      })

      describe('when clicking on the forward button with errors', () => {

        beforeEach(() => {
          restRequest = jest.fn().mockResolvedValueOnce(
            {
              status: 200,
              data: {
                data: EVENT_DATA
              }
            }
          ).mockRejectedValueOnce(
            {
              response: {
                status: 422,
                data: {
                  errors: {
                    "participant": [CANT_BE_BLANK]
                  }
                }
              }
            })

          wrapper = mountPollEditor(restRequest, {
            eventId: EVENT_ID
          })
        })

        beforeEach(() => {
          wrapper.find('button span[name="forward-button"]').trigger('click')
        })

        test.each(errorElements[0])('renders error in %s', (selector) => {
          expect(wrapper.find(selector).text()).toBe(CANT_BE_BLANK)
        })
      })

      describe('when clicking on the forward button without errors', () => {

        beforeEach(() => {
          restRequest = jest.fn().mockResolvedValueOnce(
            {
              data: {
                data: EVENT_DATA
              }
            }
          ).mockResolvedValueOnce({
            status: 204
          })

          wrapper = mountPollEditor(restRequest, {
            eventId: EVENT_ID
          })
        })

        beforeEach(async () => {
          await wrapper.find('button span[name="forward-button"]').trigger('click')
        })

        test.each(errorElements[1])('does not render error in %s', (selector) => {
          expect(wrapper.find(selector).text()).toBeFalsy()
        })
      })
    })

    describe('if loading is successful, at step 2', () => {

      beforeEach(() => {
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
                  "date_ranks": [CANT_BE_BLANK],
                  "preferences": {
                    "weekday_ranks": [CANT_BE_BLANK]
                  }
                }
              }
            }
          }).mockResolvedValueOnce({
          data: {
            data: POLL_DATA
          }
        })

        wrapper = mountPollEditor(restRequest, {
          eventId: EVENT_ID,
          forceStep: 2
        })
      })

      it('renders the main card', () => {
        expect(wrapper.find('div.card[name="main-card"]').exists()).toBeTruthy();
      })

      it('renders the progress header', () => {
        expect(wrapper.find('progress-header-stub').exists()).toBeTruthy()
        expect(wrapper.find('progress-header-stub').attributes('step')).toBe('2')
        expect(wrapper.find('progress-header-stub').attributes('minstep')).toEqual('1')
        expect(wrapper.find('progress-header-stub').attributes('maxstep')).toEqual('2')
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

      test.each(inputElements[1])('renders input element %selector', (selector) => {
        expect(wrapper.find(selector).exists()).toBeTruthy()
      })

      it('renders one alert', () => {
        expect(wrapper.findAll('.alert').length).toBe(1)
      })

      it('renders the right buttons', () => {
        expect(wrapper.find('button[name="back-button"]').exists()).toBeTruthy();
        expect(wrapper.find('button span[name="save-poll-button"]').exists()).toBeTruthy();
        expect(wrapper.find('button span[name="forward-button"]').exists()).toBeFalsy();
        expect(wrapper.find('button[name="delete-poll-button"]').exists()).toBeFalsy();
        expect(wrapper.find('button[name="back-to-event-button"]').exists()).toBeFalsy();
      })

      describe('when saving the poll with errors', () => {

        beforeEach(() => {
          wrapper.find('button span[name="save-poll-button"]').trigger('click')
        })


        test.each(errorElements[1])('renders error in %s', selector => {
          expect(wrapper.find(selector).text()).toBe(CANT_BE_BLANK)
        })
      })

      describe('when saving the poll without errors', () => {

        beforeEach(() => {
          // clicked once to get error response
          wrapper.find('button span[name="save-poll-button"]').trigger('click')
        })

        beforeEach(() => {
          wrapper.find('button span[name="save-poll-button"]').trigger('click')
        })

        test.each(errorElements[1])('does not render error in %s', (selector) => {
          expect(wrapper.find(selector).text()).toBeFalsy()
        })

        it('shows the modal to go back to the event', () => {
          expect(wrapper.vm.$bvModal.msgBoxOk).toHaveBeenCalledWith('poll_editor.poll_saved', expect.anything())
        })
      })
    })

    describe('if loading fails', () => {

      beforeEach(() => {
        restRequest = jest.fn().mockRejectedValue(null)
        wrapper = mountPollEditor(restRequest, {
          eventId: EVENT_ID
        })
      })

      it('does not render the main card', () => {
        expect(wrapper.find('div.card').exists()).toBeFalsy();
      })

      it('renders an error page', () => {
        expect(wrapper.find('error-page-stub').exists()).toBeTruthy();
      })
    })
  })


  describe('with a pollId', () => {

    it('loads the poll', () => {
      restRequest = jest.fn().mockResolvedValue({
        data: {
          data: POLL_DATA
        }
      })
      wrapper = mountPollEditor(restRequest, {
        pollId: POLL_ID
      })
      expect(restRequest).toHaveBeenCalledWith(`polls/${POLL_ID}`)
    })

    describe('when loading a poll for a non-open event', () => {

      beforeEach(() => {
        restRequest = jest.fn().mockResolvedValue(
          {
            data: {
              data: CANCELED_EVENT_POLL_DATA
            }
          })

        wrapper = mountPollEditor(restRequest, {
          pollId: POLL_ID
        })
      })

      it('shows an error modal', () => {
        expect(wrapper.vm.$bvModal.msgBoxOk).toHaveBeenCalledWith('poll_editor.event_invalid', expect.anything())
      })
    })

    describe('if loading is successful', () => {

      beforeEach(() => {
        restRequest = jest.fn().mockResolvedValueOnce(
          {
            data: {
              data: POLL_DATA
            }
          }).mockRejectedValueOnce({
          response: {
            status: 422,
            data: {
              errors: {
                "event": [NO_LONGER_OPEN]
              }
            }
          }
        }).mockResolvedValueOnce({
          data: {
            data: POLL_DATA
          }
        })

        wrapper = mountPollEditor(restRequest, {
          pollId: POLL_ID
        })
      })

      it('renders the main card', () => {
        expect(wrapper.find('div.card').exists()).toBeTruthy();
      })

      it('renders the progress header', () => {
        expect(wrapper.find('progress-header-stub').exists()).toBeTruthy()
        expect(wrapper.find('progress-header-stub').attributes('step')).toBe('2')
        expect(wrapper.find('progress-header-stub').attributes('minstep')).toEqual('2')
        expect(wrapper.find('progress-header-stub').attributes('maxstep')).toEqual('2')
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

      it('does not render the participant name input', () => {
        expect(wrapper.find('input#pollParticipant').exists()).toBeFalsy()
      })

      it('renders the ranker', () => {
        expect(wrapper.find('ranker-stub#pollWeekdayRanks').exists()).toBeTruthy();
      })

      it('computes the poll weekday ranks', () => {
        expect(wrapper.vm.pollWeekdayRanks
          .filter(obj => obj.value !== 0).map(({
                                                 day,
                                                 value
                                               }) => ({
            day: day,
            rank: value
          })).sort((o1, o2) => o1.day - o2.day))
          .toEqual(POLL_DATA.preferences.weekday_ranks.sort((o1, o2) => o1.day - o2.day))
      })

      it('disables some poll weeday ranks', () => {
        let disabledWeekdays = EVENT_DATA.preferences.weekdays
          .filter(({
                     permitted
                   }) => !permitted)

        expect(disabledWeekdays.length).toBe(1)

        disabledWeekdays.forEach(({
                                    day: event_day
                                  }) => {
          let wr = wrapper.vm.pollWeekdayRanks.find(({
                                                       day
                                                     }) => day === event_day)
          expect(wr).toBeDefined()
          expect(wr.disabled).toBeTruthy()
        })
      })

      it('renders the date picker', () => {
        expect(wrapper.find('v-date-picker-stub#pollDateRanks').exists()).toBeTruthy();
      })

      it('computes datePickerAttributes', () => {
        expect(wrapper.vm.datePickerAttributes.length).toBeGreaterThan(0)
      })

      it('renders one alert', () => {
        expect(wrapper.findAll('.alert').length).toBe(1)
      })

      it('renders the right buttons', () => {
        expect(wrapper.find('button[name="back-button"]').exists()).toBeFalsy();
        expect(wrapper.find('button span[name="save-poll-button"]').exists()).toBeTruthy();
        expect(wrapper.find('button span[name="forward-button"]').exists()).toBeFalsy();
        expect(wrapper.find('button[name="delete-poll-button"]').exists()).toBeTruthy();
        expect(wrapper.find('button[name="back-to-event-button"]').exists()).toBeTruthy();
      })

      it('user can go back to event', () => {
        wrapper.find('button[name="back-to-event-button"]').trigger('click')
        expect(wrapper.vm.$router.push).toHaveBeenCalledWith({
          name: 'event',
          params: {
            eventId: EVENT_ID
          }
        });
      })

      xdescribe('when blurring input', () => {

        beforeEach(() => {
          wrapper.find('input#pollParticipant').trigger('blur')
        })

        it('triggers local validation', () => {
          pending("so far the participant name is the only locally validated input, and not available when updating polls")
          expect(wrapper.find('.invalid-feedback[name="poll-participant-error"]').text()).toBe("errors.required_field")
        })
      })

      describe('when saving the poll with errors', () => {

        beforeEach(() => {
          wrapper.find('button span[name="save-poll-button"]').trigger('click')
        })

        it('renders errors', () => {
          expect(wrapper.vm.eventError).toBe(NO_LONGER_OPEN)
          expect(wrapper.vm.$bvModal.msgBoxOk).toHaveBeenCalledWith('no longer open', expect.anything())
        })
      })

      describe('when saving the poll successfully', () => {

        beforeEach(() => {
          wrapper.find('button span[name="save-poll-button"]').trigger('click')
        })

        beforeEach(() => {
          wrapper.find('button span[name="save-poll-button"]').trigger('click')
        })

        it('there should be no errors', () => {
          expect(wrapper.vm.eventError).toBeFalsy()
        })

        it('shows the modal to go back to the event', () => {
          expect(wrapper.vm.$bvModal.msgBoxOk).toHaveBeenCalledWith('poll_editor.poll_saved', expect.anything())
        })
      })

      describe('when deleting the poll', () => {

        beforeEach(() => {
          wrapper.find('button[name="delete-poll-button"]').trigger('click')
        })

        it('shows the confirmation modal', () => {
          expect(wrapper.vm.$bvModal.msgBoxConfirm).toHaveBeenCalledWith('poll_editor.really_delete', expect.anything())
        })

        it('deletes the poll', () => {
          expect(restRequest).toHaveBeenCalledWith(`polls/${POLL_ID}`, {
            method: 'delete'
          })
        })
      })
    })
  })
})
