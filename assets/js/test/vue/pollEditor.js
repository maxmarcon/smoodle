import pollEditor from '../../vue/pollEditor.vue'
import BootstrapVue from 'bootstrap-vue'
import VueRouter from 'vue-router'

import {
	mount,
	shallowMount,
	createLocalVue
} from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue);

const EVENT_ID = '73b422e0-a1a1-4c42-9c91-833a82e76acd'
const EVENT_DATA = {
	"updated_at": "2018-09-04T18:47:21.000000Z",
	"time_window_to": "2018-10-02",
	"time_window_from": "2018-09-02",
	"state": "OPEN",
	"scheduled_to": null,
	"scheduled_from": null,
	"organizer": "Max",
	"name": "Party",
	"inserted_at": "2018-09-02T19:11:19.000000Z",
	"id": EVENT_ID,
	"desc": "By the pool"
}

const CANCELED_EVENT_DATA = {
	"updated_at": "2018-09-04T18:47:21.000000Z",
	"time_window_to": "2018-10-02",
	"time_window_from": "2018-09-02",
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
		"weekday_ranks": []
	},
	"participant": "Min",
	"inserted_at": "2018-09-21T14:55:22.000000Z",
	"id": POLL_ID,
	"event_id": EVENT_ID,
	"event": EVENT_DATA,
	"date_ranks": []
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


let routerSpy = jasmine.createSpyObj("router", ["push"])
let dayClickedSpy = jasmine.createSpy('dayClicked')

function mountPollEditor(restRequest, propsData) {

	return mount(pollEditor, {
		mixins: [{
			methods: {
				restRequest
			}
		}],
		methods: {
			dayClicked: dayClickedSpy
		},
		mocks: {
			$t: () => "",
			$tc: () => "",
			$i18n: {
				t: (key) => key
			},
			$router: routerSpy
		},
		propsData,
		localVue
	})
}

describe('pollEditor', () => {

	let wrapper;
	let restRequest;

	describe('with an eventId', () => {

		it('loads the event', () => {
			restRequest = jasmine.createSpy("restRequest").and.returnValue(Promise.resolve(true))
			wrapper = mountPollEditor(restRequest, {
				eventId: EVENT_ID
			})
			expect(restRequest).toHaveBeenCalledWith(`events/${EVENT_ID}`)
		})

		describe('when loading an non-open event', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy("restRequest").and.returnValues(
					Promise.resolve({
						data: {
							data: CANCELED_EVENT_DATA
						}
					})
				)

				wrapper = mountPollEditor(restRequest, {
					eventId: EVENT_ID
				})

				setTimeout(done, 0)
			})

			it('shows an error modal', () => {
				expect(wrapper.find('#eventNoLongerOpenModal').isVisible()).toBeTruthy()
			})
		})

		describe('if loading is successful', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy("restRequest").and.returnValues(
					Promise.resolve({
						data: {
							data: EVENT_DATA
						}
					}),
					Promise.reject({
						response: {
							status: 422,
							data: {
								errors: {
									"participant": ["can't be blank"]
								}
							}
						}
					}),
					Promise.resolve({
						data: {
							data: POLL_DATA
						}
					})
				)

				wrapper = mountPollEditor(restRequest, {
					eventId: EVENT_ID
				})

				setTimeout(done, 0)
			})

			it('renders the main card', () => {
				expect(wrapper.find('div.card').exists()).toBeTruthy();
			})

			it('renders the event header', () => {
				let eventHeader = wrapper.find('event-header')
				expect(eventHeader.exists).toBeTruthy();
				expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
				expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
				expect(eventHeader.attributes('eventstate')).toBe(EVENT_DATA.state)
				expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
				expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
				expect(eventHeader.attributes('eventtimewindowfrom')).toBeDefined()
				expect(eventHeader.attributes('eventtimewindowto')).toBeDefined()
			})

			it('renders the participant name input', () => {
				expect(wrapper.find('input#pollParticipant').exists()).toBeTruthy()
			})

			it('renders the weekday ranker', () => {
				expect(wrapper.find('ranker').exists()).toBeTruthy();
			})

			it('renders the date picker', () => {
				expect(wrapper.find('v-date-picker').exists()).toBeTruthy();
			})

			it('renders one alert-info', () => {
				expect(wrapper.findAll('.alert.alert-info').length).toBe(1)
			})

			it('renders the right buttons', () => {
				expect(wrapper.find('button[name="save-poll"]').exists()).toBeTruthy();
				expect(wrapper.find('button[name="delete-poll"]').exists()).toBeFalsy();
				expect(wrapper.find('button[name="back-to-event"]').exists()).toBeTruthy();
			})

			it('user can go back to event', () => {
				wrapper.find('button[name="back-to-event"]').trigger('click')
				expect(routerSpy.push).toHaveBeenCalledWith({
					name: 'event',
					params: {
						eventId: EVENT_ID
					}
				});
			})

			describe('when blurring input', () => {

				beforeEach((done) => {
					wrapper.find('input#pollParticipant').trigger('blur')
					setTimeout(done, 0)
				})

				it('triggers local validation', () => {
					expect(wrapper.find('.invalid-feedback[name="poll-participant-error"]').text()).toBe("errors.required_field")
				})
			})

			describe('when adding a new date to the date-picker', () => {

				it('increases the size of the attributes', () => {
					let oldlen = wrapper.vm.datePickerAttributes.length
					wrapper.find('v-date-picker').trigger('input')
					expect(wrapper.vm.datePickerAttributes.length).toBe(oldlen + 1)
				})
			})

			describe('when clicking a date in the date-picker', () => {

				it('dayClicked is called', () => {
					wrapper.find('v-date-picker').trigger('dayclick')
					expect(dayClickedSpy).toHaveBeenCalled()
				})
			})

			describe('when saving the poll with errors', () => {

				beforeEach((done) => {
					wrapper.find('button[name="save-poll"]').trigger('click')
					setTimeout(done, 0)
				})

				it('renders errors', () => {
					expect(wrapper.find('.invalid-feedback[name="poll-participant-error"]').text()).toBe("can't be blank")
					expect(wrapper.find('#pollSavedModal').isVisible()).toBeFalsy()
				})
			})

			describe('when saving the poll successfully', () => {

				beforeEach((done) => {
					wrapper.find('button[name="save-poll"]').trigger('click')
					setTimeout(() => {
						wrapper.find('button[name="save-poll"]').trigger('click')
						setTimeout(done, 0)
					}, 0)
				})

				it('there should be no errors', () => {
					expect(wrapper.find('.invalid-feedback[name="poll-participant-error"]').text()).toBeFalsy()
				})

				it('shows the modal to go back to the event', () => {
					expect(wrapper.find('#pollSavedModal').isVisible()).toBeTruthy()
				})
			})
		})

		describe('if loading fails', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy("restRequest").and.returnValue(Promise.reject())
				wrapper = mountPollEditor(restRequest, {
					eventId: EVENT_ID
				})

				setTimeout(done, 0)
			})

			it('does not render the main card', () => {
				expect(wrapper.find('div.card').exists()).toBeFalsy();
			})

			it('renders an error page', () => {
				expect(wrapper.find('error-page').exists()).toBeTruthy();
			})
		})
	})


	describe('with a pollId', () => {

		it('loads the poll', () => {
			let restRequest = jasmine.createSpy("restRequest").and.returnValue(Promise.resolve(true))
			wrapper = mountPollEditor(restRequest, {
				pollId: POLL_ID
			})
			expect(restRequest).toHaveBeenCalledWith(`polls/${POLL_ID}`)
		})

		describe('when loading a poll for a non-open event', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy("restRequest").and.returnValues(
					Promise.resolve({
						data: {
							data: CANCELED_EVENT_POLL_DATA
						}
					})
				)

				wrapper = mountPollEditor(restRequest, {
					pollId: POLL_ID
				})

				setTimeout(done, 0)
			})

			it('shows an error modal', () => {
				expect(wrapper.find('#eventNoLongerOpenModal').isVisible()).toBeTruthy()
			})
		})

		describe('if loading is successful', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy("restRequest").and.returnValues(
					Promise.resolve({
						data: {
							data: POLL_DATA
						}
					}),
					Promise.reject({
						response: {
							status: 422,
							data: {
								errors: {
									"event": ["no longer open"]
								}
							}
						}
					}),
					Promise.resolve({
						data: {
							data: POLL_DATA
						}
					})
				)

				wrapper = mountPollEditor(restRequest, {
					pollId: POLL_ID
				})

				setTimeout(done, 0)
			})

			it('renders the main card', () => {
				expect(wrapper.find('div.card').exists()).toBeTruthy();
			})

			it('renders the event header', () => {
				let eventHeader = wrapper.find('event-header')
				expect(eventHeader.exists).toBeTruthy();
				expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
				expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
				expect(eventHeader.attributes('eventstate')).toBe(EVENT_DATA.state)
				expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
				expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
				expect(eventHeader.attributes('eventtimewindowfrom')).toBeDefined()
				expect(eventHeader.attributes('eventtimewindowto')).toBeDefined()
			})

			it('does not render the participant name input', () => {
				expect(wrapper.find('input#pollParticipant').exists()).toBeFalsy()
			})

			it('renders the weekday ranker', () => {
				expect(wrapper.find('ranker').exists()).toBeTruthy();
			})

			it('renders the date picker', () => {
				expect(wrapper.find('v-date-picker').exists()).toBeTruthy();
			})

			it('renders one alert-info', () => {
				expect(wrapper.findAll('.alert.alert-info').length).toBe(1)
			})

			it('renders the right buttons', () => {
				expect(wrapper.find('button[name="save-poll"]').exists()).toBeTruthy();
				expect(wrapper.find('button[name="delete-poll"]').exists()).toBeTruthy();
				expect(wrapper.find('button[name="back-to-event"]').exists()).toBeTruthy();
			})

			it('user can go back to event', () => {
				wrapper.find('button[name="back-to-event"]').trigger('click')
				expect(routerSpy.push).toHaveBeenCalledWith({
					name: 'event',
					params: {
						eventId: EVENT_ID
					}
				});
			})

			describe('when blurring input', () => {

				beforeEach((done) => {
					wrapper.find('input#pollParticipant').trigger('blur')
					setTimeout(done, 0)
				})

				it('triggers local validation', () => {
					pending("so far the participant name is the only locally validated input, and not available when updating polls")
					expect(wrapper.find('.invalid-feedback[name="poll-participant-error"]').text()).toBe("errors.required_field")
				})
			})

			describe('when saving the poll with errors', () => {

				beforeEach((done) => {
					wrapper.find('button[name="save-poll"]').trigger('click')
					setTimeout(done, 0)
				})

				it('renders errors', () => {
					expect(wrapper.find('div[name="event-error"]').text()).toBe("no longer open")
					expect(wrapper.find('#pollSavedModal').isVisible()).toBeFalsy()
				})
			})

			describe('when saving the poll successfully', () => {

				beforeEach((done) => {
					wrapper.find('button[name="save-poll"]').trigger('click')
					setTimeout(() => {
						wrapper.find('button[name="save-poll"]').trigger('click')
						setTimeout(done, 0)
					}, 0)
				})

				it('there should be no errors', () => {
					expect(wrapper.find('div[name="event-error"]').text()).toBeFalsy()
				})

				it('shows the modal to go back to the event', () => {
					expect(wrapper.find('#pollSavedModal').isVisible()).toBeTruthy()
				})
			})

			describe('when deleting the poll', () => {

				beforeEach((done) => {
					wrapper.find('button[name="delete-poll"]').trigger('click')

					setTimeout(done, 0)
				})

				it('shows the confirmation modal', () => {
					expect(wrapper.find('#pollDeleteModal').isVisible()).toBeTruthy()
				})

				describe('when the user clicks delete', () => {

					it('deletes the poll', () => {
						wrapper.find('#pollDeleteModal button.btn-danger').trigger('click')
						expect(restRequest).toHaveBeenCalledWith(`polls/${POLL_ID}`, {
							method: 'delete'
						})
					})
				})
			})
		})
	})
})