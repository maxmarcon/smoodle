//import 'vueify/lib/insert-css'
import EventEditor from './vue/eventEditor.vue'
import AvailabiltyVue from './vue/availability.vue'
import VueRouter from 'vue-router'
import VueI18n from 'vue-i18n'

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

const i18n = new VueI18n({
  locale: smoodle_locale,
  messages
})

const app = new Vue({
	i18n,
 	router
}).$mount('#app');


