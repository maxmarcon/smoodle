import eventHeader from '../../vue/eventHeader.vue'

import {
	mount,
	createLocalVue
} from '@vue/test-utils'

const localVue = createLocalVue()
const EVENT_DATA = {
	"time_window": "2019-12-01 - 2019-06-01",
	"scheduled_to": null,
	"scheduled_from": null,
	"organizer": "Max",
	"name": "Party",
}

const OPEN_EVENT = {
	eventName: EVENT_DATA.name,
	eventOrganizer: EVENT_DATA.organizer,
	eventTimeWindow: EVENT_DATA.time_window,
	eventScheduledFrom: EVENT_DATA.scheduled_from,
	eventScheduledTo: EVENT_DATA.scheduled_to,
	eventState: "OPEN"
}

const SCHEDULED_EVENT = {
	eventName: EVENT_DATA.name,
	eventOrganizer: EVENT_DATA.organizer,
	eventTimeWindow: EVENT_DATA.time_window,
	eventScheduledFrom: EVENT_DATA.scheduled_from,
	eventScheduledTo: EVENT_DATA.scheduled_to,
	eventState: "SCHEDULED"
}

const CANCELED_EVENT = {
	eventName: EVENT_DATA.name,
	eventOrganizer: EVENT_DATA.organizer,
	eventTimeWindow: EVENT_DATA.time_window,
	eventScheduledFrom: EVENT_DATA.scheduled_from,
	eventScheduledTo: EVENT_DATA.scheduled_to,
	eventState: "CANCELED"
}

describe('eventHeader', () => {

	let wrapper

	describe('open event', () => {

		beforeEach(() => {

			wrapper = mount(eventHeader, {
				mocks: {
					$t: (k) => k,
					$i18n: {
						t: (k) => k
					}
				},
				localVue,
				propsData: OPEN_EVENT
			})
		})

		it('renders the event name', () => {
			expect(wrapper.find('h5.card-title').text()).toBe(OPEN_EVENT.eventName)
		})

		it('renders the organizer name', () => {
			expect(wrapper.find('small').text()).toBe('event_header.by')
		})

		it('renders the event dates', () => {
			expect(wrapper.find('h6.card-subtitle').text()).toBe('event_header.open')
		})
	})

	describe('scheduled event', () => {

		beforeEach(() => {

			wrapper = mount(eventHeader, {
				mocks: {
					$t: (k) => k,
					$i18n: {
						t: (k) => k
					}
				},
				localVue,
				propsData: SCHEDULED_EVENT
			})
		})

		it('renders the event name', () => {
			expect(wrapper.find('h5.card-title').text()).toBe(SCHEDULED_EVENT.eventName)
		})

		it('renders the organizer name', () => {
			expect(wrapper.find('small').text()).toBe('event_header.by')
		})

		it('renders the event dates', () => {
			expect(wrapper.find('h6.card-subtitle').text()).toBe('event_header.scheduled')
		})
	})

	describe('canceled event', () => {

		beforeEach(() => {

			wrapper = mount(eventHeader, {
				mocks: {
					$t: (k) => k,
					$i18n: {
						t: (k) => k
					}
				},
				localVue,
				propsData: CANCELED_EVENT
			})
		})

		it('renders the event name', () => {
			expect(wrapper.find('h5.card-title').text()).toBe(CANCELED_EVENT.eventName)
		})

		it('renders the organizer name', () => {
			expect(wrapper.find('small').text()).toBe('event_header.by')
		})

		it('renders the event dates', () => {
			expect(wrapper.find('h6.card-subtitle').text()).toBe('event_header.canceled')
		})
	})
})
