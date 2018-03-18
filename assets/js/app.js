
const Vue = require('vue/dist/vue.common');
 
const greeting = () => 'Greetings from Smoodle!';

let app = new Vue({
  el: '#app',
  data: {
    message: greeting()
  }
})