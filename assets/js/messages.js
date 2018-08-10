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
				organizer_help: "Let your friends know who invitied them...",
				organizer_email: "Please enter your email",
				organizer_email_help: "We will use this email to send you a private link that you can use to manage the event"
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
			event_created: "Congratulations {eventOrganizer}! Your event for \u201C{eventName}\u201E has been created.\
			 An email has been sent to {organizerEmail}",
			event_created_short: "Your event has been created",
			share_link: "Now share the below link with your friends, so they can enter which dates work best for them:",
			manage_event: "Manage event",
			create_event: "Create event",
			poll_event: "Enter your availability",
			dates_placeholder: "Select a date range"
		},
		poll_editor: {
			title: "Poll for \u201C{eventName}\u201E",
			participant_group: "Who are you?",
			poll: {
				participant: "Participant name",
				participant_help: "Tell the organizer who you are..."
			},
			weekday_ranker_group: "How is your typical week?",
			weekday_ranker_help: "Specify which days of your typical week are good {0}, just fine {1}, or bad {2} for the event. You can add exception for specific dates later. {3}",
			calendar_ranker_group: "Select specific dates",
			save_poll: "Save poll",
			delete_poll: "Delete poll",
			poll_saved: "Your poll has been saved",
			really_delete: "Do you really want to delete your poll? This operation can't be undone",
			back_to_event: "Back to the event",
			poll_deleted: "Your poll has been deleted",
			dates_placeholder: "Select a time period",
			date_ranker_helper: "Select specific date ranges that are good {0} or bad {1} for the event. This takes precedence over the preferences you expressed for the week days. {2}",
			date_ranker_help_modal_title: "Adding and removing dates",
			date_ranker_help_modal_content: "First choose whether you are adding dates that are good {0} or bad {1}.\
			Then, to add a date range, click on the first date, then on the second one. To select a single date, click twice on it.\
			To remove dates, first select {2} and then click on them.",
			weekday_ranker_help_modal_title: "Preferences for the days of the week",
			weekday_ranker_help_modal_content: "Give us an idea of your typical week. For example, \
			you might go to the gym every Wednesday and might want to mark it with {0}. On the other hand, a Friday might be a good day for this event\
			and you might want to mark it with {1}. Other days might be just ok, and you can leave them as {2}."
		},
		event_viewer: {
			organizer: "Organizer:",
			description: "Description:",
			should_happen: "Should happen:",
			create_poll: "Answer the poll",
			update_poll: "Update your answer",
			no_participants: "Nobody participated yet. As soon as there are some participants, the best dates for the event will appear here. Be the first one to answer the poll!",
			schedule_not_found: "We were unable to fetch the current schedule for this event",
			welcome: "{organizer} has invited you to this event.",
			event_open: "The event has not been scheduled yet. Below are the best candidate dates so far. If you haven't yet, please answer a poll\
								to enter your availability",
			event_canceled: "This event has been canceled",
			event_scheduled: "{organizer} has scheduled this event to happen on {time}",
			says: "says:",
			update: {
				title: "Update your answer",
				load: "Load your answer",
				how_to: "Enter the name you used to save your answer",
				name_placeholder: "Enter your name here...",
				poll_not_found: "No answer found under this name. Did you spell the name correctly?"
			},
			participants_for_date: "Everybody can make it! | {count} people cannot make it",
			create_new_event: "Create a new event"
		},
		date_format: 'MM/DD/YYYY',
		time_format: 'MM/DD/YYYY h:mm A',
		week_days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
		ranker: {
			good: "Good",
			ok: "Ok",
			bad: "Bad"
		},
		date_fns_locale: date_fns_en,
		errors: {
			required_field: "Can't be blank",
			network: "The server is not responding or cannot be reached. Please try again later.",
			not_found: "The requested data could not be found on the server"
		},
		event_header: {
			by: "by {organizer}",
			no_name: "No event name yet",
			no_dates: "No dates yet"
		},
		actions: {
			cancel: "Cancel"
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
		date_format: 'DD.MM.YYYY',
		week_days: ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'],
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
		date_format: 'DD/MM/YYYY',
		week_days: ['Lunedí', 'Martedí', 'Mercoledí', 'Giovedí', 'Venerdí', 'Sabato', 'Domenica'],
		date_fns_locale: date_fns_it
	}
}