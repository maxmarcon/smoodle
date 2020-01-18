import * as dateFns from "date-fns";

export default {
    data() {
        return {
            pollParticipant: null,
            pollWeekdayRanks: this.initialWeeklyRanks(),
            pollDateRanks: []
        }
    },
    computed: {
        pollDataForRequest() {
            return {
                participant: this.pollParticipant,
                preferences: {
                    weekday_ranks: this.pollWeekdayRanks
                        .filter(({
                                     value
                                 }) => value) // exclude 0 ranks
                        .map(({
                                  day,
                                  value: rank
                              }) => ({
                            day,
                            rank
                        }))
                },
                date_ranks: this.pollDateRanks
                    .filter(({
                                 rank
                             }) => rank)
                    .map(({
                              date,
                              rank
                          }) => ({
                        date_from: dateFns.format(date, 'yyyy-MM-dd'),
                        date_to: dateFns.format(date, 'yyyy-MM-dd'),
                        rank: rank
                    }))
            }
        }
    },
    methods: {
        initialWeeklyRanks() {
            return Object.keys(this.$i18n.t('week_days')).map((code, index) => ({
                day: index,
                name: `week_days.${code}`,
                value: 0
            }));
        },
        datesKey: (date) => `${date.getTime()}`,
        assignPollData({
                           participant,
                           date_ranks = [],
                           preferences = {
                               weekday_ranks: []
                           },
                       },
                       eventWeekdays) {
            this.pollParticipant = participant;
            if (preferences === null) {
                preferences = { weekday_ranks: [] }
            }
            if (date_ranks === null) {
                date_ranks = []
            }

            eventWeekdays.forEach(({
                                       day: event_day,
                                       value: permitted
                                   }) => {
                let weekDayRank = this.pollWeekdayRanks.find(({
                                                                  day
                                                              }) => day === event_day)
                weekDayRank.disabled = !permitted
            })

            preferences.weekday_ranks.forEach((rank) => {
                let el = this.pollWeekdayRanks.find(({
                                                         day
                                                     }) => day === rank.day);
                if (el) {
                    el.value = rank.rank;
                }
            });

            this.pollDateRanks = date_ranks.map(({
                                                     date_from,
                                                     date_to,
                                                     rank
                                                 }) => {
                date_from = dateFns.parseISO(date_from)
                date_to = dateFns.parseISO(date_to)

                return dateFns.eachDayOfInterval({start: date_from, end: date_to}).map(date => ({
                    date,
                    rank,
                    key: this.datesKey(date)
                }))
            }).flat()
        }
    }
}
