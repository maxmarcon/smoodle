import * as dateFns from "date-fns";

export default {
    data() {
        return {
            eventName: null,
            eventOrganizer: null,
            eventOrganizerEmail: null,
            eventOrganizerEmail_confirmation: null,
            eventDesc: null,
            eventState: null,
            eventShareLink: null,
            eventPossibleDates: [],
            eventScheduledFrom: null,
            eventScheduledTo: null,
            eventInsertedAt: null,
            eventModifiedAt: null,
            eventWeekdays: this.initialWeekdays(),
            eventOrganizerMessage: null,
            eventPublicParticipants: false
        }
    },
    methods: {
        assignEventData({
                            name,
                            organizer,
                            email,
                            desc,
                            state,
                            scheduled_from,
                            scheduled_to,
                            share_link,
                            inserted_at,
                            updated_at,
                            preferences,
                            possible_dates = [],
                            organizer_message,
                            public_participants
                        }) {
            this.eventName = name
            this.eventOrganizer = organizer
            this.eventOrganizerEmail = email
            this.eventDesc = desc
            this.eventPossibleDates = possible_dates.map(({
                                                              date_from,
                                                              date_to,
                                                              rank
                                                          }) => ({
                date_from: dateFns.parseISO(date_from),
                date_to: dateFns.parseISO(date_to),
                rank
            }))
            this.eventState = state
            this.eventScheduledFrom = scheduled_from && dateFns.parseISO(scheduled_from)
            this.eventScheduledTo = scheduled_to && dateFns.parseISO(scheduled_to)
            this.eventShareLink = share_link
            this.eventInsertedAt = inserted_at && dateFns.parseISO(inserted_at)
            this.eventModifiedAt = updated_at && dateFns.parseISO(updated_at)
            this.eventOrganizerMessage = organizer_message;
            this.eventPublicParticipants = public_participants;
            (preferences || {
                weekdays: []
            }).weekdays.forEach(weekday => {
                let el = this.eventWeekdays.find(({
                                                      day
                                                  }) => day === weekday.day)
                if (el) {
                    el.value = weekday.rank >= 0
                }
            })
        },
        initialWeekdays() {
            return Object.keys(this.$i18n.t('week_days')).map((code, index) => ({
                day: index,
                name: `week_days.${code}`,
                value: true
            }));
        }
    },
    computed: {
        eventData() {
            return {
                eventName: this.eventName,
                eventOrganizer: this.eventOrganizer,
                eventOrganizerEmail: this.eventOrganizerEmail,
                eventDesc: this.eventDesc,
                eventPossibleDates: this.eventPossibleDates,
                eventState: this.eventState,
                eventScheduledFrom: this.eventScheduledFrom,
                eventScheduledTo: this.eventScheduledTo,
                eventShareLink: this.eventShareLink,
                eventWeekdays: this.eventWeekdays,
                eventOrganizerMessage: this.eventOrganizerMessage,
                eventTimeWindow: this.formattedEventTimeWindow,
                eventPublicParticipants: this.eventPublicParticipants
            };
        },
        eventDataForRequest() {
            let data = {
                name: this.eventName,
                desc: this.eventDesc,
                organizer: this.eventOrganizer,
                possible_dates: this.eventPossibleDates.map(({
                                                                 date_from,
                                                                 date_to,
                                                                 rank
                                                             }) => ({
                    date_from: dateFns.format(date_from, 'yyyy-MM-dd'),
                    date_to: dateFns.format(date_to, 'yyyy-MM-dd'),
                    rank: rank
                })),
                email: this.eventOrganizerEmail,
                email_confirmation: this.eventOrganizerEmail_confirmation,
                organizer_message: this.eventOrganizerMessage,
                public_participants: this.eventPublicParticipants,
                preferences: {
                    weekdays: this.eventWeekdays.filter(({
                                                             value
                                                         }) => !value)
                        .map(({
                                  day
                              }) => ({
                            day,
                            rank: -1
                        }))
                }
            };
            Object.keys(data).forEach((k) => data[k] === null && delete data[k]);
            return data;
        }
    }
}
