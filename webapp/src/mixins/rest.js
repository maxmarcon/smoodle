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

            let loader = null;
            let timeout = null
            if (!config.background && this.$loading) {
                if (config.spinnerDelay) {
                    timeout = setTimeout( () => {
                        loader = this.$loading.show();
                    }, config.spinnerDelay)
                }
                this.requestOngoing = true;
            }

            try {
                return await this.$http.request(config)
            } catch (error) {
                if (config.errorHandling && this.showInErrorBar) {
                    if (!error.response) {
                        if (error.request) {
                            this.showInErrorBar(this.$i18n.t('errors.network'))
                        } else {
                            this.showInErrorBar(this.$i18n.t('errors.generic', {
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
                    this.requestOngoing = false;
                }
            }
        }
    }
}
