import Vue from 'vue'
import App from './components/app.vue'
import router from './router'
import i18nBuilder from './i18n'
import BootstrapVue from 'bootstrap-vue'
import VueLoading from 'vue-loading-overlay'
import 'vue-loading-overlay/dist/vue-loading.css';
import VCalendar from 'v-calendar';
import axios from 'axios'
import VueAxios from 'vue-axios'
import datePicker from 'vue-bootstrap-datetimepicker'
import VueScrollTo from 'vue-scrollto'
import PrettyCheckbox from 'pretty-checkbox-vue'
import VueClipboard from 'vue-clipboard2'

import 'bootstrap/scss/bootstrap.scss'
import 'flag-icon-css/sass/flag-icon.scss';
import '@fortawesome/fontawesome-free/scss/regular.scss';
import '@fortawesome/fontawesome-free/scss/solid.scss';
import '@fortawesome/fontawesome-free/scss/brands.scss';
import '@fortawesome/fontawesome-free/scss/fontawesome.scss';
import 'pc-bootstrap4-datetimepicker/build/css/bootstrap-datetimepicker.css';
import 'vue-loading-overlay/dist/vue-loading.css';
import 'bootstrap-vue/dist/bootstrap-vue.css';
import 'pretty-checkbox/src/pretty-checkbox.scss';
import './scss/app.scss';
import './scss/opacity.scss';

import MessageBar from './components/message-bar'
import EventHeader from './components/event-header'
import ProgressHeader from './components/progress-header'
import Ranker from './components/ranker'
import ErrorPage from './components/error-page'

Vue.config.productionTip = false;

Vue.use(BootstrapVue);
Vue.use(VueLoading);
Vue.use(VueAxios, axios);
Vue.use(VCalendar)
Vue.use(PrettyCheckbox)
Vue.use(VueScrollTo)
Vue.use(datePicker)
Vue.use(VueClipboard)

Vue.component('message-bar', MessageBar);
Vue.component('event-header', EventHeader);
Vue.component('progress-header', ProgressHeader);
Vue.component('ranker', Ranker)
Vue.component('error-page', ErrorPage)

new Vue({
  router,
  i18n: i18nBuilder(navigator.languages),
  render: h => h(App)
}).$mount('#app');
