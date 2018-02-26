defmodule Smoodle.Scheduler do
  @moduledoc """
  The Scheduler context.
  """

  import Ecto.Query, warn: false
  alias Smoodle.Repo

  alias Smoodle.Scheduler.Event

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  @doc """
  Gets a single event.

  Raises if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

  """
  def get_event!(id) do
    Repo.get!(Event, id)
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, ...}

  """
  def create_event(attrs \\ %{}) do
    raise "TODO"
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, ...}

  """
  def update_event(%Event{} = event, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, ...}

  """
  def delete_event(%Event{} = event) do
    raise "TODO"
  end

  @doc """
  Returns a datastructure for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Todo{...}

  """
  def change_event(%Event{} = event) do
    raise "TODO"
  end
end
