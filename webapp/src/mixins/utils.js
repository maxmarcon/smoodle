export const scrollToTopMixin = {
  methods: {
    scrollToTop() {
      if (this.$scrollTo) {
        return this.$scrollTo('main');
      }
    }
  }
}
export const nameListTrimmerMixin = {
  methods: {
    trimmedNameList(list, maxVisible = 5) {
      if (!(list instanceof Array)) {
        throw 'trimmedNameList should be called with an array'
      }

      if (list.length <= maxVisible) {
        return list.join(', ')
      } else {
        return this.$i18n.t('trimmed_list', {
          list: list.slice(0, maxVisible).join(', '),
          others: list.length - maxVisible
        })
      }
    }
  }
}
export const whatsAppHelpersMixin = {
  methods: {
    whatsAppMessageURL: (link) => `https://wa.me/?text=${encodeURIComponent(link)}`
  }
};
