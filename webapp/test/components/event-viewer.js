import eventViewer from '../../src/components/event-viewer.vue'
import BootstrapVue from 'bootstrap-vue'
import VueClipboard from 'vue-clipboard2'
import i18nMock from '../test-utils/i18n-mock'
import wait from '../test-utils/wait'
import {createLocalVue, mount} from '@vue/test-utils'

const routerSpy = jasmine.createSpyObj("routerSpy", ["push"])

const localVue = createLocalVue();
localVue.use(BootstrapVue);
localVue.use(VueClipboard)

function mountEventViewer(restRequest, propsData) {

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
            $router: routerSpy,
            $scrollTo: () => null
        },
        propsData,
        localVue,
        stubs: ['message-bar', 'event-header', 'v-calendar',
            'router-link', 'v-date-picker', 'i18n', 'date-picker', 'error-page'
        ]
    }

    return mount(eventViewer, config)
}

const EVENT_ID = "bf6747d5-7b32-4bde-8e2d-c055d9bb02d3"
const EVENT_SECRET = "NGQ4NkdBQWVTd0U9"

const EVENT_DATA = {
    "updated_at": "2018-09-20T17:06:20.000000Z",
    "possible_dates": [{
        "date_to": "2019-12-01",
        "date_from": "2019-06-01"
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

const POLL_PARTICIPANT = 'Fritz'
const POLL_ID = "599a1056-3cea-4c4e-b54c-5fd376f0f632";

const NEW_POLL_BUTTON = 'router-link-stub[name="new-poll-button"]'
const EDIT_EVENT_BUTTON = 'router-link-stub[name="edit-button"]'
const CANCEL_EVENT_BUTTON = 'button[name="cancel-button"]'
const EDIT_POLL_BUTTON = 'button[name="edit-poll-button"]'
const OPEN_EVENT_BUTTON = 'button[name="open-button"]'
const SCHEDULE_EVENT_BUTTON = 'button[name="schedule-button"]'
const ORGANIZER_MESSAGE = 'this is a message from the organizer'

const buttonSelectors = {
    organizer: {
        open: [EDIT_EVENT_BUTTON, CANCEL_EVENT_BUTTON],
        closed: [OPEN_EVENT_BUTTON],
        openWithParticipants: [EDIT_EVENT_BUTTON, CANCEL_EVENT_BUTTON, SCHEDULE_EVENT_BUTTON]
    },
    guest: {
        open: [
            NEW_POLL_BUTTON,
        ],
        openWithParticipants: [
            NEW_POLL_BUTTON,
            EDIT_POLL_BUTTON
        ]
    },
    all: [
        NEW_POLL_BUTTON, EDIT_EVENT_BUTTON, CANCEL_EVENT_BUTTON,
        EDIT_POLL_BUTTON, OPEN_EVENT_BUTTON, SCHEDULE_EVENT_BUTTON
    ]
}

const EVENT_INTRO = 'p[name="event-intro"]'

function makeEvent(type = 'OPEN', withSecret = false) {
    const eventData = Object.assign({}, EVENT_DATA)

    if (type === 'CANCELED') {
        eventData.state = type
    } else if (type === 'SCHEDULED') {
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
    const schedule = Object.assign({}, (withSecret ? SCHEDULE_DATA_SECRET : SCHEDULE_DATA))

    if (!withParticipants) {
        schedule.participants_count = 0
        schedule.participants = []
        schedule.dates = []
    }

    return schedule
}

let wrapper
let restRequest

describe('eventViewer', () => {

    describe('when loading fails', () => {

        beforeEach(async () => {

            restRequest = jasmine.createSpy('restRequest').and.returnValue(Promise.reject())

            wrapper = mountEventViewer(restRequest, {
                eventId: EVENT_ID
            })

            await wait()
        })

        it('does not render the main card', () => {
            expect(wrapper.find('div.card').exists()).toBeFalsy();
        })

        it('shows the error page', () => {
            expect(wrapper.find('error-page-stub').exists()).toBeTruthy()
        })
    })

    describe('without secret', () => {

        describe('open event', () => {

            describe('with participants', () => {

                beforeEach(async () => {

                    restRequest = jasmine.createSpy('restRequest').and.callFake((path, config) => {
                        if (path === `events/${EVENT_ID}`) {
                            return Promise.resolve({
                                data: {
                                    data: makeEvent()
                                }
                            })
                        } else if (path === `events/${EVENT_ID}/schedule`) {
                            return Promise.resolve({
                                data: {
                                    data: makeSchedule(true)
                                }
                            })
                        } else if (path === `events/${EVENT_ID}/polls` && config.params.participant === POLL_PARTICIPANT) {
                            return Promise.resolve({
                                data: {
                                    data: {
                                        id: POLL_ID
                                    }
                                }
                            })
                        }
                        return Promise.reject()
                    })

                    wrapper = mountEventViewer(restRequest, {
                        eventId: EVENT_ID
                    })

                    await wait()
                })

                it('renders event header', () => {
                    let eventHeader = wrapper.find('event-header-stub')
                    expect(eventHeader.exists).toBeTruthy();
                    expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
                    expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
                    expect(eventHeader.attributes('eventstate')).toBe(EVENT_DATA.state)
                    expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
                    expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
                    expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
                })

                it('renders main card', () => {
                    expect(wrapper.find('div.card').exists()).toBeTruthy();
                })

                buttonSelectors.all.forEach(selector => {
                    if (buttonSelectors.guest.openWithParticipants.indexOf(selector) > -1) {
                        it(`renders ${selector}`, () => {
                            expect(wrapper.find(selector).exists()).toBeTruthy()
                        })
                    } else {
                        it(`does not render ${selector}`, () => {
                            expect(wrapper.find(selector).exists()).toBeFalsy()
                        })
                    }
                })

                it('renders event intro', () => {
                    expect(wrapper.find(EVENT_INTRO).exists()).toBeTruthy()
                })

                it('renders two alerts', () => {
                    expect(wrapper.findAll('.alert').length).toBe(2)
                })

                it('renders calendar', () => {
                    expect(wrapper.find('v-calendar-stub').exists()).toBeTruthy()
                })

                it('it computes scheduleCalendarAttributes', () => {
                    expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(SCHEDULE_DATA.dates.length)
                    wrapper.vm.scheduleCalendarAttributes.forEach((attr) => expect(attr.dates instanceof Date).toBeTruthy())
                })

                describe('clicking on update availability', () => {

                    beforeEach(async () => {
                        wrapper.find(EDIT_POLL_BUTTON).trigger("click")
                        await wait()
                    })

                    it('opens modal', () => {
                        expect(wrapper.find('#updateAnswerModal').isVisible()).toBeTruthy()
                    })

                    describe('clicking on the load button', () => {

                        beforeEach(async () => {
                            wrapper.find('input#pollParticipant').setValue(POLL_PARTICIPANT)
                            await wait();
                        })

                        beforeEach(async () => {
                            wrapper.find('#updateAnswerModal button.btn.btn-primary').trigger('click')
                            await wait()
                        })

                        it('takes user to editor for the poll', () => {
                            expect(routerSpy.push).toHaveBeenCalledWith({
                                name: 'edit_poll',
                                params: {
                                    pollId: POLL_ID
                                }
                            })
                        })
                    })
                })
            })

            describe("without participants", () => {

                beforeEach(async () => {
                    restRequest = jasmine.createSpy('restRequest').and.callFake((path) => {
                        if (path === `events/${EVENT_ID}`) {
                            return Promise.resolve({
                                data: {
                                    data: makeEvent()
                                }
                            })
                        } else if (path === `events/${EVENT_ID}/schedule`) {
                            return Promise.resolve({
                                data: {
                                    data: makeSchedule(false)
                                }
                            })
                        }
                        return Promise.reject()
                    })

                    wrapper = mountEventViewer(restRequest, {
                        eventId: EVENT_ID
                    })

                    await new Promise(resolve => setTimeout(resolve, 0))
                })

                it('renders event header', () => {
                    let eventHeader = wrapper.find('event-header-stub')
                    expect(eventHeader.exists).toBeTruthy();
                    expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
                    expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
                    expect(eventHeader.attributes('eventstate')).toBe(EVENT_DATA.state)
                    expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
                    expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
                    expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
                })

                it('it computes scheduleCalendarAttributes', () => {
                    expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(0)
                })

                it('renders main card', () => {
                    expect(wrapper.find('div.card').exists()).toBeTruthy();
                })

                it('it computes scheduleCalendarAttributes', () => {
                    expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(0)
                })

                buttonSelectors.all.forEach(selector => {
                    if (buttonSelectors.guest.open.indexOf(selector) > -1) {
                        it(`renders ${selector}`, () => {
                            expect(wrapper.find(selector).exists()).toBeTruthy()
                        })
                    } else {
                        it(`does not render ${selector}`, () => {
                            expect(wrapper.find(selector).exists()).toBeFalsy()
                        })
                    }
                })

                it('renders event intro', () => {
                    expect(wrapper.find(EVENT_INTRO).exists()).toBeTruthy()
                })

                it('renders two alerts', () => {
                    expect(wrapper.findAll('.alert').length).toBe(2)
                })

                it('does not render calendar', () => {
                    expect(wrapper.find('v-calendar-stub').exists()).toBeFalsy()
                })
            })
        })

        describe('canceled event', () => {

            beforeEach(async () => {
                restRequest = jasmine.createSpy('restRequest').and.callFake((path) => {
                    if (path === `events/${EVENT_ID}`) {
                        return Promise.resolve({
                            data: {
                                data: makeEvent('CANCELED')
                            }
                        })
                    } else if (path === `events/${EVENT_ID}/schedule`) {
                        return Promise.resolve({
                            data: {
                                data: makeSchedule(false)
                            }
                        })
                    }
                    return Promise.reject()
                })

                wrapper = mountEventViewer(restRequest, {
                    eventId: EVENT_ID
                })
                await wait()
            })

            it('renders event header', () => {
                let eventHeader = wrapper.find('event-header-stub')
                expect(eventHeader.exists).toBeTruthy();
                expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
                expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
                expect(eventHeader.attributes('eventstate')).toBe("CANCELED")
                expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
                expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
                expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
            })

            it('it computes scheduleCalendarAttributes', () => {
                expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(0)
            })

            it('renders main card', () => {
                expect(wrapper.find('div.card').exists()).toBeTruthy();
            })

            it('renders event intro', () => {
                expect(wrapper.find(EVENT_INTRO).exists()).toBeTruthy()
            })

            it('renders one alert', () => {
                expect(wrapper.findAll('.alert').length).toBe(1)
            })

            it('does not render calendar', () => {
                expect(wrapper.find('v-calendar').exists()).toBeFalsy()
            })

            buttonSelectors.all.forEach(selector => {
                it(`does not render ${selector}`, () => {
                    expect(wrapper.find(selector).exists()).toBeFalsy()
                })
            })
        })

        describe('scheduled event', () => {

            beforeEach(async () => {
                restRequest = jasmine.createSpy('restRequest').and.callFake((path) => {
                    if (path === `events/${EVENT_ID}`) {
                        return Promise.resolve({
                            data: {
                                data: makeEvent('SCHEDULED')
                            }
                        })
                    } else if (path === `events/${EVENT_ID}/schedule`) {
                        return Promise.resolve({
                            data: {
                                data: makeSchedule(false)
                            }
                        })
                    }
                    return Promise.reject()
                })

                wrapper = mountEventViewer(restRequest, {
                    eventId: EVENT_ID
                })
                await wait()
            })

            it('renders event header', () => {
                let eventHeader = wrapper.find('event-header-stub')
                expect(eventHeader.exists).toBeTruthy();
                expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
                expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
                expect(eventHeader.attributes('eventstate')).toBe("SCHEDULED")
                expect(eventHeader.attributes('eventscheduledfrom')).toBeDefined()
                expect(eventHeader.attributes('eventscheduledto')).toBeDefined()
                expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
            })

            it('it computes scheduleCalendarAttributes', () => {
                expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(0)
            })

            it('renders main card', () => {
                expect(wrapper.find('div.card').exists()).toBeTruthy();
            })

            it('renders event intro', () => {
                expect(wrapper.find(EVENT_INTRO).exists()).toBeTruthy()
            })

            it('renders one alert', () => {
                expect(wrapper.findAll('.alert').length).toBe(1)
            })

            it('renders the calendar', () => {
                expect(wrapper.find('v-calendar-stub').exists()).toBeTruthy()
            })

            buttonSelectors.all.forEach(selector => {
                it(`does not render ${selector}`, () => {
                    expect(wrapper.find(selector).exists()).toBeFalsy()
                })
            })
        })
    })

    describe('with secret', () => {

        describe('open event', () => {

            describe("with participants", () => {

                beforeEach(async () => {

                    restRequest = jasmine.createSpy('restRequest').and.callFake((path) => {
                        if (path === `events/${EVENT_ID}`) {
                            return Promise.resolve({
                                data: {
                                    data: makeEvent("OPEN", true)
                                }
                            })
                        } else if (path === `events/${EVENT_ID}/schedule`) {
                            return Promise.resolve({
                                data: {
                                    data: makeSchedule(true, true)
                                }
                            })
                        }
                        return Promise.reject()
                    })

                    wrapper = mountEventViewer(restRequest, {
                        eventId: EVENT_ID,
                        secret: EVENT_SECRET
                    })

                    await wait()
                })

                it('renders event header', () => {
                    let eventHeader = wrapper.find('event-header-stub')
                    expect(eventHeader.exists).toBeTruthy();
                    expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
                    expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
                    expect(eventHeader.attributes('eventstate')).toBe(EVENT_DATA.state)
                    expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
                    expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
                    expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
                })

                it('renders main card', () => {
                    expect(wrapper.find('div.card').exists()).toBeTruthy();
                })

                it('it computes scheduleCalendarAttributes', () => {
                    expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(SCHEDULE_DATA.dates.length)
                    wrapper.vm.scheduleCalendarAttributes.forEach((attr) => expect(attr.dates instanceof Date).toBeTruthy())
                })

                buttonSelectors.all.forEach(selector => {
                    if (buttonSelectors.organizer.openWithParticipants.indexOf(selector) > -1) {
                        it(`renders ${selector}`, () => {
                            expect(wrapper.find(selector).exists()).toBeTruthy()
                        })
                    } else {
                        it(`does not render ${selector}`, () => {
                            expect(wrapper.find(selector).exists()).toBeFalsy()
                        })
                    }
                })

                it('renders event intro', () => {
                    expect(wrapper.find(EVENT_INTRO).exists()).toBeTruthy()
                })

                it('renders two alerts', () => {
                    expect(wrapper.findAll('.alert').length).toBe(2)
                })

                it('renders date picker', () => {
                    expect(wrapper.find('v-date-picker-stub').exists()).toBeTruthy()
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

                describe('clicking on schedule event', () => {

                    beforeEach(async () => {

                        wrapper.find(SCHEDULE_EVENT_BUTTON).trigger('click')

                        await wait()
                    })

                    it('opens modal', () => {
                        expect(wrapper.find('#scheduleEventModal').isVisible()).toBeTruthy()
                    })

                    describe('clicking on the primary button in the modal without a selected date', () => {

                        beforeEach(async () => {
                            wrapper.find('#scheduleEventModal button.btn-primary').trigger('click')
                            await wait()
                        })

                        it('only closes the modal', () => {
                            expect(restRequest).toHaveBeenCalledTimes(2)
                            expect(wrapper.find('#scheduleEventModal').isVisible()).toBeFalsy()
                        })
                    })

                    describe('clicking on the primary button in the modal with a selected date', () => {

                        beforeEach(async () => {
                            wrapper.vm.selectedDate = wrapper.vm.scheduleCalendarAttributes[0].dates
                            await wait()
                        })

                        beforeEach(async () => {
                            wrapper.find('#scheduleEventModal textarea#scheduleOrganizerMessage').setValue(ORGANIZER_MESSAGE)
                            wrapper.find('#scheduleEventModal button.btn-primary').trigger('click')
                            await wait()
                        })

                        it('schedules the event', () => {
                            expect(restRequest).toHaveBeenCalledTimes(3)
                            // must use regex and not exact time match because the value sent by the browser
                            // depends on the time zone
                            const TIME_REGEX = /2018-09-(29|30)T\d{2}:\d{2}:\d{2}\.\d{3}Z/

                            let scheduleCallbackArgs = restRequest.calls.mostRecent().args
                            expect(scheduleCallbackArgs[0]).toEqual('events/bf6747d5-7b32-4bde-8e2d-c055d9bb02d3')
                            expect(scheduleCallbackArgs[1].method).toEqual('patch')
                            expect(scheduleCallbackArgs[1].data.event.state).toEqual('SCHEDULED')
                            expect(scheduleCallbackArgs[1].data.event.secret).toEqual(EVENT_SECRET)
                            expect(scheduleCallbackArgs[1].data.event.scheduled_from).toMatch(TIME_REGEX)
                            expect(scheduleCallbackArgs[1].data.event.scheduled_to).toMatch(TIME_REGEX)
                            expect(scheduleCallbackArgs[1].data.event.organizer_message).toEqual(ORGANIZER_MESSAGE)

                            expect(wrapper.find('#scheduleEventModal').isVisible()).toBeFalsy()
                        })
                    })
                })

                describe('clicking on cancel event', () => {

                    beforeEach(async () => {

                        wrapper.find(CANCEL_EVENT_BUTTON).trigger('click')

                        await wait()
                    })

                    it('opens modal', () => {
                        expect(wrapper.find('#cancelEventModal').isVisible()).toBeTruthy()
                    })

                    describe('clicking on primary button within the modal', () => {

                        beforeEach(async () => {

                            wrapper.find('#cancelEventModal textarea#cancelOrganizerMessage').setValue(ORGANIZER_MESSAGE)
                            wrapper.find('#cancelEventModal button.btn-primary').trigger('click')

                            await wait()
                        })

                        it('cancels the event', () => {
                            expect(restRequest).toHaveBeenCalledWith(`events/${EVENT_ID}`, {
                                method: 'patch',
                                data: {
                                    event: {
                                        state: 'CANCELED',
                                        secret: EVENT_SECRET,
                                        organizer_message: ORGANIZER_MESSAGE
                                    }
                                }
                            })
                        })
                    })
                })
            })

            describe("without participants", () => {

                beforeEach(async () => {
                    restRequest = jasmine.createSpy('restRequest').and.callFake((path) => {
                        if (path === `events/${EVENT_ID}`) {
                            return Promise.resolve({
                                data: {
                                    data: makeEvent('OPEN', true)
                                }
                            })
                        } else if (path === `events/${EVENT_ID}/schedule`) {
                            return Promise.resolve({
                                data: {
                                    data: makeSchedule(false, true)
                                }
                            })
                        }
                        return Promise.reject()
                    })

                    wrapper = mountEventViewer(restRequest, {
                        eventId: EVENT_ID,
                        secret: EVENT_SECRET
                    })
                    await wait()
                })

                it('renders event header', () => {
                    let eventHeader = wrapper.find('event-header-stub')
                    expect(eventHeader.exists).toBeTruthy();
                    expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
                    expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
                    expect(eventHeader.attributes('eventstate')).toBe(EVENT_DATA.state)
                    expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
                    expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
                    expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
                })

                it('it computes scheduleCalendarAttributes', () => {
                    expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(0)
                })

                it('renders main card', () => {
                    expect(wrapper.find('div.card').exists()).toBeTruthy();
                })

                it('it computes scheduleCalendarAttributes', () => {
                    expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(0)
                })

                buttonSelectors.all.forEach(selector => {
                    if (buttonSelectors.organizer.open.indexOf(selector) > -1) {
                        it(`renders ${selector}`, () => {
                            expect(wrapper.find(selector).exists()).toBeTruthy()
                        })
                    } else {
                        it(`does not render ${selector}`, () => {
                            expect(wrapper.find(selector).exists()).toBeFalsy()
                        })
                    }
                })

                it('renders event intro', () => {
                    expect(wrapper.find(EVENT_INTRO).exists()).toBeTruthy()
                })

                it('renders two alert', () => {
                    expect(wrapper.findAll('.alert').length).toBe(2)
                })

                it('does not render date picker', () => {
                    expect(wrapper.find('v-date-picker-stub').exists()).toBeFalsy()
                })
            })
        })

        describe('canceled event', () => {

            beforeEach(async () => {
                restRequest = jasmine.createSpy('restRequest').and.callFake((path) => {
                    if (path === `events/${EVENT_ID}`) {
                        return Promise.resolve({
                            data: {
                                data: makeEvent('CANCELED', true)
                            }
                        })
                    } else if (path === `events/${EVENT_ID}/schedule`) {
                        return Promise.resolve({
                            data: {
                                data: makeSchedule(false, true)
                            }
                        })
                    }
                    return Promise.reject()
                })

                wrapper = mountEventViewer(restRequest, {
                    eventId: EVENT_ID,
                    secret: EVENT_SECRET
                })
                await wait()
            })

            it('renders event header', () => {
                let eventHeader = wrapper.find('event-header-stub')
                expect(eventHeader.exists).toBeTruthy();
                expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
                expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
                expect(eventHeader.attributes('eventstate')).toBe("CANCELED")
                expect(eventHeader.attributes('eventscheduledfrom')).toBeUndefined()
                expect(eventHeader.attributes('eventscheduledto')).toBeUndefined()
                expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
            })

            it('it computes scheduleCalendarAttributes', () => {
                expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(0)
            })

            it('renders main card', () => {
                expect(wrapper.find('div.card').exists()).toBeTruthy();
            })

            it('renders event intro', () => {
                expect(wrapper.find(EVENT_INTRO).exists()).toBeTruthy()
            })

            it('renders one alert', () => {
                expect(wrapper.findAll('.alert').length).toBe(1)
            })

            it('does not render the date picker', () => {
                expect(wrapper.find('v-date-picker-stub').exists()).toBeFalsy()
            })

            buttonSelectors.all.forEach(selector => {
                if (buttonSelectors.organizer.closed.indexOf(selector) > -1) {
                    it(`renders ${selector}`, () => {
                        expect(wrapper.find(selector).exists()).toBeTruthy()
                    })
                } else {
                    it(`does not render ${selector}`, () => {
                        expect(wrapper.find(selector).exists()).toBeFalsy()
                    })
                }
            })

            describe('when clicking on reopen event', () => {

                beforeEach(async () => {

                    wrapper.find(OPEN_EVENT_BUTTON).trigger('click')

                    await wait()
                })

                it('reopens the event', () => {

                    expect(restRequest).toHaveBeenCalledWith(`events/${EVENT_ID}`, {
                        method: 'patch',
                        data: {
                            event: {
                                state: "OPEN",
                                secret: EVENT_SECRET,
                                scheduled_from: null,
                                scheduled_to: null
                            }
                        }
                    })
                })
            })
        })

        describe('scheduled event', () => {

            beforeEach(async () => {
                restRequest = jasmine.createSpy('restRequest').and.callFake((path) => {
                    if (path === `events/${EVENT_ID}`) {
                        return Promise.resolve({
                            data: {
                                data: makeEvent('SCHEDULED', true)
                            }
                        })
                    } else if (path === `events/${EVENT_ID}/schedule`) {
                        return Promise.resolve({
                            data: {
                                data: makeSchedule(false, true)
                            }
                        })
                    }
                    return Promise.reject()
                })

                wrapper = mountEventViewer(restRequest, {
                    eventId: EVENT_ID,
                    secret: EVENT_SECRET
                })
                await wait()
            })

            it('renders event header', () => {
                let eventHeader = wrapper.find('event-header-stub')
                expect(eventHeader.exists).toBeTruthy();
                expect(eventHeader.attributes('eventname')).toBe(EVENT_DATA.name)
                expect(eventHeader.attributes('eventorganizer')).toBe(EVENT_DATA.organizer)
                expect(eventHeader.attributes('eventstate')).toBe("SCHEDULED")
                expect(eventHeader.attributes('eventscheduledfrom')).toBeDefined()
                expect(eventHeader.attributes('eventscheduledto')).toBeDefined()
                expect(eventHeader.attributes('eventtimewindow')).toBeDefined()
            })

            it('it computes scheduleCalendarAttributes', () => {
                expect(wrapper.vm.scheduleCalendarAttributes.length).toBe(0)
            })

            it('renders main card', () => {
                expect(wrapper.find('div.card').exists()).toBeTruthy();
            })

            it('renders event intro', () => {
                expect(wrapper.find(EVENT_INTRO).exists()).toBeTruthy()
            })

            it('renders one alert', () => {
                expect(wrapper.findAll('.alert').length).toBe(2)
            })

            it('does not render the date picker', () => {
                expect(wrapper.find('v-date-picker-stub').exists()).toBeFalsy()
            })

            buttonSelectors.all.forEach(selector => {
                if (buttonSelectors.organizer.closed.indexOf(selector) > -1) {
                    it(`renders ${selector}`, () => {
                        expect(wrapper.find(selector).exists()).toBeTruthy()
                    })
                } else {
                    it(`does not render ${selector}`, () => {
                        expect(wrapper.find(selector).exists()).toBeFalsy()
                    })
                }
            })
        })
    })
})
