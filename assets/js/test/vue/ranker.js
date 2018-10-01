import ranker from '../../vue/ranker.vue'

import {
	mount,
	createLocalVue
} from '@vue/test-utils'

const localVue = createLocalVue()

const ELEMENTS = [{
	name: 'ABC',
	rank: 1
}, {
	name: 'DEF',
	rank: -1
}, {
	name: 'GHI',
	rank: 1
}]

describe('ranker', () => {

	let wrapper

	beforeEach(() => {

		wrapper = mount(ranker, {
			mocks: {
				$t: (k) => k
			},
			propsData: {
				elements: ELEMENTS
			}
		})
	})

	it('renders the right numner of elements', () => {
		let elements = wrapper.findAll('li')
		expect(elements.length).toBe(ELEMENTS.length)
	})

	it('renders the right elements in the right order', () => {
		let elements = wrapper.findAll('li')

		ELEMENTS.forEach((el, index) => {
			let element = elements.at(index)

			expect(element.find('h6').text()).toBe(el.name)

			let radios = element.findAll('p-radio')
			expect(radios.at(0).attributes('name')).toBe(el.name)
			expect(radios.at(0).attributes('value')).toBe("1")

			expect(radios.at(1).attributes('name')).toBe(el.name)
			expect(radios.at(1).attributes('value')).toBe("0")

			expect(radios.at(2).attributes('name')).toBe(el.name)
			expect(radios.at(2).attributes('value')).toBe("-1")
		})
	})
})