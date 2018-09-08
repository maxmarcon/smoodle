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
				desc_help: "Describe the event",
				dates: "Specify a custom time period or select one from the drop-down",
				organizer: "Who are you?",
				organizer_help: "Let your friends know who invitied them...",
				organizer_email: "Please enter your email",
				organizer_email_help: "We will use this email to send you a private link that you can use to manage the event",
				organizer_email_confirmation_help: "Please confirm your email here. Even the best make mistakes sometimes..."
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
			welcome: "Hey {participant}, here you can update your poll for ths event.",
			welcome_new_participant: "Here you can enter your availabiliy for this event.",
			title: "Poll for \u201C{eventName}\u201E",
			participant_group: "Who are you?",
			poll: {
				participant: "Participant name",
				participant_help: "Tell the organizer who you are..."
			},
			weekday_ranker_group: "How is your typical week?",
			weekday_ranker_help: "Specify which days of your typical week are good {good}, just fine {ok}, or bad {bad} for the event. You can add exception for specific dates later. {help}.",
			calendar_ranker_group: "Select specific dates",
			save_poll: "Save poll",
			delete_poll: "Delete poll",
			poll_saved: "Your poll has been saved",
			really_delete: "Do you really want to delete your poll? This operation can't be undone",
			back_to_event: "Back to the event",
			poll_deleted: "Your poll has been deleted",
			poll_delete_error: "An error has occurred, the poll could not be deleted",
			dates_placeholder: "Select a time period",
			date_ranker_helper: "Select specific date ranges that are good {good} or bad {bad} for the event. This takes precedence over the preferences you expressed for the week days. {help}.",
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
			create_poll: "Answer the poll",
			update_poll: "Update your answer",
			cancel_event: "Cancel event",
			no_participants: "{icon} The event has not been scheduled and nobody answered the poll yet. Be the first one to answer the poll!",
			no_participants_organizer: "{icon} The event has not been scheduled and nobody answered the poll yet. Tell your invitees to answer the poll!",
			schedule_not_found: "We were unable to fetch the current schedule for this event",
			welcome: "{organizer} has invited you to this event.",
			welcome_organizer: "Hey {organizer}! Here you can manage your event.",
			event_open: "{calendar_icon} The event has not been scheduled yet. Below are the candidate dates so far, based on the answers from {participants} participants. If you haven't yet, please answer a poll\
								to enter your availability",
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
			nof_participants: "{participants} participants",
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
			title: 'Gathering made easy',
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
			good: 'good',
			good_upper: 'Good',
			indifferent: 'indifferent',
			bad: 'bad'
		},
		date_format: 'MM/DD/YYYY',
		datetime_format: 'MM/DD/YYYY h:mm A',
		time_format: 'h:mm A',
		week_days: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
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
			unprocessable_entity: "Ops! The data you entered contains some errors, or something is missing. Please double check.",
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
		time_format: 'MM/DD/YYYY h:mm A',
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