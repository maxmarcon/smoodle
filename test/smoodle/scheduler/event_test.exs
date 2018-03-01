defmodule Smoodle.Scheduler.EventTest do
	use Smoodle.DataCase

	alias Smoodle.Scheduler.Event

	@valid_attrs %{name: "Party", desc: "Yeah!"}

	test "changeset with valid attrs" do 
		changeset = Event.changeset_create(%Event{}, @valid_attrs)
		assert changeset.valid?
	end

	test "changeset with without name" do 
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
end