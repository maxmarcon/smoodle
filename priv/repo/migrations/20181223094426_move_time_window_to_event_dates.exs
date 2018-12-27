defmodule Smoodle.Repo.Migrations.MoveTimeWindowToEventDates do
  use Ecto.Migration
  alias Ecto.Adapters.SQL
  alias Smoodle.Repo

  def up do
    %{rows: rows} = SQL.query!(Repo, "select id, time_window_from, time_window_to from events")

    Enum.each(rows, fn row ->
      SQL.query!(
        Repo,
        "insert into event_dates (event_id, date_from, date_to, inserted_at, updated_at) values ($1, $2, $3, now(), now())",
        row
      )
    end)
  end

  def down do
    %{rows: rows} = SQL.query!(Repo, "select date_from, date_to, event_id from event_dates")

    Enum.each(rows, fn row ->
      SQL.query!(
        Repo,
        "update events set time_window_to = $1, time_window_from = $2 where id = $3",
        row
      )

      SQL.query!(
        Repo,
        "delete from event_dates where event_id = $1",
        [get_in(row, [Access.at(2)])]
      )
    end)

    alter table(:events) do
      modify(:time_window_from, :date, null: false)
      modify(:time_window_to, :date, null: false)
    end
  end
end
