export const scrollToTopMixin = {
  methods: {
    scrollToTop() {
      if (this.$scrollTo) {
        return this.$scrollTo('main');
      }
    }
  }
}

export const whatsAppHelpersMixin = {
  methods: {
    whatsAppMessageURL: (link) => `https://wa.me/?text=${encodeURIComponent(link)}`
  }
};
