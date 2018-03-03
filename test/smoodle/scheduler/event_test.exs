defmodule Smoodle.Scheduler.EventTest do
	use Smoodle.DataCase

	alias Smoodle.Scheduler.Event

	@valid_attrs %{
		name: "Party",
		desc: "Yeah!",
		time_window_from: "2018-01-10 00:00:00+00",
		time_window_to: "2018-03-20 00:00:00+00",
		scheduled_from: "2018-02-05 19:00:00+00",
		scheduled_to: "2018-02-05 23:00:00+00"
	}

	test "changeset with valid attrs" do 
		changeset = Event.changeset_create(%Event{}, @valid_attrs)
		assert changeset.valid?
	end

	test "changeset without name" do 
		changeset = Event.changeset_create(%Event{}, Map.delete(@valid_attrs, :name))
		assert %{name: ["can't be blank"]} = errors_on(changeset)
	end

	test "changeset with name too long" do 
		changeset = Event.changeset_create(%Event{}, Map.replace!(@valid_attrs, :name, String.pad_trailing("Party", 256, "123")))
		assert %{name: ["should be at most 255 character(s)"]} = errors_on(changeset)
	end

	test "changeset with description too long" do 
		changeset = Event.changeset_create(%Event{}, Map.replace!(@valid_attrs, :desc, String.pad_trailing("Yeah!", 2501, "123")))
		assert %{desc: ["should be at most 2500 character(s)"]} = errors_on(changeset)
	end

	test "validate both time window ends must be defined" do
		changeset = Event.changeset_create(%Event{}, Map.delete(@valid_attrs, :time_window_from))
		assert %{time_window: ["both ends must be defined or none"]} = errors_on(changeset)
	end

	test "validate both scheduled ends must be defined" do
		changeset = Event.changeset_create(%Event{}, Map.delete(@valid_attrs, :scheduled_to))
		assert %{scheduled: ["both ends must be defined or none"]} = errors_on(changeset)
	end

	test "validate both time window ends must be consistent" do
		changeset = Event.changeset_create(%Event{}, Map.replace!(@valid_attrs, :time_window_from, "2018-03-25 00:00:00+00"))
		assert %{time_window: ["the right side of the window must happen later than the left one"]} = errors_on(changeset)
	end

	test "validate both scheduled ends must be consistent" do
		changeset = Event.changeset_create(%Event{}, Map.replace!(@valid_attrs, :scheduled_to, "2018-02-05 18:00:01+00"))
		assert %{scheduled: ["the right side of the window must happen later than the left one"]} = errors_on(changeset)
	end

end