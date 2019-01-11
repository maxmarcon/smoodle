defmodule Smoodle.Scheduler.DateRankTest do
  alias Smoodle.Scheduler.DateRank
  use ExUnit.Case

  @valid_attrs %{
    date_from: "2017-02-01",
    date_to: "2017-03-22",
    rank: 0.2
  }

  test "date rank is valid with valid data" do
    changeset = DateRank.changeset(%DateRank{}, @valid_attrs)
    assert changeset.valid?
  end

  test "date rank is invalid without a date" do
    changeset = DateRank.changeset(%DateRank{}, Map.delete(@valid_attrs, :date_from))
    refute changeset.valid?
    assert [date_from: {_, [validation: :required]}] = changeset.errors
  end

  test "date rank is invalid without rank" do
    changeset = DateRank.changeset(%DateRank{}, Map.delete(@valid_attrs, :rank))
    refute changeset.valid?
    assert [rank: {_, [validation: :required]}] = changeset.errors
  end

  test "date rank is invalid with 0 rank" do
    changeset = DateRank.changeset(%DateRank{}, Map.put(@valid_attrs, :rank, 0.0))
    refute changeset.valid?
    assert [rank: {_, [validation: :must_be_nonzero]}] = changeset.errors
  end

  test "date rank is invalid with a date_from later than date_to" do
    changeset =
      DateRank.changeset(
        %DateRank{},
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
      DateRank.changeset(
        %DateRank{},
        Map.merge(@valid_attrs, %{
          date_from: @valid_attrs[:date_to],
          date_to: @valid_attrs[:date_to]
        })
      )

    assert changeset.valid?
  end
end
