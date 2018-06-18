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
  def get_event_for_update!(id, owner_token) do
    Repo.get_by!(Event, id: id, owner_token: owner_token)
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
    |> Repo.insert
  end


  @doc """
  Updates a event.

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update
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
  def list_polls do
    Repo.all(Poll)
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
end
