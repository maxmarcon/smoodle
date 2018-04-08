//import 'vueify/lib/insert-css'
import EventEditor from './vue/eventEditor.vue'
import AvailabiltyVue from './vue/availability.vue'
import VueRouter from 'vue-router'

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

const app = new Vue({
 router
}).$mount('#app');


