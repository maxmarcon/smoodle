module.exports = {
  pluginOptions: {
    i18n: {
      locale: 'en',
      fallbackLocale: 'en',
      localeDir: 'locales',
      enableInSFC: false
    }
  },
  outputDir: '../priv/static'
  // v-calendar includes ES6 code:
  // https://github.com/nathanreyes/v-calendar/issues/513
  // this causes issues in IE11 and Edge
  // the line below should fix the problem but it doesn't fully,
  // the code loads but the calendar is not visualized correctly
  // transpileDependencies: ['v-calendar']
}
