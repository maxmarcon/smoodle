//import 'vueify/lib/insert-css'
import Event from './vue/event.vue'
import Availabilty from './vue/availability.vue'
import VueRouter from 'vue-router'

const router = new VueRouter({
	mode: 'history',
	routes: [
	  { path: '/event', component: Event },
	  { path: '/availability', component: Availabilty }
	 ]
});

const app = new Vue({
 router
}).$mount('#app');
