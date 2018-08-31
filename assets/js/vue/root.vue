<template lang="pug">
div
	b-navbar(toggleable="md" type="dark" variant="info")
		b-navbar-brand(href="#") {{ $t('app_name') }}

		b-navbar-toggle(target="nav_collapse")

		b-collapse#nav_collapse(is-nav="")
			b-navbar-nav
				b-nav-item(
					v-bind:to="{name: 'new_event'}"
					v-bind:active="$route.name == 'new_event'"
					v-bind:disabled="$route.name == 'new_event'"
			  )
					i.fas.fa-plus-circle
					| &nbsp; {{ $t("event_editor.title") }}

	div
		router-view
</template>
