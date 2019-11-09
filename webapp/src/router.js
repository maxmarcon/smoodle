import Vue from 'vue'
import Router from 'vue-router'

const Home = () =>
    import ( /* webpackChunkName: "home" */ './components/home.vue')
const EventEditor = () =>
    import ( /* webpackChunkName: "event-editor" */ './components/event-editor.vue')
const PollEditor = () =>
    import ( /* webpackChunkName: "poll-editor" */ './components/poll-editor.vue')
const EventViewer = () =>
    import ( /* webpackChunkName: "event-viewer" */ './components/event-viewer.vue')

Vue.use(Router)

export default new Router({
    mode: 'history',
    base: process.env.BASE_URL,
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
    }, {
        path: '/*',
        redirect: '/home'
    }]
})

