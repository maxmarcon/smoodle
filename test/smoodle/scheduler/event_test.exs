defmodule Smoodle.Scheduler.EventTest do
	use Smoodle.DataCase

	alias Smoodle.Scheduler.Event

	@valid_attrs %{
		name: "Party",
		desc: "Yeah!",
		organizer: "Donald Trump",
		time_window_from: "2118-01-10",
		time_window_to: "2118-03-20",
		scheduled_from: "2118-02-05 19:00:00",
		scheduled_to: "2118-02-05 23:00:00",
		email: "bot@fake.com"
	}

	@past_event %{
		name: "Party",
		desc: "Yeah!",
		organizer: "Donald Trump",
		time_window_from: "1118-01-10",
		time_window_to: "1118-03-20",
		scheduled_from: "1118-02-05 19:00:00",
		scheduled_to: "1118-02-05 23:00:00",
		email: "bot@fake.com"
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
		changeset = Event.changeset(%Event{}, Map.replace!(@valid_attrs, :name, String.pad_trailing("Party", 51, "123")))
		assert [name: {_,  [count: 50, validation: :length, max: 50]}] = changeset.errors
	end

	test "changeset with organizer too long" do
		changeset = Event.changeset(%Event{}, Map.replace!(@valid_attrs, :organizer, String.pad_trailing("Trump", 51, "123")))
		assert [organizer: {_,  [count: 50, validation: :length, max: 50]}] = changeset.errors
	end

	test "changeset with description too long" do
		changeset = Event.changeset(%Event{}, Map.replace!(@valid_attrs, :desc, String.pad_trailing("Yeah!", 251, "123")))
		assert [desc: {_,  [count: 250, validation: :length, max: 250]}] = changeset.errors
	end

	test "changeset with invalid email" do
		changeset = Event.changeset(%Event{}, Map.replace!(@valid_attrs, :email, "me@invaliddomain"))
		assert [email: {_,  [validation: :format]}] = changeset.errors
	end

	test "changeset without email" do
		changeset = Event.changeset(%Event{}, Map.delete(@valid_attrs, :email))
		assert [email: {_,  [validation: :required]}] = changeset.errors
	end

	test "validate both time window ends must be defined" do
		changeset = Event.changeset(%Event{}, Map.delete(@valid_attrs, :time_window_from))
		assert [time_window_from: {_, [validation: :required]}] = changeset.errors

		changeset = Event.changeset(%Event{}, Map.delete(@valid_attrs, :time_window_to))
		assert [time_window_to: {_, [validation: :required]}] = changeset.errors
	end

	test "validate both scheduled ends must be defined" do
		changeset = Event.changeset(%Event{}, Map.delete(@valid_attrs, :scheduled_to))
		assert [scheduled: {_, [validation: :only_one_end_defined]}] = changeset.errors
	end

	test "validate both time window ends must be consistent" do
		changeset = Event.changeset(%Event{}, Map.replace!(@valid_attrs, :time_window_from, "2118-03-21"))
		assert [time_window: {_, [validation: :inconsistent_interval]}] = changeset.errors
	end

	test "validate both scheduled ends must be consistent" do
		changeset = Event.changeset(%Event{}, Map.replace!(@valid_attrs, :scheduled_to, "2118-02-05 18:00:01"))
		assert [scheduled: {_, [validation: :inconsistent_interval]}] = changeset.errors
	end

	test "validate time window can't be too large" do
		changeset = Event.changeset(%Event{}, Map.replace!(@valid_attrs, :time_window_to, "2119-01-11"))
		assert [time_window: {_, [validation: :time_interval_too_large]}] = changeset.errors
	end

	test "validate events cannot be in the past" do
		changeset = Event.changeset(%Event{}, @past_event)
		assert {_, [validation: :in_the_past]} = changeset.errors[:scheduled_to]
		assert {_, [validation: :in_the_past]} = changeset.errors[:scheduled_from]
		assert {_, [validation: :in_the_past]} = changeset.errors[:time_window_to]
		assert {_, [validation: :in_the_past]} = changeset.errors[:time_window_from]
	end

	test "changeset removes trailing and leading spaces" do
		changeset = Event.changeset(%Event{}, Map.replace!(@valid_attrs, :name, "  Too many leading and trailing spaces    "))
		{:ok, new_name} = Ecto.Changeset.fetch_change(changeset, :name)
		refute new_name =~ ~r/^\s/
		refute new_name =~ ~r/\s$/
	end
end