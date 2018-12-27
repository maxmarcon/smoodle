defmodule Smoodle.Scheduler.EventDateTest do
  use Smoodle.DataCase
  alias Smoodle.Scheduler.EventDate

  @valid_attrs %{
    date_from: "2017-02-01",
    date_to: "2017-03-22"
  }

  test "date rank is valid with valid data" do
    changeset = EventDate.changeset(%EventDate{}, @valid_attrs)
    assert changeset.valid?
  end

  test "date rank is invalid without a date" do
    changeset = EventDate.changeset(%EventDate{}, Map.delete(@valid_attrs, :date_from))
    refute changeset.valid?
    assert [date_from: {_, [validation: :required]}] = changeset.errors
  end

  test "date rank is invalid with a date_from later than date_to" do
    changeset =
      EventDate.changeset(
        %EventDate{},
        Map.merge(@valid_attrs, %{
          date_from: @valid_attrs[:date_to],
          date_to: @valid_attrs[:date_from]
        })
      )

    refute changeset.valid?
    assert [dates: {_, [validation: :inconsistent_interval]}] = changeset.errors
  end

  test "date rank is valid with date_from equal to date_to" do
    changeset =
      EventDate.changeset(
        %EventDate{},
        Map.merge(@valid_attrs, %{
          date_from: @valid_attrs[:date_to],
          date_to: @valid_attrs[:date_to]
        })
      )

    assert changeset.valid?
  end
end
