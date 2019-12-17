# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Smoodle.Repo.insert!(%Smoodle.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
require Logger

alias Smoodle.Scheduler.Event
alias Smoodle.Scheduler.Poll
alias Smoodle.Scheduler.EventDate
alias Smoodle.Scheduler.DateRank
alias Smoodle.Repo

if Application.get_env(:smoodle, :env) != :dev do
  raise "seeder can only be executed in the dev environment"
end

event_data = [
  %{
    name: "Birthday Party",
    desc: "We'll meet at my place and then go out for drinks",
    public_participants: true
  },
  %{
    name: "Dinner with friends",
    desc: "There's this nice restaurant I'd like to try out",
    public_participants: false
  },
  %{
    name: "Workshop",
    desc: "Let's meet to discuss the buisness plan for the next semester",
    public_participants: false
  }
]

participants_count = (10..20)

fake_poll = fn event ->
  domain = Event.domain(event)

  date_ranks =
    domain
    |> Enum.take_random(round(length(domain) * 0.75))
    |> Enum.map(
         fn date ->
           %DateRank{
             date_from: date,
             date_to: date,
             rank: Faker.Util.pick([-1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0])
           }
         end
       )

  poll = Repo.insert!(
    %Poll{
      event_id: event.id,
      participant: Faker.Name.En.name(),
      date_ranks: date_ranks
    }
  )

  poll
end

fake_event = fn event_data ->

  date_from = Faker.Date.forward(60)
  date_to = Faker.Date.between(date_from, Date.add(date_from, 90))

  event = Repo.insert!(
    struct(
      Event,
      Map.merge(
        event_data,
        %{
          secret: "X",
          organizer: Faker.Name.En.name(),
          email: Faker.Internet.email(),
          possible_dates: [%EventDate{
            date_from: date_from,
            date_to: date_to,
            rank: 1.0
          }]
        }
      )
    )
  )

  Enum.each((1..Enum.random(10..20)), fn _ -> fake_poll.(event) end)

  event
end


events = Enum.map(event_data, fake_event)

Enum.each(
  events,
  fn event ->
    Logger.info(
      "Created event #{event.name} (#{Event.date_range(event).first} - #{Event.date_range(event).last})"
    )
    Logger.info("#{SmoodleWeb.EventView.share_link(event)}")
  end
)

