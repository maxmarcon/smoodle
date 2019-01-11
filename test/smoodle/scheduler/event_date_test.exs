defmodule Smoodle.Scheduler.EventDateTest do
  alias Smoodle.Scheduler.EventDate
  use ExUnit.Case

  @valid_attrs %{
    date_from: "2017-02-01",
    date_to: "2017-03-22",
    rank: 1.0
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

  test "date rank is invalid without a rank" do
    changeset = EventDate.changeset(%EventDate{}, Map.delete(@valid_attrs, :rank))
    refute changeset.valid?
    assert [rank: {_, [validation: :required]}] = changeset.errors
  end

  test "date rank is invalid without a non-negative rank" do
    changeset = EventDate.changeset(%EventDate{}, Map.replace!(@valid_attrs, :rank, -0.1))
    refute changeset.valid?

    assert [rank: {_, [validation: :number, kind: :greater_than_or_equal_to, number: 0]}] =
             changeset.errors
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
