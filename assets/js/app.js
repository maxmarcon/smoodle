//import 'vueify/lib/insert-css'
import EventEditor from './vue/eventEditor.vue'
import AvailabiltyVue from './vue/availability.vue'
import VueRouter from 'vue-router'
import VueI18n from 'vue-i18n'
import AirbnbStyleDatepicker from 'vue-airbnb-style-datepicker'
import BootstrapVue from 'bootstrap-vue'
import axios from 'axios'
import VueAxios from 'vue-axios'

const router = new VueRouter({
	mode: 'history',
	routes: [
	  {
	  	path: '/new_event',
	  	name: 'new_event',
	  	component: EventEditor,
	  	props: true
	  },
	  { path: '/poll', component: AvailabiltyVue }
	 ]
});

import messages from './messages.js'
// importing these here because otherwise single file components (e.g. eventEditor)
// won't be able to "see" them and import. Probably an issue with vue-brunch, babel, or both
import 'date-fns'
// this is super annoying!!!
import 'babel-runtime/core-js/object/assign'

const i18n = new VueI18n({
  locale: smoodle_locale,
  messages
});

Vue.use(BootstrapVue);

Vue.use(VueAxios, axios);

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


