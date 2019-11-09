import date_fns_en from 'date-fns/locale/en-US'

export default {
    t: (key) => {
        if (key === 'date_fns_locale') {
            return date_fns_en;
        }
        if (key === 'date_format') {
            return 'MM/dd/yyyy';
        }
        if (key === 'time_format') {
            return "h:mm a"
        }
        if (key === 'datetime_format') {
            return "MM/dd/yyyy h:mm a"
        }
        return key;
    }
}