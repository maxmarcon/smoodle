import date_fns_de from 'date-fns/locale/de'
import date_fns_en from 'date-fns/locale/en'
import date_fns_it from 'date-fns/locale/it'

export default {
	en: {
		event_editor: {
			event: {
				name: "Event title",
				name_help: "Enter a name for your event",
				desc: "What is going to happen?",
				desc_help: "Describe the event",
				dates: "Dates"
			},
			this_week: "This week",
			next_week: "Next week",
			within_months: "In 1 month | In {count} months",
			next: "Next",
			prev: "Previous",
			dates_quick_selection: "Quick selection"
		},
		date_picker: {
			days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
			daysShort: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
			months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
			apply: 'Apply',
			cancel: 'Cancel'
		},
		date_fns_locale: date_fns_en
	},

	de: {
		event_editor: {
			event: {
				name: "Titel des Events",
				name_help: "Gib deinem Event einen Namen",
				desc: "Was ist der Anlass?",
				desc_help: "Beschreibe dein Event",
				dates: "Daten"
			},
			next: "Weiter",
			prev: "Zurück",
		},
		date_picker: {
			days: ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'],
			daysShort: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
			months: ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'],
			apply: 'Übernehmen',
			cancel: 'Abbrechen'
		},
		date_fns_locale: date_fns_de
	},

	it: {
		event_editor: {
			event: {
				name: "Titolo dell'evento",
				name_help: "Dai un nome al tuo evento",
				desc: "Qual'è l'occasione?",
				desc_help: "Descrivi l'evento",
				dates: "Date"
			},
			next: "Avanti",
			prev: "Indietro"
		},
		date_picker: {
			days: ['Lunedí', 'Martedí', 'Mercoledí', 'Giovedí', 'Venerdí', 'Sabato', 'Domenica'],
			daysShort: ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'],
			months: ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'],
			apply: 'Accetta',
			cancel: 'Annulla'
		},
		date_fns_locale: date_fns_it
	}
}