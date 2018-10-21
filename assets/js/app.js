// import 'babel-polyfill';
// This would enable IE11 compatibility, in case we ever need it.
import EventEditor from './vue/eventEditor.vue'
import PollEditor from './vue/pollEditor.vue'
import EventViewer from './vue/eventViewer.vue'
import Home from './vue/home.vue'

import datePicker from 'vue-bootstrap-datetimepicker';
import VueRouter from 'vue-router'
import VueI18n from 'vue-i18n'
import BootstrapVue from 'bootstrap-vue'
import axios from 'axios'
import VueAxios from 'vue-axios'
import VueClipboard from 'vue-clipboard2'
import VCalendar from 'v-calendar'
import VueScrollTo from 'vue-scrollto';
import VueLoading from 'vue-loading-overlay';
import rootVue from './vue/root.vue'
import messageBar from './vue/messageBar.vue'
import messages from './messages'
import ranker from './vue/ranker.vue'
import eventHeader from './vue/eventHeader.vue'
import errorPage from './vue/errorPage.vue'
import PrettyCheckbox from 'pretty-checkbox-vue';
import Vue from 'vue/dist/vue.runtime.esm';

// See: https://vuejs.org/v2/guide/installation.html#Development-vs-Production-Mode
Vue.config.devtools = (process.env.NODE_ENV != "production");
Vue.config.productionTip = false;

Vue.use(VueRouter);
const router = new VueRouter({
	mode: 'history',
	routes: [{
		path: '/home',
		name: 'home',
		component: Home
	}, {
		path: '/events/new',
		name: 'new_event',
		component: EventEditor
	}, {
		path: '/events/:eventId/edit',
		name: 'edit_event',
		component: EventEditor,
		props: (route) => Object.assign({
			secret: route.query.s
		}, route.params)
	}, {
		path: '/events/:eventId',
		name: 'event',
		component: EventViewer,
		props: (route) => Object.assign({
			secret: route.query.s
		}, route.params)
	}, {
		path: '/events/:eventId/polls/new',
		name: 'new_poll',
		component: PollEditor,
		props: true
	}, {
		path: '/polls/:pollId/edit',
		name: 'edit_poll',
		component: PollEditor,
		props: true
	}]
});

Vue.use(VueI18n);
const i18n = new VueI18n({
	locale: smoodle_locale,
	fallbackLocale: 'en',
	messages
});

Vue.use(PrettyCheckbox);

Vue.use(BootstrapVue);

Vue.use(VueAxios, axios);

Vue.use(VueClipboard);

Vue.use(VueScrollTo);

Vue.use(VueLoading);

Vue.use(VCalendar, {
	locale: smoodle_locale
});

Vue.use(datePicker);

Vue.component('message-bar', messageBar);

Vue.component('ranker', ranker);

Vue.component('event-header', eventHeader);

Vue.component('error-page', errorPage);

const app = new Vue({
	i18n,
	router,
	render: h => h(rootVue)
}).$mount('#app');