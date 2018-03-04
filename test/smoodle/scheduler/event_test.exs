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
		assert [name: {_, [validation: :required]}] = changeset.errors
	end

	test "changeset with name too long" do 
		changeset = Event.changeset_create(%Event{}, Map.replace!(@valid_attrs, :name, String.pad_trailing("Party", 256, "123")))
		assert [name: {_,  [count: 255, validation: :length, max: 255]}] = changeset.errors
	end

	test "changeset with description too long" do 
		changeset = Event.changeset_create(%Event{}, Map.replace!(@valid_attrs, :desc, String.pad_trailing("Yeah!", 2501, "123")))
		assert [desc: {_,  [count: 2500, validation: :length, max: 2500]}] = changeset.errors
	end

	test "validate both time window ends must be defined" do
		changeset = Event.changeset_create(%Event{}, Map.delete(@valid_attrs, :time_window_from))
		assert [time_window: {_, [validation: :only_one_end_defined]}] = changeset.errors
	end

	test "validate both scheduled ends must be defined" do
		changeset = Event.changeset_create(%Event{}, Map.delete(@valid_attrs, :scheduled_to))
		assert [scheduled: {_, [validation: :only_one_end_defined]}] = changeset.errors
	end

	test "validate both time window ends must be consistent" do
		changeset = Event.changeset_create(%Event{}, Map.replace!(@valid_attrs, :time_window_from, "2018-03-25 00:00:00+00"))
		assert [time_window: {_, [validation: :inconsistent_interval]}] = changeset.errors
	end

	test "validate both scheduled ends must be consistent" do
		changeset = Event.changeset_create(%Event{}, Map.replace!(@valid_attrs, :scheduled_to, "2018-02-05 18:00:01+00"))
		assert [scheduled: {_, [validation: :inconsistent_interval]}] = changeset.errors
	end

end