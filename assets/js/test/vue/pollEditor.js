import pollEditor from '../../vue/pollEditor.vue'
import BootstrapVue from 'bootstrap-vue'
import {
	mount,
	createLocalVue
} from '@vue/test-utils'

const localVue = createLocalVue();
localVue.use(BootstrapVue);

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


const routerSpy = jasmine.createSpyObj("router", ["push"])
const newDateSpy = jasmine.createSpy("newDate")

function mountPollEditor(restRequest, propsData) {

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
			$t: k => k,
			$tc: k => k,
			$i18n: {
				t: k => k
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
				restRequest = jasmine.createSpy("restRequest").and.returnValue(
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
				expect(wrapper.find('#eventErrorModal').isVisible()).toBeTruthy()
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
				expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
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

			it('renders one alert', () => {
				expect(wrapper.findAll('.alert').length).toBe(1)
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

			describe('when a date is selected in the date-picker', () => {

				it('newDate is called', () => {
					wrapper.find('v-date-picker').trigger('input')
					expect(newDateSpy).toHaveBeenCalled()
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
				expect(wrapper.find('#eventErrorModal').isVisible()).toBeTruthy()
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
				expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
			})

			it('does not render the participant name input', () => {
				expect(wrapper.find('input#pollParticipant').exists()).toBeFalsy()
			})

			it('renders the ranker', () => {
				expect(wrapper.find('ranker#pollWeekdayRanks').exists()).toBeTruthy();
			})

			it('computes the poll weekday ranks', () => {
				expect(wrapper.vm.pollWeekdayRanks
						.filter(obj => obj.value != 0).map(({
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
					}) => day == event_day)
					expect(wr).toBeDefined()
					expect(wr.disabled).toBeTruthy()
				})
			})

			it('renders the date picker', () => {
				expect(wrapper.find('v-date-picker#pollDateRanks').exists()).toBeTruthy();
			})

			it('computes datePickerAttributes', () => {
				expect(wrapper.vm.datePickerAttributes.length).toBeGreaterThan(0)
			})

			it('renders one alert', () => {
				expect(wrapper.findAll('.alert').length).toBe(1)
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
					expect(wrapper.vm.eventError).toBe("no longer open")
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
					expect(wrapper.vm.eventError).toBeFalsy()
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