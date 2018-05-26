//import 'vueify/lib/insert-css'
import EventEditor from './vue/eventEditor.vue'
import PollVue from './vue/poll.vue'
import VueRouter from 'vue-router'
import VueI18n from 'vue-i18n'
import AirbnbStyleDatepicker from 'vue-airbnb-style-datepicker'
import BootstrapVue from 'bootstrap-vue'
import axios from 'axios'
import VueAxios from 'vue-axios'
import VueClipboard from 'vue-clipboard2'

const router = new VueRouter({
	mode: 'history',
	routes: [
	  {
	  	path: '/new_event',
	  	name: 'new_event',
	  	component: EventEditor
	  },
	  {
	  	path: '/event/:eventId/poll',
	  	name: 'poll',
	  	component: PollVue,
			props: true
	  }
  ]
});

import messages from './messages'
// importing these here because otherwise single file components (e.g. eventEditor)
// won't be able to "see" them and import. Probably an issue with vue-brunch, babel, or both
// UPDATE: fixed by having vue-brunch run before babel-brunch (via correct order in package.json)
//import 'date-fns'
// this is super annoying!!!

import messageBar from './vue/messageBar.vue'
Vue.component('message-bar', messageBar);

import weekdayRanker from './vue/weekdayRanker.vue'
Vue.component('weekday-ranker', weekdayRanker);

const i18n = new VueI18n({
  locale: smoodle_locale,
  messages
});

import ToggleButton from 'vue-js-toggle-button'
Vue.use(ToggleButton)

Vue.use(BootstrapVue);

Vue.use(VueAxios, axios);

Vue.use(VueClipboard);

Vue.use(AirbnbStyleDatepicker, {
	monthNames: i18n.t('date_picker.months'),
	days: i18n.t('date_picker.days'),
	daysShort: i18n.t('date_picker.daysShort'),
	texts: {
		apply: i18n.t('date_picker.apply'),
		cancel: i18n.t('date_picker.cancel')
	}
});

const app = new Vue({
	i18n,
 	router
}).$mount('#app');


