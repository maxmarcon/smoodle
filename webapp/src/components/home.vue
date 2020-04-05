<template lang="pug">
  div
    b-card
      b-card-title.text-center
        h1.display-3.text-success
          em {{ $t('app_name') }}
      b-card-sub-title.text-center
        h1.text-muted {{ $t('home.title') }}
      b-card-text.text-center.m-5
        router-link.btn.btn-lg.btn-success(
          role="button"
          :to="{ name: 'new_event'}"
        )
          i.fas.fa-handshake
          | &nbsp; {{ $t('home.create_new_event') }}
      b-card-text.text-center
        h1 {{ $t('home.how_it_works') }}
      b-card-group(deck)
        b-card.text-center
          b-card-title
            h2 {{ $t('home.step1.title') }}
          b-card-text(text-tag="h5")
            em.text-muted {{ $t('home.step1.part1') }}
          b-card-text(text-tag="h5")
            em.text-muted {{ $t('home.step1.part2') }}
          img.img-fluid.w-75.border.border-primary.rounded(src="../assets/event-creation-calendar.png")
        b-card.text-center
          b-card-title
            h2 {{ $t('home.step2.title') }}
          b-card-text(text-tag="h5")
            i18n.text-muted(path="home.step2.part1" tag="em")
              span.text-success(place="good") {{ $tc('home.good', 1) }}
              span.text-warning(place="indifferent") {{ $tc('home.indifferent', 1) }}
              span.text-danger(place="bad") {{ $tc('home.bad', 1) }}
          img.img-fluid.border.border-primary.rounded(src="../assets/single-day-details.png")
        b-card.text-center
          b-card-title
            h2 {{ $t('home.step3.title') }}
          b-card-text(text-tag="h5")
            em.text-muted {{ $t('home.step3.part1') }}
          img.img-fluid.border.border-success.rounded(src="../assets/event-overview-calendar.png")
          b-card-text(text-tag="h5")
            i18n.text-muted(path="home.step3.part2" tag="em")
              span.text-success(place="good") {{ $tc('home.good_upper', 2) }}
              span.text-danger(place="bad") {{ $tc('home.bad', 2) }}
          b-card-text(text-tag="h5")
            em.text-muted {{ $t('home.step3.part3') }}
</template>
<style>
  .card-text, .card-title {
    padding-bottom: 10px;
    padding-top: 10px;
  }

  img {
    margin-bottom: 10px;
    margin-top: 10px;
  }
</style>
