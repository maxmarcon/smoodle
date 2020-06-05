export const scrollToTopMixin = {
  methods: {
    scrollToTop() {
      if (this.$scrollTo) {
        return this.$scrollTo('#page-top');
      }
    }
  }
}

export const whatsAppHelpersMixin = {
  methods: {
    whatsAppMessageURL: (text) => `whatsapp://send?text=${encodeURIComponent(text)}`
  }
};
