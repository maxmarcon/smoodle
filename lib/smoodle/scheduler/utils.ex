defmodule Smoodle.Scheduler.Utils do
  import Ecto.Changeset
  import SmoodleWeb.Gettext

  @doc """
  iex> types = %{df: :date, dt: :date}
  iex> changes = %{df: ~D[2017-01-01], dt: ~D[2017-01-10]}
  iex> changeset = Ecto.Changeset.change({%{}, types}, changes)
  iex> changeset == Smoodle.Scheduler.Utils.validate_window_consistent(changeset, [:df, :dt], :dates, Date)
  true

  iex> types = %{df: :date, dt: :date}
  iex> changes = %{df: ~D[2017-02-01], dt: ~D[2017-01-10]}
  iex> changeset = Ecto.Changeset.change({%{}, types}, changes)
  iex> result = Smoodle.Scheduler.Utils.validate_window_consistent(changeset, [:df, :dt], :dates, Date)
  iex> result.errors[:dates]
  {"the right side of the window must happen later than the left one", [validation: :inconsistent_interval]}

  iex> types = %{df: :naive_datetime, dt: :naive_datetime}
  iex> changes = %{df: ~N[2017-02-01 12:00:00], dt: ~N[2017-01-10 11:00:00]}
  iex> changeset = Ecto.Changeset.change({%{}, types}, changes)
  iex> result = Smoodle.Scheduler.Utils.validate_window_consistent(changeset, [:df, :dt], :dates)
  iex> result.errors[:dates]
  {"the right side of the window must happen later than the left one", [validation: :inconsistent_interval]}

  iex> types = %{df: :date, dt: :date}
  iex> changes = %{df: ~D[2017-02-01], dt: ~D[2017-01-10]}
  iex> changeset = Ecto.Changeset.change({%{}, types}, changes)
  iex> changeset == Smoodle.Scheduler.Utils.validate_window_consistent(changeset, [:df], :dates)
  true
  """
  def validate_window_consistent(changeset, keys, error_key, t \\ NaiveDateTime) do
    with [t1, t2] <-
           Enum.map(keys, &fetch_field(changeset, &1))
           |> Enum.map(&elem(&1, 1)),
         false <- Enum.any?([t1, t2], &is_nil/1),
         :gt <- t.compare(t1, t2) do
      add_error(
        changeset,
        error_key,
        dgettext("errors", "the right side of the window must happen later than the left one"),
        validation: :inconsistent_interval
      )
    else
      _ -> changeset
    end
  end

  @doc """
  iex> Smoodle.Scheduler.Utils.date_lte(~D[2018-02-01], ~D[2018-02-02])
  true

  iex> Smoodle.Scheduler.Utils.date_lte(~D[2018-02-01], ~D[2018-02-01])
  true

  iex> Smoodle.Scheduler.Utils.date_lte(~D[2018-02-01], ~D[2018-01-31])
  false

  iex> Smoodle.Scheduler.Utils.date_lte(nil, ~D[2018-01-31])
  true
  """
  def date_lte(d1, d2) when is_map(d1) and is_map(d2) do
    Date.compare(d1, d2) != :gt
  end

  def date_lte(_, _) do
    true
  end

  @doc """
  iex> cs = Ecto.Changeset.change({%{name: " Snoopy "}, %{name: :string, job: :string}}, %{job: "		dog"})
  iex> cs = Smoodle.Scheduler.Utils.trim_text_changes(cs, [:name, :job])
  iex> Ecto.Changeset.apply_changes(cs)
  %{name: " Snoopy ", job: "dog"}

  iex> cs = Ecto.Changeset.change({%{name: " Snoopy  "}, %{name: :string, job: :string}}, %{name: "Snoopy ", job: "		dog"})
  iex> cs = Smoodle.Scheduler.Utils.trim_text_changes(cs, [:name, :job])
  iex> Ecto.Changeset.apply_changes(cs)
  %{name: "Snoopy", job: "dog"}

  iex> cs = Ecto.Changeset.change({%{name: " Snoopy	", job: "		dog"}, %{name: :string, job: :string}})
  iex> cs = Smoodle.Scheduler.Utils.trim_text_changes(cs, [])
  iex> Ecto.Changeset.apply_changes(cs)
  %{name: " Snoopy	", job: "		dog"}

  iex> cs = Ecto.Changeset.change({%{name: " Snoopy	", job: "		dog"}, %{name: :string, job: :string}}, %{name: "Snoopy	", job: "		dog"})
  iex> cs = Smoodle.Scheduler.Utils.trim_text_changes(cs, [])
  iex> Ecto.Changeset.apply_changes(cs)
  %{name: "Snoopy	", job: "		dog"}
  """
  def trim_text_changes(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, cs ->
      update_change(cs, field, &String.trim/1)
    end)
  end

  def validate_nonzero(changeset, field) do
    if get_change(changeset, field) == 0 do
      add_error(
        changeset,
        field,
        dgettext("errors", "must be different than zero"),
        validation: :must_be_nonzero
      )
    else
      changeset
    end
  end

  @doc """
  iex> cs = Ecto.Changeset.change({%{weekdays: [%{day: 1}]}, %{weekdays: List}}, %{weekdays: [%{day: 0}, %{day: 1}]})
  iex> cs = Smoodle.Scheduler.Utils.validate_no_weekday_duplicates(cs)
  iex> cs.errors
  []

  iex> cs = Ecto.Changeset.change({%{weekdays: [%{day: 1}]}, %{weekdays: List}}, %{weekdays: [%{day: 0}, %{day: 0}]})
  iex> cs = Smoodle.Scheduler.Utils.validate_no_weekday_duplicates(cs)
  iex> cs.errors
  [weekdays: {"you can only list a weekday once", [validation: :weekday_listed_twice]}]
  """
  def validate_no_weekday_duplicates(changeset, key \\ :weekdays) do
    case fetch_field(changeset, key) do
      {_, changes} ->
        if Enum.count(Enum.uniq_by(changes, fn %{day: day} -> day end)) != Enum.count(changes) do
          add_error(
            changeset,
            key,
            dgettext("errors", "you can only list a weekday once"),
            validation: :weekday_listed_twice
          )
        else
          changeset
        end

      _ ->
        changeset
    end
  end

  @spec validate_no_overlapping_dates(Ecto.Changeset.t(), atom) :: list
  @doc """
  Validates that a list of date ranges accessed via "key" do not overlap

  ### Examples:

  iex> cs = Ecto.Changeset.change({%{dates: []}, %{dates: List}}, %{dates: [%{date_from: ~D[2018-10-01], date_to: ~D[2018-10-14]}]})
  iex> cs = Smoodle.Scheduler.Utils.validate_no_overlapping_dates(cs, :dates)
  iex> cs.errors
  []

  iex> cs = Ecto.Changeset.change({%{dates: [%{date_from: ~D[2018-10-01], date_to: ~D[2018-10-05]}, %{date_from: ~D[2018-10-03], date_to: ~D[2018-10-06]}]}, %{dates: List}}, %{})
  iex> cs = Smoodle.Scheduler.Utils.validate_no_overlapping_dates(cs, :dates)
  iex> cs.errors
  [dates: {"dates cannot overlap", [validation: :overlapping_dates]}]


  iex> cs = Ecto.Changeset.change({%{dates: [%{date_from: ~D[2018-10-01], date_to: ~D[2018-10-05]}]}, %{dates: List}}, %{})
  iex> cs = Smoodle.Scheduler.Utils.validate_no_overlapping_dates(cs, :dates)
  iex> cs.errors
  []

  iex> cs = Ecto.Changeset.change({%{dates: []}, %{dates: List}}, %{dates: [%{date_from: ~D[2018-10-01], date_to: ~D[2018-10-14]}, %{date_from: ~D[2018-10-01], date_to: ~D[2018-10-01]}]})
  iex> cs = Smoodle.Scheduler.Utils.validate_no_overlapping_dates(cs, :dates)
  iex> cs.errors
  [dates: {"dates cannot overlap", [validation: :overlapping_dates]}]

  iex> cs = Ecto.Changeset.change({%{dates: []}, %{dates: List}}, %{})
  iex> cs = Smoodle.Scheduler.Utils.validate_no_overlapping_dates(cs, :dates)
  iex> cs.errors
  []

  iex> cs = Ecto.Changeset.change({%{dates: []}, %{dates: List}}, %{dates: [%{date_from: ~D[2018-10-01], date_to: ~D[2018-10-01]}]})
  iex> cs = Smoodle.Scheduler.Utils.validate_no_overlapping_dates(cs, :dates)
  iex> cs.errors
  []
  """
  def validate_no_overlapping_dates(changeset, key) do
    flattened_ranges_sorted_by_date_from =
      changeset
      |> get_field(key)
      |> Enum.filter(&(!is_nil(&1.date_from) && !is_nil(&1.date_to)))
      |> Enum.sort_by(& &1.date_from, &date_lte/2)
      |> Enum.flat_map(&Enum.uniq([&1.date_from, &1.date_to]))

    all_dates_sorted = Enum.sort(flattened_ranges_sorted_by_date_from, &date_lte/2)

    if flattened_ranges_sorted_by_date_from != all_dates_sorted ||
         Enum.uniq(all_dates_sorted) != all_dates_sorted do
      add_error(
        changeset,
        key,
        dgettext("errors", "dates cannot overlap"),
        validation: :overlapping_dates
      )
    else
      changeset
    end
  end
end
