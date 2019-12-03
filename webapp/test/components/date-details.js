import {createLocalVue, mount} from '@vue/test-utils'
import dateDetails from '../../src/components/date-details'
import i18nMock from '../test-utils/i18n-mock'
import BootstrapVue from "bootstrap-vue";

const nameList = [
    'Harlow Ayala'
    , 'Ishan Reed'
    , 'Ellis Sincla'
    , 'Jemima Sanch'
    , 'Arielle Plum'
    , 'Gianluca Sim'
    , 'Quinn Benson'
    , 'Ember Lovell'
    , 'Mollie Vance'
    , 'Maisha Becke'
    , 'Billy Gallag'
    , 'Kaira Hawort'
    , 'Emeli Briggs'
    , 'Vickie Arias'
    , 'Lukas Simpso'
    , 'Neil Coleman'
    , 'Denise Sulli'
    , 'Octavia Poll'
    , 'Braxton Dick'
    , 'Ihsan Joyce'
    , 'Ho Kline'
    , 'Shanelle Bis'
    , 'Mahdi Sanfor'
    , 'Tobi Driscol'
    , 'Heather Rodr'
    , 'Benas Gibbs'
    , 'Shaunna Mark'
    , 'Lavinia Chav'
    , 'Sophia-Rose '
    , 'Phillippa On'
]

function mountComponent(neg_part, neg_rank, pos_part, pos_rank, optimal = false, isOrganizer = false) {
    const localVue = createLocalVue()
    localVue.use(BootstrapVue)

    return mount(dateDetails, {
        propsData: {
            isOrganizer,
            calendarAttribute: {
                highlight: {},
                customData: {
                    date: new Date(),
                    negative_rank: neg_rank,
                    negative_participants: neg_part,
                    positive_rank: pos_rank,
                    positive_participants: pos_part,
                    optimal
                }
            }
        },
        mocks: {
            $t: i18nMock.t,
            $tc: i18nMock.t,
            $i18n: i18nMock
        },
        localVue
    })
}

let wrapper;

describe('dateDetails', () => {

    describe('with no more than 5 negative or positive participants', () => {

        beforeEach(() => {
            wrapper = mountComponent(nameList.slice(0, 5), -5, nameList.slice(0, 5), 5)
        })

        it('does not render show all buttons', () => {
            expect(wrapper.findAll('.card-body button.btn-link').length).toBe(0)
        })
    })

    describe('with more than 5 negative or positive participants', () => {
        beforeEach(() => {
            wrapper = mountComponent(nameList, -nameList.length, nameList, nameList.length)
        })

        it('does render show all buttons', () => {
            expect(wrapper.findAll('.card-body button.btn-link').length).toBe(2)
        })
    })

    describe('with more than 5 negative or positive participants but no names', () => {
        beforeEach(() => {
            wrapper = mountComponent(null, -nameList.length, null, nameList.length)
        })

        it('does render show all buttons', () => {
            expect(wrapper.findAll('.card-body button.btn-link').length).toBe(0)
        })
    })

    describe('with an optimal date', () => {
        beforeEach(() => {
            wrapper = mountComponent(nameList, -nameList.length, nameList, nameList.length, true)
        })

        it('shows the optimal badge', () => {
            expect(wrapper.find('span.badge.badge-primary').exists()).toBeTruthy()
        })
    })

    describe('with a non-optimal date', () => {
        beforeEach(() => {
            wrapper = mountComponent(nameList, -nameList.length, nameList, nameList.length)
        })

        it('does not show the optimal badge', () => {
            expect(wrapper.find('span.badge.badge-primary').exists()).toBeFalsy()
        })
    })

    describe('for a negative date', () => {
        beforeEach(() => {
            wrapper = mountComponent(nameList, -nameList.length, nameList, nameList.length)
        })

        it('shows the negative badge', () => {
            expect(wrapper.find('span.badge.badge-danger').exists()).toBeTruthy()
        })

        it('does not show the positive badge', () => {
            expect(wrapper.find('span.badge.badge-success').exists()).toBeFalsy()
        })
    })

    describe('for a positive date', () => {
        beforeEach(() => {
            wrapper = mountComponent([], 0, nameList, nameList.length)
        })

        it('does not show the negative badge', () => {
            expect(wrapper.find('span.badge.badge-danger').exists()).toBeFalsy()
        })

        it('shows the positive badge', () => {
            expect(wrapper.find('span.badge.badge-success').exists()).toBeTruthy()
        })
    })

    describe('for a non-organizer', () => {

        beforeEach(() => {
            wrapper = mountComponent(nameList, -nameList.length, nameList, nameList.length, false, false)
        })

        it('does not render the scheduler button', () => {
            expect(wrapper.find('.card-footer button.btn.btn-primary').exists()).toBeFalsy();
        })
    })

    describe('for an organizer', () => {
        beforeEach(() => {
            wrapper = mountComponent(nameList, -nameList.length, nameList, nameList.length, false, true)
        })

        it('does render the scheduler button', () => {
            expect(wrapper.find('.card-footer button.btn.btn-primary').exists()).toBeTruthy();
        })
    })
});
