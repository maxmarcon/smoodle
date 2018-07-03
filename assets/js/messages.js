import date_fns_de from 'date-fns/locale/de'
import date_fns_en from 'date-fns/locale/en'
import date_fns_it from 'date-fns/locale/it'

export default {
	en: {
		event_editor: {
			title: 'New event',
			welcome: 'Hello! Here you can create a new event and share it with participants',
			event: {
				name: "Event title",
				name_help: "Enter a name for your event",
				desc: "What is going to happen?",
				desc_help: "Describe the event",
				dates: "Specify a custom time period or select one from the drop-down",
				organizer: "Who are you?",
				organizer_help: "Let your friends know who invitied them..."
			},
			general_info_group: 'What kind of event is it?',
			dates_group: 'How soon should it happen?',
			organizer_group: 'Who\'s organizing the event?',
			this_week: "This week",
			next_week: "Next week",
			within_months: "Within one month | Within {count} months",
			next: "Next",
			prev: "Previous",
			dates_quick_selection: "Quick pre-selection",
			step: "Step {step} of {lastStep}",
			link_copied: "Link copied to clipboard",
			event_created: "Congratulations {eventOrganizer}! Your event for \u201C{eventName}\u201E has been created",
			event_created_short: "Your event has been created",
			share_link: "Now share this link with your friends, so they can enter which dates work best for them:",
			manage_event: "Manage event",
			poll_event: "Enter your availability",
			dates_placeholder: 'Click to enter dates'
		},
		poll_editor: {
			welcome: "{eventOrganizer} has invited you to a {eventName}. Please let them know what dates work best for you by answering a few questions.",
			title: "Poll for \u201C{eventName}\u201E",
			particpiant_group: "Who are you?",
			weekday_ranks_group: "Which days of the week work best for you?",
			weekday_ranks_help: "Specify which days of the week are perfect, good, or bad for the event"
		},
		date_picker: {
			days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
			daysShort: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
			months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
			apply: 'Apply',
			cancel: 'Cancel'
		},
		date_fns_locale: date_fns_en,
		errors: {
			required_field: "Can't be blank",
			network: "The server is not responding or cannot be reached. Please try again later.",
			not_found: "The requested data record could not be found on the server"
		}
	},

	de: {
		event_editor: {
			event: {
				name: "Titel des Events",
				name_help: "Gib deinem Event einen Namen",
				desc: "Was ist der Anlass?",
				desc_help: "Beschreibe dein Event",
				dates: "Daten",
				organizer: "Wer bist Du?",
				organizer_help: "Lass deine Freunde wissen, wer sie einlädt..."
			},
			next: "Weiter",
			prev: "Zurück",
			this_week: "Diese Woche",
			next_week: "Nächste Woche",
			within_months: "Innerhalb eines Monats | Innerhalb der nächsten {count} Monate",
			dates_quick_selection: "Schnelle Vorauswahl",
			step: "Schritt {step} von {lastStep}"
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
				dates: "Date",
				organizer: "Chi sei?",
				organizer_help: "Fai sapere ai tuoi amici chi li invita..."
			},
			next: "Avanti",
			prev: "Indietro",
			this_week: "Questa settimana",
			next_week: "La prossima settimana",
			within_months: "Entro un mese | Entro {count} mesi",
			dates_quick_selection: "Preselezione veloce",
			step: "Passo {step} di {lastStep}"
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