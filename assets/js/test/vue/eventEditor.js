import eventEditor from '../../vue/eventEditor.vue'
import BootstrapVue from 'bootstrap-vue'
import VueClipboard from 'vue-clipboard2'
import {
	mount,
	createLocalVue
} from '@vue/test-utils'

const routerSpy = jasmine.createSpyObj("routerSpy", ["push"])
const localVue = createLocalVue();
localVue.use(BootstrapVue);
localVue.use(VueClipboard)

const CANT_BE_BLANK = 'can\'t be blank'

function mountEventEditor(restRequest, propsData) {

	const config = {
		mixins: [{
			methods: {
				restRequest,
				collapseAllGroups: () => null // very weird, need to mock this for some reason, the real method does not work here
			}
		}],
		mocks: {
			$t: k => k,
			$tc: k => k,
			$i18n: {
				t: k => k
			},
			$scrollTo: () => null,
			$router: routerSpy
		},
		propsData,
		localVue
	}

	return mount(eventEditor, config)
}

const inputElements = [
	'input#eventOrganizer',
	'input#eventOrganizerEmail',
	'input#eventOrganizerEmailConfirmation',
	'input#eventName',
	'textarea#eventDesc',
	'v-date-picker#eventTimeWindow',
	'ranker#eventWeekdays'
]

const inputElementsForUpdate = [
	'input#eventName',
	'textarea#eventDesc',
	'v-date-picker#eventTimeWindow',
	'ranker#eventWeekdays'
]

const errorElements = [
	'.invalid-feedback[name="event-organizer-error"]',
	'.invalid-feedback[name="event-organizer-email-error"]',
	'.invalid-feedback[name="event-organizer-email-confirmation-error"]',
	'.invalid-feedback[name="event-name-error"]',
	'.invalid-feedback[name="event-desc-error"]',
	'.small.text-danger[name="event-time-window-error"]',
	'.small.text-danger[name="event-weekdays-error"]'
]

const errorElementsForUpdate = [
	'.invalid-feedback[name="event-name-error"]',
	'.invalid-feedback[name="event-desc-error"]',
	'.small.text-danger[name="event-time-window-error"]',
	'.small.text-danger[name="event-weekdays-error"]'
]

const EVENT_ID = "bf6747d5-7b32-4bde-8e2d-c055d9bb02d3"
const EVENT_SECRET = "NGQ4NkdBQWVTd0U9"

const EVENT_DATA = {
	"updated_at": "2018-09-20T17:06:20.000000Z",
	"time_window_to": "2019-12-01",
	"time_window_from": "2019-06-01",
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
	"desc": "Be our guest!"
}


describe('eventEditor', () => {

	let wrapper;
	let restRequest;

	describe('without an eventId', () => {

		describe('after loading', () => {

			beforeEach(() => {
				wrapper = mountEventEditor(restRequest, {})
			})

			it('renders the event header', () => {
				let eventHeader = wrapper.find('event-header')
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
				expect(wrapper.find('div.card').exists()).toBeTruthy();
			})

			it('renders the card body', () => {
				expect(wrapper.find('div.card-body').exists()).toBeTruthy();
			})

			it('renders one alert', () => {
				expect(wrapper.findAll('.alert').length).toBe(1)
			})

			inputElements.forEach(selector => {
				it(`renders input element ${selector}`, () => {
					expect(wrapper.find(selector).exists()).toBeTruthy()
				})
			})

			it('renders only the save button', () => {

				expect(wrapper.find('button[name="save-event"]').exists()).toBeTruthy()
				expect(wrapper.find('button[name="cancel"]').exists()).toBeFalsy()
				expect(wrapper.find('router-link[name="manage-event"]').exists()).toBeFalsy()
			})
		})

		describe('when blurring input', () => {

			beforeEach((done) => {
				wrapper = mountEventEditor(restRequest, {})
				wrapper.find('input#eventOrganizer').trigger('blur')
				setTimeout(done, 0)
			})

			it('triggers local validation', () => {
				expect(wrapper.find('.invalid-feedback[name="event-organizer-error"]').text()).toBe("errors.required_field")
			})
		})

		describe('when saving the event with errors', () => {

			beforeEach((done) => {

				restRequest = jasmine.createSpy().and.returnValue(Promise.reject({
					response: {
						status: 422,
						data: {
							errors: {
								"organizer": [CANT_BE_BLANK],
								"email": [CANT_BE_BLANK],
								"email_confirmation": [CANT_BE_BLANK],
								"desc": [CANT_BE_BLANK],
								"name": [CANT_BE_BLANK],
								"time_window": [CANT_BE_BLANK],
								"preferences": {"weekdays": [CANT_BE_BLANK]}
							}
						}
					}
				}))

				wrapper = mountEventEditor(restRequest, {})
				wrapper.find('button[name="save-event"]').trigger("click")
				setTimeout(done, 0)
			})

			errorElements.forEach(selector => {
				it(`renders error in ${selector}`, () => {
					expect(wrapper.find(selector).text()).toBe(CANT_BE_BLANK)
				})
			})
		})

		describe('when successfully creating an event', () => {

			beforeEach((done) => {

				restRequest = jasmine.createSpy().and.returnValue(Promise.resolve({
					data: {
						data: EVENT_DATA
					}
				}))

				wrapper = mountEventEditor(restRequest, {})
				wrapper.find('button[name="save-event"]').trigger("click")
				setTimeout(done, 0)
			})

			it('renders one alert', () => {
				expect(wrapper.findAll('.alert').length).toBe(1)
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

			it('renders the main card', () => {
				expect(wrapper.find('div.card').exists()).toBeTruthy();
			})

			it('does not render the card body', () => {
				expect(wrapper.find('div.card-body').exists()).toBeFalsy();
			})

			inputElements.forEach(selector => {
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
				expect(wrapper.find('button[name="save-event"]').exists()).toBeFalsy()
				expect(wrapper.find('button[name="cancel"]').exists()).toBeFalsy()
				expect(wrapper.find('router-link[name="manage-event"]').exists()).toBeTruthy()
			})
		})
	})

	describe('with an eventId', () => {

		describe('when loading an existing event', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy().and.returnValue(Promise.resolve({
					data: {
						data: EVENT_DATA
					}
				}))

				wrapper = mountEventEditor(restRequest, {
					eventId: EVENT_ID,
					secret: EVENT_SECRET
				})

				setTimeout(done, 0)
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

			it('renders the main card', () => {
				expect(wrapper.find('div.card').exists()).toBeTruthy();
			})

			it('renders the card body', () => {
				expect(wrapper.find('div.card-body').exists()).toBeTruthy();
			})

			it('renders one alert', () => {
				expect(wrapper.findAll('.alert').length).toBe(1)
			})

			inputElements
				.filter(element => inputElementsForUpdate.indexOf(element) < 0)
				.forEach(selector => {
					it(`does not render input element ${selector}`, () => {
						expect(wrapper.find(selector).exists()).toBeFalsy()
					})
				})

			inputElementsForUpdate.forEach(selector => {
				it(`renders input element ${selector}`, () => {
					expect(wrapper.find(selector).exists()).toBeTruthy()
				})
			})

			it('user can go back to the event', () => {

				wrapper.find('button[name="cancel"]').trigger("click")

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

			it('renders the save and cancel button', () => {

				expect(wrapper.find('button[name="save-event"]').exists()).toBeTruthy()
				expect(wrapper.find('button[name="cancel"]').exists()).toBeTruthy()
				expect(wrapper.find('router-link[name="manage-event"]').exists()).toBeFalsy()
			})

			describe('when blurring input', () => {

				beforeEach((done) => {
					wrapper.vm.eventName = '';
					wrapper.find('input#eventName').trigger('blur')
					setTimeout(done, 0)
				})

				it('triggers local validation', () => {
					expect(wrapper.find('.invalid-feedback[name="event-name-error"]').text()).toBe("errors.required_field")
				})
			})
		})

		describe('when trying to load an event without using the secret', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy().and.returnValue(Promise.resolve({
					data: {
						data: EVENT_DATA
					}
				}))

				wrapper = mountEventEditor(restRequest, {
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

		describe('when trying to load an non-existent event', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy().and.returnValue(Promise.reject({
					response: {
						status: 404
					}
				}))

				wrapper = mountEventEditor(restRequest, {
					eventId: EVENT_ID,
					secret: EVENT_SECRET
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

		describe('when saving an existing event with errors', () => {

			beforeEach((done) => {

				restRequest = jasmine.createSpy().and.returnValues(
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
									"organizer": [CANT_BE_BLANK],
									"email": [CANT_BE_BLANK],
									"email_confirmation": [CANT_BE_BLANK],
									"desc": [CANT_BE_BLANK],
									"name": [CANT_BE_BLANK],
									"time_window": [CANT_BE_BLANK],
									"preferences": {"weekdays": [CANT_BE_BLANK]	}
								}
							}
						}
					}))

				wrapper = mountEventEditor(restRequest, {
					eventId: EVENT_ID,
					secret: EVENT_SECRET
				})

				setTimeout(() => {
					wrapper.find('button[name="save-event"]').trigger("click")
					setTimeout(done, 0)
				}, 0)
			})

			errorElementsForUpdate.forEach(selector => {
				it(`renders error in ${selector}`, () => {
					expect(wrapper.find(selector).text()).toBe(CANT_BE_BLANK)
				})
			})
		})

		describe('when saving an existing event', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy().and.returnValues(Promise.resolve({
						data: {
							data: EVENT_DATA
						}
					}),
					Promise.resolve({
						data: {
							data: EVENT_DATA
						}
					})
				)

				wrapper = mountEventEditor(restRequest, {
					eventId: EVENT_ID,
					secret: EVENT_SECRET
				})

				setTimeout(() => {
					wrapper.find('button[name="save-event"]').trigger('click')
					setTimeout(done, 0)
				}, 0)
			})

			errorElementsForUpdate.forEach(selector => {
				it(`no error in ${selector}`, () => {
					expect(wrapper.find(selector).text()).toBeFalsy()
				})
			})

			it('opens the eventUpdatedModal modal', () => {
				expect(wrapper.find('#eventUpdatedModal').isVisible()).toBeTruthy()
			})

			it('the eventUpdatedModal has a button that takes the user back to the event', () => {
				wrapper.find('#eventUpdatedModal button.btn-primary').trigger('click')

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