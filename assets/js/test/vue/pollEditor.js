import pollEditor from '../../vue/pollEditor.vue'
import BootstrapVue from 'bootstrap-vue'
import VueRouter from 'vue-router'
import Promise from 'es6-promise'

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


let routerSpy = jasmine.createSpyObj("router", ["push"])

function mountPollEditor(restRequest, propsData) {
	return shallowMount(pollEditor, {
		mixins: [{
			methods: {
				restRequest
			}
		}],
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
			let restRequest = jasmine.createSpy("restRequest").and.returnValue(Promise.resolve(true))
			wrapper = mountPollEditor(restRequest, {
				eventId: EVENT_ID
			})
			expect(restRequest).toHaveBeenCalledWith(`events/${EVENT_ID}`)
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
					})
				)

				wrapper = mountPollEditor(restRequest, {
					eventId: EVENT_ID
				})

				wrapper.vm.$nextTick(done)
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
					wrapper.vm.$nextTick(done)
				})

				it('triggers local validation', () => {
					expect(wrapper.find('.invalid-feedback[name="poll-participant-error"]').text()).toBe("errors.required_field")
				})
			})

			describe('when saving the poll with errors', () => {

				beforeEach((done) => {
					wrapper.find('button[name="save-poll"]').trigger('click')
					wrapper.vm.$nextTick(done)
				})

				it('renders errors', (done) => {

					wrapper.vm.$nextTick(() => {
						expect(wrapper.find('.invalid-feedback[name="poll-participant-error"]').text()).toBe("can't be blank")
						done()
					})
				})
			})
		})

		describe('if loading fails', () => {

			beforeEach((done) => {
				restRequest = jasmine.createSpy("restRequest").and.returnValue(Promise.reject())
				wrapper = mountPollEditor(restRequest, {
					eventId: EVENT_ID
				})

				wrapper.vm.$nextTick(done)
			})

			it('does not render the main card', () => {
				expect(wrapper.find('div.card').exists()).toBeFalsy();
			})

			it('renders an error page', () => {
				expect(wrapper.find('error-page').exists()).toBeTruthy();
			})
		})
	})
})