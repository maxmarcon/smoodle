//import 'vueify/lib/insert-css'
import Welcome from './vue/welcome.vue'

const greeting = () => 'Greetings from Smoodle!';

let app = new Vue({
  el: '#app',
  components: { Welcome }
})