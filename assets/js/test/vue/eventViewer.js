import eventViewer from '../../vue/eventViewer.vue'
import BootstrapVue from 'bootstrap-vue'
import VueRouter from 'vue-router'
import VueClipboard from 'vue-clipboard2'
import {
	mount,
	createLocalVue
} from '@vue/test-utils'

const routerSpy = jasmine.createSpyObj("routerSpy", ["push"])

const router = new VueRouter({
	mode: 'history',
	routes: [{
		path: '/events/:eventId/polls/new',
		name: 'new_poll',
		component: PollEditor,
		props: true
	}, {
		path: '/events/:eventId/edit',
		name: 'edit_event',
		component: EventEditor,
		props: (route) => Object.assign({
			secret: route.query.s
		}, route.params)
	}]
});

function mountEventViewer(restRequest, propsData, withRouter = true) {
	const localVue = createLocalVue();
	localVue.use(BootstrapVue);
	localVue.use(VueClipboard)
	if (withRouter) {
		localVue.use(VueRouter)
	}

	let config = {
		mixins: [{
			methods: {
				restRequest
			}
		}],
		mocks: {
			$t: k => k,
			$tc: k => k,
			$i18n: {
				t: k => k
			},
		},
		propsData,
		localVue
	}
	if (withRouter) {
		config.router = router
	} else {
		config.mocks.$router = routerSpy
	}

	return mount(eventViewer, config)
}


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

const SCHEDULE_DATA = {
	participants_count: 5,
	participants: [],
	dates: [{
		"positive_rank": 1,
		"negative_rank": 0,
		"date": "2018-09-29"
	}, {
		"positive_rank": 1,
		"negative_rank": 0,
		"date": "2018-09-30"
	}, {
		"positive_rank": 1,
		"negative_rank": 0,
		"date": "2018-10-06"
	}]
}

const SCHEDULE_DATA_SECRET = {
	participants_count: 5,
	participants: ['A', 'B', 'C', 'D', 'E'],
	dates: [{
		"positive_rank": 1,
		"negative_rank": 0,
		"date": "2018-09-29",
		"positive_participants": [
			"A", "B"
		],
		"negative_participants": [
			"C", "D", "E"
		]
	}, {
		"positive_rank": 1,
		"negative_rank": 0,
		"date": "2018-09-30",
		"positive_participants": [
			"A", "B"
		],
		"negative_participants": [
			"C", "D", "E"
		]

	}, {
		"positive_rank": 1,
		"negative_rank": 0,
		"date": "2018-10-06",
		"positive_participants": [
			"A", "B"
		],
		"negative_participants": [
			"C", "D", "E"
		]
	}]
}

let buttonSelectors = {
	organizer: {
		open: ['a[name="edit-button"]', 'button[name="cancel-button"]'],
		closed: ['button[name="open-button"]'],
		openWithParticipants: ['a[name="edit-button"]', 'button[name="cancel-button"]', 'button[name="schedule-button"]']
	},
	guest: {
		open: [
			'a[name="new-poll-button"]',
		],
		openWithParticipants: [
			'a[name="new-poll-button"]',
			'button[name="edit-poll-button"]'
		]
	}
}

function makeEvent(type = 'OPEN', withSecret = false) {
	const eventData = EVENT_DATA

	if (type == 'CANCELED') {
		eventData.state = type
	} else if (type == 'SCHEDULED') {
		eventData.state = type
		eventData.scheduled_from = '2018-10-17T17:30:00.000000Z'
		eventData.scheduled_to = '2018-10-17T19:30:00.000000Z'
	}

	if (!withSecret) {
		delete eventData['secret']
		delete eventData['owner_link']
		delete eventData['email']
		delete eventData['share_link']
	}

	return eventData
}

function makeSchedule(withParticipants = false, withSecret = false) {
	const schedule = withSecret ? SCHEDULE_DATA_SECRET : SCHEDULE_DATA

	if (!withParticipants) {
		schedule.participants_count = 0
		schedule.participants = []
		schedule.dates = []
	}

	return schedule
}

describe('eventViewer', () => {

	let wrapper
	let restRequest

	describe('without secret', () => {

		describe('open event', () => {

			describe('with participants', () => {

				beforeEach((done) => {

					restRequest = jasmine.createSpy('restRequest').and.callFake((path) => {
						if (path == `events/${EVENT_ID}`) {
							return Promise.resolve({
								data: {
									data: makeEvent()
								}
							})
						} else if (path == `events/${EVENT_ID}/schedule`) {
							return Promise.resolve({
								data: {
									data: makeSchedule(true)
								}
							})
						} else {
							return Promise.reject()
						}
					})

					wrapper = mountEventViewer(restRequest, {
						eventId: EVENT_ID
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

				it('renders the right buttons', () => {
					buttonSelectors.guest.openWithParticipants.forEach(selector => {
						expect(wrapper.find(selector).exists()).toBeTruthy()
					})
				})
			})

			describe("without participants", () => {

			})
		})

		describe('canceled event', () => {

		})

		describe('scheduled event', () => {

		})
	})

	describe('with secret', () => {

		describe('open event', () => {

			describe("with participants", () => {

			})

			describe("without participants", () => {

			})

		})


		describe('canceled event', () => {

		})

		describe('scheduled event', () => {

		})
	})
})