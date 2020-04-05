<template lang="pug">
  .card
    .card-body.text-center
      i.fas.fa-exclamation-triangle.fa-3x
      h5.mt-3
        strong {{ message }}
    .card-footer
      slot
        .row.justify-content-center
          .col-12.col-md-auto
            router-link.btn.btn-block.btn-secondary(
              role="button"
              :to="{name: 'home'}"
            )
              i.fas.fa-home
              | &nbsp; {{ $t('actions.back_home') }}
</template>
<script>
  export default {
    props: {
      message: {
        type: String,
        required: true
      }
    }
  }
</script>
