//import 'vueify/lib/insert-css'
import EventVue from './vue/event.vue'
import AvailabiltyVue from './vue/availability.vue'
import VueRouter from 'vue-router'

const router = new VueRouter({
	mode: 'history',
	routes: [
	  { path: '/event/:id?', component: EventVue, props: true },
	  { path: '/availability', component: AvailabiltyVue }
	 ]
});

const app = new Vue({
 router
}).$mount('#app');


