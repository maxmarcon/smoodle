//import 'vueify/lib/insert-css'
import EventEditor from './vue/eventEditor.vue'
import AvailabiltyVue from './vue/availability.vue'
import VueRouter from 'vue-router'
import VueI18n from 'vue-i18n'
import AirbnbStyleDatepicker from 'vue-airbnb-style-datepicker'
import BootstrapVue from 'bootstrap-vue'

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

const dateTimeFormats = {
	en: {
		short: {
			year: 'numeric', month: 'short', day: 'numeric'
		}
	},
	de: {
		short: {
			year: 'numeric', month: 'short', day: 'numeric'
		}
	}

}

const i18n = new VueI18n({
  locale: smoodle_locale,
  messages,
  dateTimeFormats
});

Vue.use(BootstrapVue);

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


