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

			b-navbar-nav.ml-auto
				b-nav-item-dropdown(right)
					template(slot="button-content")
						i.fas.fa-lg.fa-globe-americas
					b-dropdown-item(
						@click="setLocale('en')"
						:disabled="getLocale() == 'en'"
					)
						i.flag-icon.flag-icon-us
					b-dropdown-item(
						@click="setLocale('de')"
						:disabled="getLocale() == 'de'"
					)
						i.flag-icon.flag-icon-de
					b-dropdown-item(
						@click="setLocale('it')"
						:disabled="getLocale() == 'it'"
					)
						i.flag-icon.flag-icon-it

	div
		router-view

	.fluid-container.bg-light
		small.text-muted.p-2 &copy; 2018 Max Marcon
</template>
<script>
export default {
	methods: {
		setLocale(locale) {
			this.$i18n.locale = locale;
		},
		getLocale() {
			return this.$i18n.locale;
		}
	}
}
</script>
