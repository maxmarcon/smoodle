export default {
    data() {
        return {
            requestOngoing: false,
            apiVersion: 'v1'
        }
    },
    methods: {
        async restRequest(path, config) {
            config = Object.assign({
                url: [process.env.VUE_APP_APIBASE, this.apiVersion, path].join('/'),
                headers: {
                    'Accept-Language': this.$i18n.locale
                },
                errorHandling: true,
                spinnerDelay: 100,
                background: false
            }, config);

            let self = this;

            let loader = null;
            let timeout = null
            if (!config.background && self.$loading) {
                if (config.spinnerDelay) {
                    timeout = setTimeout(function () {
                        loader = self.$loading.show();
                    }, config.spinnerDelay)
                }
                this.requestOngoing = true;
            }

            try {
                return await this.$http.request(config)
            } catch (error) {
                if (config.errorHandling && self.showInErrorBar) {
                    if (!error.response) {
                        if (error.request) {
                            self.showInErrorBar(self.$i18n.t('errors.network'))
                        } else {
                            self.showInErrorBar(self.$i18n.t('errors.generic', {
                                message: error.message
                            }))
                        }
                    }
                }
                throw error;
            } finally {
                if (timeout) {
                    clearTimeout(timeout)
                }
                if (loader) {
                    loader.hide();
                }
                if (!config.background) {
                    self.requestOngoing = false;
                }
            }
        }
    }
}
