import eventEditor from '../../vue/eventEditor.vue'
import BootstrapVue from 'bootstrap-vue'
import VueRouter from 'vue-router'
import VueClipboard from 'vue-clipboard2'

const router = new VueRouter({
	mode: 'history',
	routes: [{
		path: '/events/:eventId',
		name: 'event',
		props: (route) => Object.assign({
			secret: route.query.s
		}, route.params)
	}]
});

import {
	mount,
	createLocalVue
} from '@vue/test-utils'


const CANT_BE_BLANK = 'can\'t be blank'
const localVue = createLocalVue();
localVue.use(BootstrapVue);
localVue.use(VueRouter)
localVue.use(VueClipboard)

function mountEventEditor(restRequest, propsData) {
	return mount(eventEditor, {
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
			$scrollTo: () => null
		},
		propsData,
		localVue,
		router
	})
}

const inputElements = [
	'input#eventOrganizer',
	'input#eventOrganizerEmail',
	'input#eventOrganizerEmailConfirmation',
	'input#eventName',
	'textarea#eventDesc',
	'v-date-picker#eventTimeWindow'
]

const errorElements = [
	'.invalid-feedback[name="event-organizer-error"]',
	'.invalid-feedback[name="event-organizer-email-error"]',
	'.invalid-feedback[name="event-organizer-email-confirmation-error"]',
	'.invalid-feedback[name="event-name-error"]',
	'.invalid-feedback[name="event-desc-error"]',
	'.small.text-danger[name="event-time-window-error"]'
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
	"name": "dsd",
	"inserted_at": "2018-09-20T17:06:20.000000Z",
	"id": EVENT_ID,
	"email": "maxmarcon@gmx.net",
	"desc": "Be our guest!"
}


describe('without an eventId', () => {

	let wrapper;
	let restRequest;

	describe('when loading the page', () => {

		beforeEach(() => {
			wrapper = mountEventEditor(restRequest, {})
		})

		it('renders one info element', () => {
			expect(wrapper.findAll('.alert-info').length).toBe(1)
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
							"time_window": [CANT_BE_BLANK]
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


	describe('when creating an event', () => {

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
			expect(wrapper.find(`a[name="manage-event"][href="/events/${EVENT_ID}?s=${EVENT_SECRET}"]`).exists()).toBeTruthy()
		})

	})
})