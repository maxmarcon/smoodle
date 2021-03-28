<template lang="pug">
  div#page-top
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
          b-nav-item-dropdown(right size="sm")
            template(slot="button-content")
              span.fas.fa-globe-americas
              | &nbsp; {{ $t("navbar.language") }}
            b-dropdown-item-button(
              @click="setLocale('en')"
              :disabled="getLocale() == 'en'"
            )
              span.flag-icon.flag-icon-us
              | &nbsp; EN
            b-dropdown-item-button(
              @click="setLocale('de')"
              :disabled="getLocale() == 'de'"
            )
              span.flag-icon.flag-icon-de
              | &nbsp; DE
            b-dropdown-item-button(
              @click="setLocale('it')"
              :disabled="getLocale() == 'it'"
            )
              span.flag-icon.flag-icon-it
              | &nbsp; IT

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
