import date_fns_de from 'date-fns/locale/de'
import date_fns_en from 'date-fns/locale/en'
import date_fns_it from 'date-fns/locale/it'

export default {
	en: {
		app_name: "Lets meet!",
		event_editor: {
			title: 'New event',
			welcome: 'Hello! Here you can create a new event and share it with participants.',
			welcome_again: 'Hello {organizer}! You can edit your event details here.',
			event: {
				name: "Give the event a name",
				name_help: "Enter a name for your event",
				desc: "What is going to happen?",
				desc_help: "Describe the event to your guests",
				dates: "Specify a custom time period or select one from the drop-down",
				organizer: "Who are you?",
				organizer_help: "Let your friends know who invitied them...",
				organizer_email: "Please enter your email",
				organizer_email_help: "We will use this email exclusively to send you a private link that you can use to manage the event",
				organizer_email_confirmation_help: "Please confirm your email here. Even the best make mistakes sometimes..."
			},
			general_info_group: 'What kind of event is it?',
			dates_group: 'When should it roughly happen?',
			organizer_group: 'Who\'s organizing the event?',
			this_week: "This week",
			next_week: "Next week",
			within_months: "Within one month | Within {count} months",
			dates_quick_selection: "Quick pre-selection",
			link_copied: "Link copied to clipboard",
			event_created: "Congratulations {eventOrganizer}! Your event \u201C{eventName}\u201E has been created.\
			 An email has been sent to {organizerEmail}",
			event_created_short: "Your event has been created",
			share_link: "Now share this link with your friends to invite them:",
			manage_event: "Manage event",
			create_event: "Create event",
			poll_event: "Enter your availability",
			dates_placeholder: "Select a date range",
			back_to_event: "Back to the event",
			update_event: "Update event",
			event_updated: "The event details have been updated",
			too_many_requests_error: "You have created too many events for {email}. Take a short break..."
		},
		poll_editor: {
			welcome: "Hey {participant}, here you can update your availabiliy for ths event.",
			welcome_new_participant: "Here you can enter your availabiliy for this event.",
			title: "My availabiliy for \u201C{eventName}\u201E",
			participant_group: "Who are you?",
			poll: {
				participant: "Participant name",
				participant_help: "Tell the organizer who you are..."
			},
			weekday_ranker_group: "How is your typical week?",
			weekday_ranker_help: "Specify which days of your typical week are good {good}, just fine {ok}, or bad {bad} for the event. You can add exception for specific dates later. {help}.",
			calendar_ranker_group: "Select specific dates",
			save_poll: "Save availabiliy",
			delete_poll: "Delete your availabiliy",
			poll_saved: "Your availabiliy has been saved",
			really_delete: "Do you really want to delete your availabiliy? This operation can't be undone",
			back_to_event: "Back to the event",
			poll_deleted: "Your availabiliy has been deleted",
			poll_delete_error: "An error has occurred, the availabiliy could not be deleted",
			dates_placeholder: "Select a time period",
			date_ranker_helper: "Select specific dates that are good {good} or bad {bad} for the event. This takes precedence over the preferences you expressed for the week days. {help}.",
			date_ranker_help_modal_title: "Adding and removing dates",
			date_ranker_help_modal_content: "First choose whether you are adding dates that are good {good} or bad {bad}.\
			Then add the dates, either as single dates or date ranges.\
			To remove dates, first select {trash} and then click on them.",
			weekday_ranker_help_modal_title: "Preferences for the days of the week",
			weekday_ranker_help_modal_content: "Give us an idea of your typical week. For example, \
			you might go to the gym every Wednesday and might want to mark it with {bad}. On the other hand, a Friday might be a good day for this event\
			and you might want to mark it with {good}. Other days might be just ok, and you can leave them as {ok}.",
			event_no_longer_open: "The event is no longer open.",
			range: "Range"
		},
		event_viewer: {
			organizer: "Organizer:",
			description: "Description:",
			should_happen: "Should happen:",
			create_poll: "Enter your availabiliy",
			update_poll: "Update your availabiliy",
			cancel_event: "Cancel event",
			no_participants: "{icon} The event has not been scheduled and nobody entered their availabiliy yet. Be the first one to answer!",
			no_participants_organizer: "{icon} The event has not been scheduled and nobody entered their availabiliy yet.",
			schedule_not_found: "We were unable to fetch the current schedule for this event",
			welcome: "{organizer} has invited you to this event.",
			welcome_organizer: "Hey {organizer}! Here you can manage your event.",
			event_open: "{calendar_icon} The event has not been scheduled yet. Below are the candidate dates so far, based on the answers from {participants} participants. If you haven't yet, please enter your availability",
			event_open_organizer: "{calendar_icon} You haven't scheduled the event yet. Below are the candidate dates so far, based on the answers from {participants}.",
			event_canceled: "This event has been canceled",
			event_canceled_organizer: "You canceled this event",
			event_scheduled: "{organizer} has scheduled this event to happen on: {datetime}",
			event_scheduled_organizer: "You have scheduled this event to happen on: {datetime}",
			organizer_says: "{organizer} says:",
			update: {
				title: "Update your answer",
				load: "Load your answer",
				how_to: "Enter the name you used to save your answer",
				name_placeholder: "Enter your name here...",
				poll_not_found: "No answer found under this name. Did you spell the name correctly?"
			},
			create_new_event: "Create a new event",
			really_cancel_event: "Are you sure you want to cancel the event?",
			event_canceled_ok: "Event successfully canceled",
			cancel_event_error: "An error has occurred, the event could not be canceled",
			open_event: 'Reopen the event',
			event_opened_ok: 'The event has been reopened',
			open_event_error: 'An error has occurred, the event could not be reopened',
			share_link: 'Share this link with participants:',
			nof_participants: "{participants} participant | {participants} participants",
			current_participants: "Current participants:",
			negative_participants_for_date: "Everybody can make it | {count} person can't make it | {count} people can't make it",
			positive_participants_for_date: "Everybody can make it | {count} person prefers this date | {count} people prefer this date",
			positive_participants_list_date: "{participants} likes this date | {participants} like this date",
			negative_participants_list_date: "{participants} can't make it | {participants} can't make it",
			schedule_event: "Schedule event",
			about_to_schedule: "You are about to schedule the event to happen on {date}",
			schedule_event_error: "An error has occurred, the event could not be scheduled",
			warning_bad_date: "Warning! {participants} person can't make it on this date | Warning! {participants} people cannot make it on this date",
			select_time: "Finally, select a time for the event:",
			date_selection_help: "Dates are ranked from {best} to {worst}. Click or hover on a date to see how many can make it on that day.",
			date_selection_help_organizer: "Dates are ranked from {best} to {worst}. Click or hover on a date to see who can make it on that day. To schedule the event, select a date first.",
			best: "best",
			worst: "worst",
			edit_event: "Edit event"
		},
		home: {
			title: 'Events made easy',
			subtitle_1: '{app_name} helps you find the best date for the events in your social circle',
			subtitle_2: 'No account needed. We only require your email to send you a link',
			step: 'Step {step}',
			how_it_works: 'Nail your event in 3 easy steps:',
			step1: {
				title: '{step} : Create the event',
				part1: 'Describe your event.',
				part2: 'Select the time period suitable for the event.',
				part3: 'Finally, invite with friends by sharing a Web link.'
			},
			step2: {
				title: '{step} : Let your friends decide',
				part1: 'Your friends can say if a date is {good}, {indifferent}, or {bad} for them.',
				part2: 'They can select weekdays or specific dates, even whole time periods.'
			},
			step3: {
				title: '{step} : Manage the event',
				part1: 'As an organizer, you always have a clear overview of your friends decisions.',
				part2: '{good} and {bad} dates are cleary visible on the calendar.',
				part3: 'When you are ready, pick a date, schedule the event and let your crowd now!'
			},
			create_new_event: 'Create an event now!',
			good: 'good | good',
			good_upper: 'Good | Good',
			indifferent: 'indifferent | indifferent',
			bad: 'bad | bad'
		},
		date_format: 'MM/DD/YYYY',
		datetime_format: 'MM/DD/YYYY h:mm A',
		time_format: 'h:mm A',
		week_days: {
			mo: 'Monday',
			tu: 'Tuesday',
			we: 'Wednesday',
			th: 'Thursday',
			fr: 'Friday',
			sa: 'Saturday',
			su: 'Sunday'
		},
		ranker: {
			good: "Good",
			ok: "Ok",
			bad: "Bad"
		},
		date_fns_locale: date_fns_en,
		errors: {
			required_field: "Can't be blank",
			network: "The server is not responding or cannot be reached. Check your Internet connection.",
			generic: "An error occurred while trying to contact the server: {message}",
			not_found: "The requested data could not be found on the server",
			server: "The server reported a {code} error",
			unprocessable_entity: "Ouch! The data you entered contains some errors, or something is missing. Please double check.",
			error: "Error",
			confirmation_required: "Doesn't match..."
		},
		event_header: {
			by: "by {organizer}",
			no_name: "No event name yet",
			no_dates: "No dates yet",
			scheduled: "Happening on {time}",
			open: "Sometime in {dates}",
			canceled: "Event canceled"
		},
		actions: {
			cancel: "Cancel",
			tell_me_more: "Tell me more",
			back_home: "Back home"
		}
	},

	de: {
		event_editor: {
			title: 'Neues Event',
			welcome: 'Hallo! Hier kannst du ein neues Event starten und mit Freunden teilen.',
			welcome_again: 'Hallo {organizer}! Hier kannst du die Details deines Events anpassen.',
			event: {
				name: "Wie heißt dein Event?",
				name_help: "Gib deinem Event einen Namen.",
				desc: "Was findet statt?",
				desc_help: "Beschreibe dein Event für deine Gäste.",
				dates: "Gib eine Zeitspanne ein, entweder aus dem Kalendar oder Drop-down.",
				organizer: "Wer bist du?",
				organizer_help: "Lass deine Freunde wissen, wer sie einlädt...",
				organizer_email: "Bitte gib deine Email ein.",
				organizer_email_help: "Wir benutzen deine Email lediglich, um dir einen privaten Link zu senden, mit dem du dein Event verwalten kannst.",
				organizer_email_confirmation_help: "Bitte bestätige deine Email. Auch den Besten unterläuft manchmal ein Fehler..."
			},
			general_info_group: 'Was ist das für ein Event?',
			dates_group: 'Wann soll es ungefähr stattfinden?',
			organizer_group: 'Wer organisiert das Event?',
			this_week: "Diese Woche",
			next_week: "Nächste Woche",
			within_months: "Binnen einem Monat | Binnen {count} Monaten",
			dates_quick_selection: "Schnelle Vorwahl",
			link_copied: "Link in der Zwischenablage gespeichert",
			event_created: "Gratulation {eventOrganizer}! Dein Event \u201C{eventName}\u201E wurde gespeichert.\
			 Ein Email wurde an {organizerEmail} gesendet.",
			event_created_short: "Dein Event wurde angelegt.",
			share_link: "Jetzt diesen Link mit Gästen teilen und einladen:",
			manage_event: "Event verwalten",
			create_event: "Event speichern",
			poll_event: "Gib deine Verfügbarkeit ein",
			dates_placeholder: "Zeitspanne auswählen",
			back_to_event: "Zurück zum Event",
			update_event: "Event aktualisieren",
			event_updated: "Die Details des Events wurden aktualisiert",
			too_many_requests_error: "Du hast zu viele Events für {email} angelegt. Gönne dir eine kurze Pause..."
		},
		poll_editor: {
			welcome: "Hey {participant}, hier kannst du deine Verfügbarkeit für dieses Event aktualisieren.",
			welcome_new_participant: "Hier kannst du deine Verfügbarkeit für dieses Event eingeben.",
			title: "Meine Verfügbarkeit für \u201C{eventName}\u201E",
			participant_group: "Wer bist du?",
			poll: {
				participant: "Teilnehmername",
				participant_help: "Lass dem Organisator wissen, wer du bist..."
			},
			weekday_ranker_group: "Wie sieht deine typische Woche aus?",
			weekday_ranker_help: "Gib ein, welche Tage deiner typischen Woche gut {good}, ok {ok}, oder schlecht {bad} sind für dieses Event. Du kannst später Ausnahmen für einzelne Daten hinzufügen. {help}.",
			calendar_ranker_group: "einzelne Daten auswählen",
			save_poll: "Verfügbarkeit speichern",
			delete_poll: "Verfügbarkeit löschen",
			poll_saved: "Deine Verfügbarkeit wurde gespeichert",
			really_delete: "Willst du wirklich deine Verfügbarkeit löschen? Das ist unumkehrbar.",
			back_to_event: "Zurück zum Event",
			poll_deleted: "Deine Verfügbarkeit wurde gelöscht",
			poll_delete_error: "Ein Fehler ist aufgetreten, deine Verfügbarkeit konnte nicht gelöscht werden.",
			dates_placeholder: "Zeitspanne auswählen",
			date_ranker_helper: "Wähl Daten aus, die gut {good} oder schlecht {bad} sind für dieses Event. Diese haben Vorrang vor deiner Auaswahl über die Wochentage. {help}.",
			date_ranker_help_modal_title: "Daten hinzufügen oder entfernen",
			date_ranker_help_modal_content: "Zuerst wähl aus, ob die Daten gut {good} oder schlecht {bad} sind für dieses Event.\
			Dann füg die Daten hinzu, entweder einzeln oder als Zeitspanne.\
			Um Daten zu entfernen, wähl {trash} aus, dann Daten anklicken.",
			weekday_ranker_help_modal_title: "Auswahl für die Wochentage",
			weekday_ranker_help_modal_content: "Wie sieht deine typische Woche aus? Zum Beispiel, \
			vielleicht gehst du mittwochs ins Fittnessstudio und den Wochentag als {bad} markieren. Ein Freitag könnte aber ein guter Tag sein für das Event\
			und du kannst ihn mit {good} markieren. Die anderen Tage sind vielleicht nur ok, und du kannst sie als {ok} lassen.",
			event_no_longer_open: "Das Event ist nicht mehr offen.",
			range: "Spanne"
		},
		event_viewer: {
			organizer: "Organisator:",
			description: "Beschreibung:",
			should_happen: "Soll stattfinden:",
			create_poll: "Verfügbarkeit angeben",
			update_poll: "Verfügbarkeit aktualisieren",
			cancel_event: "Event absagen",
			no_participants: "{icon} Für das Event wurde noch kein Datum festgelet und es liegt keine Verfügbarkeit vor. Sei der Erste, der antwortet!",
			no_participants_organizer: "{icon} Für das Event wurde noch kein Datum festgelet und es liegt keine Verfügbarkeit vor.",
			schedule_not_found: "Die Planung für dieses Event konnte nicht gefunden werden.",
			welcome: "{organizer} hat dich zu diesem Event eingeladen.",
			welcome_organizer: "Hey {organizer}! Hier kannst du dein Event verwalten.",
			event_open: "{calendar_icon} Der Organisator hat sich noch nicht für ein Datum entschieden. Hier unten sind die möglichen Daten, basierend auf den Antworten von {participants} Gästen. Gib deine Verfügbarkeit an, wenn du es noch nicht getan hast.",
			event_open_organizer: "{calendar_icon} Du hast dich noch nicht für ein Datum entschieden. Hier unten sind die möglichen Daten, basierend auf den Antworten von {participants}.",
			event_canceled: "Dieses Event wurde abgesagt",
			event_canceled_organizer: "Du hast dieses Event abgesagt",
			event_scheduled: "{organizer} hat entschieden, dass das Event am {datetime} stattfinden wird",
			event_scheduled_organizer: "Du hast entschieden, dass das Event am {datetime} stattfinden wird",
			organizer_says: "{organizer} sagt:",
			update: {
				title: "Verfügbarkeit aktualisieren",
				load: "Verfügbarkeit anzeigen",
				how_to: "Gib den Namen ein, unter dem du deine Verfügbarkeit gespeichert hast",
				name_placeholder: "Gib deinen Namen hier ein...",
				poll_not_found: "Keine Verfügbarkeit unter diesem Namen gefunden. Tippfehler vielleicht?"
			},
			create_new_event: "Neues Event starten",
			really_cancel_event: "Bist du sicher, dass du das Event absagen möchtest?",
			event_canceled_ok: "Event wurde erfolgreich abgesagt",
			cancel_event_error: "Ein Fehler ist aufgetreten, das Event konnte nicht abgesagt werden",
			open_event: 'Event wiederöffnen',
			event_opened_ok: 'Das Event wurde wiedergeöffnet',
			open_event_error: 'Ein Fehler ist aufgetreten, das Event konnte nicht wiedergeöffnet werden"',
			share_link: 'Teile diese Link mit deinen Gästen:',
			nof_participants: "{participants} Gast | {participants} Gäste",
			current_participants: "Aktuelle Gäste:",
			negative_participants_for_date: "Alle schaffen es | {count} Person schafft es nicht | {count} Personen schaffen es nicht",
			positive_participants_for_date: "Alle schaffen es | {count} Person bevorzugt diesen Tag | {count} Personen bevorzugen diesen Tag",
			positive_participants_list_date: "{participants} bevorzugt dieses Datum | {participants} bevorzugen dieses Datum",
			negative_participants_list_date: "{participants} schaffte es nicht | {participants} schaffen es nicht",
			schedule_event: "Datum festlegen",
			about_to_schedule: "Du willst das Event am {date} festlegen",
			schedule_event_error: "EIn Fehler ist aufgetreten, das Datum konnte nicht festgelegt werden",
			warning_bad_date: "Achtung! {participants} Person schafft es nicht an diesem Tag | Achtung! {participants} schaffen es nicht an diesem Datum",
			select_time: "Leg eine Uhrzeit für das Event fest:",
			date_selection_help: "Daten sind bewertet von {best} zu {worst}. Klick ein Datum, um zu sehen, wer an dem Tag kommen kann.",
			date_selection_help_organizer: "Daten sind bewertet von {best} zu {worst}. Klick ein Datum, um zu sehen, wer an dem Tag kommen kann. Wähl das Datum aus, das du festlegen möchtest",
			best: "gut",
			worst: "schlecht",
			edit_event: "Event editieren"
		},
		home: {
			title: 'Events leicht gemacht',
			subtitle_1: '{app_name} hilft dir dabei, die besten Daten für die Events in deinem Freundeskreis zu finden.',
			subtitle_2: 'Kein Account erforderlich. Wir lediglich brauchen eine Email, um dir einen Link zu senden.',
			step: 'Schritt {step}',
			how_it_works: 'Dein Event in 3 einfachen Schritten organisieren:',
			step1: {
				title: '{step} : Event starten',
				part1: 'Beschreibe dein Event.',
				part2: 'Wähl die passende Zeitspanne für dein Event aus.',
				part3: 'Dann, lad deine Freunde ein mit einem Weblink.'
			},
			step2: {
				title: '{step} : Deine Freunde entschieden',
				part1: 'Deine Freunde können angeben, ob ein Datum {good}, {indifferent}, oder {bad} ist für sie.',
				part2: 'Sie können Wochentage oder einzelne Daten auswählen, sogar Zeitspannen.'
			},
			step3: {
				title: '{step} : Event verwalten',
				part1: 'Als Organisator, du hast immer einen klaren Überblick über die Entscheidungen deiner Freunde.',
				part2: '{good} und {bad} Daten sind deutlich sichtbar im Kalendar.',
				part3: 'Wenn du bereit bist, wähl ein Datum aus, leg es fest und sag deiner Crowd Bescheid!'
			},
			create_new_event: 'Jetzt neues Event starten!',
			good: 'gut | gute',
			good_upper: 'Good | Gute',
			indifferent: 'gleichgültig | gleichgültige',
			bad: 'schlecht | schlechte'
		},
		date_format: 'DD/MM/YYYY',
		datetime_format: 'DD/MM/YYYY hh:mm',
		time_format: 'hh:mm',
		week_days: {
			mo: 'Montag',
			tu: 'Dienstag',
			we: 'Mittwoch',
			th: 'Donnerstag',
			fr: 'Freitag',
			sa: 'Samstag',
			su: 'Sonntag'
		},
		ranker: {
			good: "Gut",
			ok: "Ok",
			bad: "Schlecht"
		},
		date_fns_locale: date_fns_de,
		errors: {
			required_field: "Darf nicht leer sein",
			network: "Der Server antwortet nicht oder kann nicht erreicht werden. Überprüfe deine Internet-Verbindung.",
			generic: "Ein Fehler ist aufgetreten bei der Verbindung mit dem Sever: {message}",
			not_found: "Die angefordeten Daten konnten nicht gefunden werden.",
			server: "Der Server hat mit einem {code} Fehler geantwortet",
			unprocessable_entity: "Autsch! Die angegebenen Daten enthalten Fehler, oder etwas fehlt. Bitte Überprüfe deine Angaben.",
			error: "Fehler",
			confirmation_required: "Stimmt nicht überein..."
		},
		event_header: {
			by: "von {organizer}",
			no_name: "Noch kein Name für das Event",
			no_dates: "Noch keine Daten",
			scheduled: "Findet am {time} statt",
			open: "Irgendwann in {dates}",
			canceled: "Event wurde abgesagt"
		},
		actions: {
			cancel: "Abbrechen",
			tell_me_more: "Ich will mehr wissen",
			back_home: "Zur Homepage"
		}
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