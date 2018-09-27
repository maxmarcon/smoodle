defmodule Smoodle.Scheduler do
  @moduledoc """
  The Scheduler context.
  """

  import Ecto.Query, warn: false
  alias Smoodle.Repo

  alias Smoodle.Scheduler.Event

  @doc """
  Returns the list of events.

  """
  def list_events do
    Repo.all(Event)
  end

  @doc """
  Gets a single event.

  Raises if the Event does not exist.

  """
  def get_event!(id) do
    Repo.get!(Event, id)
  end

  @doc """
  Gets a single event for an update, requires knowing the update token

  Raises if the Event does not exist or the token is wrong
  """
  def get_event!(id, secret) do
    Repo.get_by!(Event, id: id, secret: secret)
  end

  @doc """
  Creates an event.

  """
  #  def create_event(attrs, opts \\ [])

  #  def create_event(attrs, dry_run: true) do
  #    Event.changeset_insert(attrs)
  #  end

  def create_event(attrs) do
    Event.changeset_insert(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Event.

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  alias Smoodle.Scheduler.Poll

  @doc """
  Returns the list of polls.

  """
  def list_polls(%Event{} = event) do
    filter = [event_id: event.id]
    Repo.all(from(p in Poll, where: ^filter))
  end

  @doc """
  Gets a single poll.

  Raises `Ecto.NoResultsError` if the Poll does not exist.

  ## Examples

      iex> get_poll!(123)
      %Poll{}

      iex> get_poll!(456)
      ** (Ecto.NoResultsError)

  """
  def get_poll!(id) do
    Repo.get!(Poll, id)
  end

  def get_poll!(event_id, participant) do
    Repo.get_by!(Poll, event_id: event_id, participant: participant)
  end

  @doc """
  Creates a poll.
  """
  #  def create_poll(event, attrs, opts \\ [])

  #  def create_poll(%Event{} = event, attrs, dry_run: true) do
  #    Ecto.build_assoc(event, :polls)
  #    |> Poll.changeset(attrs)
  #  end

  def create_poll(%Event{} = event, attrs) do
    Ecto.build_assoc(event, :polls)
    |> Map.put(:event, event)
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a poll.

  """
  # def update_poll(poll, attrs, opts \\ [])

  #  def update_poll(%Poll{} = poll, attrs, dry_run: true) do
  #    poll
  #    |> Repo.preload([:event, :date_ranks])
  #    |> Poll.changeset(attrs)
  #  end

  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Repo.preload([:event, :date_ranks])
    |> Poll.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a poll

  """
  def delete_poll(%Poll{} = poll) do
    Repo.delete(poll)
  end

  def empty_schedule do
    %{
      dates: [],
      participants: [],
      participants_count: 0
    }
  end

  def get_best_schedule(%Event{} = event, opts \\ []) do
    polls =
      Repo.all(Ecto.assoc(event, :polls))
      |> Repo.preload(:date_ranks)
      |> Enum.map(&transorm_poll_for_ranking/1)

    is_owner = opts[:is_owner]
    limit = opts[:limit]

    start_date =
      case Date.compare(Date.utc_today(), event.time_window_from) do
        :gt -> Date.utc_today()
        _ -> event.time_window_from
      end

    %{
      dates:
        Enum.map(
          generate_date_ranking(start_date, event.time_window_to, polls, limit),
          fn date_entry ->
            if is_owner do
              date_entry
            else
              Map.drop(date_entry, [:negative_participants, :positive_participants])
            end
          end
        ),
      participants:
        if is_owner do
          Enum.map(polls, &Map.get(&1, :participant))
        else
          []
        end,
      participants_count: Enum.count(polls)
    }
  end

  defp generate_date_ranking(start_date, end_date, polls, limit \\ nil) do
    if Date.compare(start_date, end_date) == :lt && Enum.any?(polls) do
      Date.range(start_date, end_date)
      |> Enum.map(fn date ->
        Enum.reduce(
          polls,
          %{
            date: date,
            negative_rank: 0,
            positive_rank: 0,
            negative_participants: [],
            positive_participants: []
          },
          &reduce_polls_for_date/2
        )
      end)
      |> Enum.sort(fn d1, d2 ->
        cond do
          d1.negative_rank != d2.negative_rank ->
            d1.negative_rank > d2.negative_rank

          d1.positive_rank != d2.positive_rank ->
            d1.positive_rank > d2.positive_rank

          true ->
            Date.compare(d1.date, d2.date) != :gt
        end
      end)
      |> shorten_ranking(limit)
    else
      []
    end
  end

  defp shorten_ranking(ranking, limit) do
    if limit do
      Enum.take(ranking, limit)
    else
      ranking
    end
  end

  defp reduce_polls_for_date(poll, acc) do
    rank = compute_rank(poll, acc.date)

    Map.update!(acc, :negative_rank, fn value ->
      if rank < 0 do
        value + rank
      else
        value
      end
    end)
    |> Map.update!(:positive_rank, fn value ->
      if rank > 0 do
        value + rank
      else
        value
      end
    end)
    |> Map.update!(:negative_participants, fn participants ->
      if rank < 0 do
        [poll.participant | participants]
      else
        participants
      end
    end)
    |> Map.update!(:positive_participants, fn participants ->
      if rank > 0 do
        [poll.participant | participants]
      else
        participants
      end
    end)
  end

  defp compute_rank(%{} = poll, %Date{} = date) do
    date_rank =
      case Enum.find(poll.date_ranks, fn {date_range, _} -> Enum.member?(date_range, date) end) do
        {_, rank} -> rank
        nil -> nil
      end

    weekday_rank = poll.weekday_ranks[Date.day_of_week(date)] || 0

    date_rank || weekday_rank
  end

  defp transorm_poll_for_ranking(%Poll{} = poll) do
    poll
    |> Map.from_struct()
    |> Map.update!(
      :date_ranks,
      &(&1
        |> Enum.map(fn %{date_from: date_from, date_to: date_to, rank: rank} ->
          {Date.range(date_from, date_to), rank}
        end)
        |> Enum.sort())
    )
    |> Map.put(
      :weekday_ranks,
      case poll.preferences do
        nil ->
          %{}

        _ ->
          Enum.map(poll.preferences.weekday_ranks, fn %{day: day, rank: rank} ->
            {day + 1, rank}
          end)
          |> Map.new()
      end
    )
    |> Map.take([:date_ranks, :weekday_ranks, :participant])
  end
end
