export default {
  data() {
    return {
      errorCodeMessages: {
        422: 'errors.unprocessable_entity',
        404: 'errors.not_found'
      }
    }
  },
  methods: {
    showErrorCodeInErrorBar(code) {
      let message = this.errorCodeMessages[code] ? this.$i18n.t(this.errorCodeMessages[code]) : this.$i18n.t('errors.server', {
        code
      })
      this.showInErrorBar(message)
    },
    showInErrorBar(message) {
      this.$refs.errorBar.show(message);
      if (this.scrollToTop) {
        this.scrollToTop()
      }
    }
  }
}