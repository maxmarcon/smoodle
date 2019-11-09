import Vue from 'vue'
import VueI18n from 'vue-i18n'
import date_fns_en from 'date-fns/locale/en-US'
import date_fns_de from 'date-fns/locale/de'
import date_fns_it from 'date-fns/locale/it'

Vue.use(VueI18n)

const locales = require.context('./locales', true, /[A-Za-z0-9-_,\s]+\.json$/i)

function getAvailableLocales(locales) {
    return new Map(
        locales.keys()
        .map(key => {
            const matched = key.match(/([A-Za-z0-9-_]+)\./i)
            if (matched && matched.length > 1) {
                return [matched[1], key]
            }
        })
    );
}

function loadLocaleMessages() {
    const messages = {}
    getAvailableLocales(locales).forEach((key, locale) => {
        messages[locale] = locales(key)
    })
    return messages
}

function addDateFnsLocales(messages) {
    messages['en']['date_fns_locale'] = date_fns_en;
    messages['de']['date_fns_locale'] = date_fns_de;
    messages['it']['date_fns_locale'] = date_fns_it;

    return messages;
}

function selectBestLocale(preferredLocales) {
    preferredLocales = preferredLocales instanceof Array ? preferredLocales : [preferredLocales];
    const availableLocaleNames = Array.from(getAvailableLocales(locales).keys());
    return preferredLocales
        .filter(locale => typeof(locale) === 'string')
        .flatMap(locale => {
            const hyphen = locale.indexOf('-');
            if (hyphen < 0) {
                return [locale];
            }
            return [locale, locale.substr(0, hyphen)];
        }).find(locale => availableLocaleNames.find(available => available === locale));
}

export default function i18nBuilder(preferredLocales) {
    return new VueI18n({
        locale: selectBestLocale(preferredLocales) || 'en',
        fallbackLocale: process.env.VUE_APP_I18N_FALLBACK_LOCALE || 'en',
        messages: addDateFnsLocales(loadLocaleMessages())
    })
}
