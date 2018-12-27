defmodule Smoodle.Scheduler.EventTest do
  use Smoodle.DataCase
  alias Smoodle.Scheduler.Event
  doctest Event

  @organizer_message "Glad everybody can make it"

  @valid_attrs %{
    name: "Party",
    desc: "Yeah!",
    organizer: "Donald Trump",
    possible_dates: [
      %{date_from: "2118-01-10", date_to: "2118-03-20"}
    ],
    scheduled_from: "2118-02-05 19:00:00",
    scheduled_to: "2118-02-05 23:00:00",
    organizer_message: @organizer_message,
    preferences: %{
      weekdays: [
        %{
          day: 5,
          permitted: true
        },
        %{
          day: 6,
          permitted: true
        }
      ]
    },
    state: "SCHEDULED",
    email: "bot@fake.com",
    email_confirmation: "bot@fake.com"
  }

  @past_event_scheduled %{
    name: "Party",
    desc: "Yeah!",
    organizer: "Donald Trump",
    possible_dates: [
      %{date_from: "1118-01-10", date_to: "1118-03-20"}
    ],
    scheduled_from: "1118-02-05 19:00:00",
    scheduled_to: "1118-02-05 23:00:00",
    state: "SCHEDULED",
    organizer_message: @organizer_message,
    preferences: %{
      weekdays: [
        %{
          day: 5,
          permitted: true
        },
        %{
          day: 6,
          permitted: true
        }
      ]
    },
    email: "bot@fake.com",
    email_confirmation: "bot@fake.com"
  }

  test "changeset with valid attrs" do
    changeset = Event.changeset(%Event{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset without name" do
    changeset = Event.changeset(%Event{}, Map.delete(@valid_attrs, :name))
    assert [name: {_, [validation: :required]}] = changeset.errors
  end

  test "changeset without organizer" do
    changeset = Event.changeset(%Event{}, Map.delete(@valid_attrs, :organizer))
    assert [organizer: {_, [validation: :required]}] = changeset.errors
  end

  test "changeset ignores id" do
    changeset = Event.changeset(%Event{}, Map.merge(@valid_attrs, %{id: "sneaky_id"}))
    assert changeset.valid?
    refute Map.has_key?(changeset.changes, :id)
  end

  test "changeset ignores secret" do
    changeset = Event.changeset(%Event{}, Map.merge(@valid_attrs, %{secret: "sneaky_token"}))
    assert changeset.valid?
    refute Map.has_key?(changeset.changes, :secret)
  end

  test "changeset with name too long" do
    changeset =
      Event.changeset(
        %Event{},
        Map.replace!(@valid_attrs, :name, String.pad_trailing("Party", 51, "123"))
      )

    assert [name: {_, [count: 50, validation: :length, kind: :max]}] = changeset.errors
  end

  test "changeset with organizer too long" do
    changeset =
      Event.changeset(
        %Event{},
        Map.replace!(@valid_attrs, :organizer, String.pad_trailing("Trump", 51, "123"))
      )

    assert [organizer: {_, [count: 50, validation: :length, kind: :max]}] = changeset.errors
  end

  test "changeset with description too long" do
    changeset =
      Event.changeset(
        %Event{},
        Map.replace!(@valid_attrs, :desc, String.pad_trailing("Yeah!", 251, "123"))
      )

    assert [desc: {_, [count: 250, validation: :length, kind: :max]}] = changeset.errors
  end

  test "changeset with organizer_message too long" do
    changeset =
      Event.changeset(
        %Event{},
        Map.put(@valid_attrs, :organizer_message, String.pad_trailing("Yeah!", 251, "123"))
      )

    assert [organizer_message: {_, [count: 250, validation: :length, kind: :max]}] =
             changeset.errors
  end

  test "organizer_message is cleared if state is open" do
    changeset =
      Event.changeset(
        %Event{},
        Map.drop(Map.put(@valid_attrs, :state, "OPEN"), [:scheduled_from, :scheduled_to])
      )

    assert {:ok, nil} = Ecto.Changeset.fetch_change(changeset, :organizer_message)
  end

  test "organizer_message is not cleared if state is not open" do
    changeset =
      Event.changeset(
        %Event{},
        @valid_attrs
      )

    assert {:ok, @organizer_message} = Ecto.Changeset.fetch_change(changeset, :organizer_message)
  end

  test "changeset with invalid email" do
    changeset =
      Event.changeset(
        %Event{},
        Map.replace!(@valid_attrs, :email, "me@invaliddomain")
        |> Map.replace!(:email_confirmation, "me@invaliddomain")
      )

    assert [email: {_, [validation: :format]}] = changeset.errors
  end

  test "changeset without email" do
    changeset = Event.changeset(%Event{}, Map.delete(@valid_attrs, :email))
    assert Enum.any?(changeset.errors, &match?({:email, {_, [validation: :required]}}, &1))
  end

  test "changeset without email confirmation" do
    changeset = Event.changeset(%Event{}, Map.delete(@valid_attrs, :email_confirmation))

    assert Enum.any?(
             changeset.errors,
             &match?({:email_confirmation, {_, [validation: :required]}}, &1)
           )
  end

  test "changeset with wrong email confirmation" do
    changeset =
      Event.changeset(
        %Event{},
        Map.replace!(@valid_attrs, :email_confirmation, "different@email.com")
      )

    assert Enum.any?(
             changeset.errors,
             &match?({:email_confirmation, {_, [validation: :confirmation]}}, &1)
           )
  end

  test "changeset with invalid state" do
    changeset =
      Event.changeset(
        %Event{},
        Map.drop(Map.put(@valid_attrs, :state, "INVALID_STATE"), [:scheduled_from, :scheduled_to])
      )

    assert [state: {_, [validation: :inclusion]}] = changeset.errors
  end

  test "scheduled fields cleared if state is not scheduled" do
    changeset = Event.changeset(%Event{}, %{@valid_attrs | state: "CANCELED"})
    assert changeset.valid?
    assert is_nil(changeset.changes.scheduled_from)
    assert is_nil(changeset.changes.scheduled_to)
  end

  test "scheduled fields required if state is scheduled" do
    changeset =
      Event.changeset(%Event{}, %{@valid_attrs | scheduled_from: nil, scheduled_to: nil})

    assert Enum.any?(
             changeset.errors,
             &match?({:scheduled_from, {_, [validation: :required]}}, &1)
           )

    assert Enum.any?(changeset.errors, &match?({:scheduled_to, {_, [validation: :required]}}, &1))
  end

  test "changeset with valid state" do
    changeset =
      Event.changeset(
        %Event{},
        Map.drop(Map.put(@valid_attrs, :state, "CANCELED"), [:scheduled_to, :scheduled_from])
      )

    assert changeset.valid?
  end

  test "validate both scheduled ends must be defined" do
    changeset = Event.changeset(%Event{}, %{@valid_attrs | scheduled_to: nil})

    assert Enum.any?(
             changeset.errors,
             &match?({:scheduled, {_, [validation: :only_one_end_defined]}}, &1)
           )
  end

  test "validate both scheduled ends must be consistent" do
    changeset =
      Event.changeset(%Event{}, Map.replace!(@valid_attrs, :scheduled_to, "2118-02-05 18:00:01"))

    assert [scheduled: {_, [validation: :inconsistent_interval]}] = changeset.errors
  end

  test "validate time window can't be too large" do
    changeset =
      Event.changeset(
        %Event{},
        Map.replace!(@valid_attrs, :possible_dates, [
          %{date_from: "2118-01-10", date_to: "2119-01-11"}
        ])
      )

    assert [possible_dates: {_, [validation: :time_interval_too_large]}] = changeset.errors
  end

  test "validate weekdays" do
    changeset = Event.changeset(%Event{}, %{@valid_attrs | preferences: %{weekdays: [%{day: 0}]}})
    weekday_changeset = hd(changeset.changes.preferences.changes.weekdays)
    assert [permitted: {_, [validation: :required]}] = weekday_changeset.errors
  end

  test "validate weekday duplicates" do
    changeset =
      Event.changeset(%Event{}, %{
        @valid_attrs
        | preferences: %{weekdays: [%{day: 0, permitted: true}, %{day: 0, permitted: true}]}
      })

    assert [weekdays: {_, [validation: :weekday_listed_twice]}] =
             changeset.changes.preferences.errors
  end

  test "validate at least one weekday enabled" do
    changeset =
      Event.changeset(%Event{}, %{
        @valid_attrs
        | preferences: %{weekdays: for(d <- 0..6, do: %{day: d, permitted: false})}
      })

    assert [weekdays: {_, [validation: :no_weekdays_enabled]}] =
             changeset.changes.preferences.errors
  end

  test "validate empty weekdays accepted" do
    changeset =
      Event.changeset(%Event{}, %{
        @valid_attrs
        | preferences: %{weekdays: []}
      })

    assert changeset.valid?
  end

  test "validate event cannot be scheduled in the past" do
    changeset = Event.changeset(%Event{}, @past_event_scheduled)

    assert {_, [validation: :in_the_past]} = changeset.errors[:scheduled_to]
    assert {_, [validation: :in_the_past]} = changeset.errors[:scheduled_from]
  end

  test "validate possible_dates cannot overlap" do
    changeset =
      Event.changeset(
        %Event{},
        Map.replace!(@valid_attrs, :possible_dates, [
          %{date_from: "2118-01-10", date_to: "2118-01-21"},
          %{date_from: "2118-01-20", date_to: "2118-01-22"}
        ])
      )

    assert [possible_dates: {_, [validation: :overlapping_dates]}] = changeset.errors
  end

  test "validate possible_dates is present" do
    changeset =
      Event.changeset(
        %Event{},
        Map.delete(@valid_attrs, :possible_dates)
      )

    assert [possible_dates: {_, [validation: :required]}] = changeset.errors
  end

  test "validate possible_dates has length > 0" do
    changeset =
      Event.changeset(
        %Event{},
        Map.replace!(@valid_attrs, :possible_dates, [])
      )

    assert [possible_dates: {_, [validation: :required]}] = changeset.errors
  end

  test "validate domain non empty" do
    changeset =
      Event.changeset(
        %Event{
          name: @valid_attrs.name,
          organizer: @valid_attrs.organizer,
          email: @valid_attrs.email,
          preferences: %{weekdays: [%{day: 6, permitted: true}]}
        },
        %{
          possible_dates: [%{date_from: "2118-01-03", date_to: "2118-01-08"}]
        }
      )

    assert [possible_dates: {_, [validation: :empty]}] = changeset.errors
  end

  test "changeset removes trailing and leading spaces" do
    changeset =
      Event.changeset(
        %Event{},
        Map.replace!(@valid_attrs, :name, "  Too many leading and trailing spaces    ")
      )

    {:ok, new_name} = Ecto.Changeset.fetch_change(changeset, :name)
    refute new_name =~ ~r/^\s/
    refute new_name =~ ~r/\s$/
  end
end
