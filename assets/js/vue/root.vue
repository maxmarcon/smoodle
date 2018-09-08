<template lang="pug">
div
	b-navbar(toggleable="md" type="dark" variant="info")
		b-navbar-brand(
			:to="{name: 'home'}"
		) {{ $t('app_name') }}

		b-navbar-toggle(target="nav_collapse")

		b-collapse#nav_collapse(is-nav="")
			b-navbar-nav
				b-nav-item(
					:to="{name: 'new_event'}"
					:active="$route.name == 'new_event'"
					:disabled="$route.name == 'new_event'"
			  )
					i.fas.fa-plus-circle
					| &nbsp; {{ $t("event_editor.title") }}

	div
		router-view

	.fluid-container.bg-light
		small.text-muted.p-2 &copy; 2018 Max Marcon
</template>
