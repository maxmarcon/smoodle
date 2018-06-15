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
    with [t1, t2] <- Enum.map(keys, &fetch_field(changeset, &1))
      |> Enum.map(&elem(&1, 1)),
      false <- Enum.any?([t1, t2], &is_nil/1),
      :gt <- t.compare(t1, t2)
    do
      add_error(changeset, error_key, dgettext("errors", "the right side of the window must happen later than the left one"), validation: :inconsistent_interval)
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
  """
  def date_lte(%Date{} = d1, %Date{} = d2) do
  	Date.compare(d1, d2) != :gt
 	end

 	@doc """
		iex> cs = Ecto.Changeset.change({%{name: " Snoopy "}, %{name: :string, job: :string}}, %{job: "		dog"})
		iex> cs = Smoodle.Scheduler.Utils.trim_text_fields(cs, [:name, :job])
		iex> Ecto.Changeset.apply_changes(cs)
		%{name: " Snoopy ", job: "dog"}

		iex> cs = Ecto.Changeset.change({%{name: " Snoopy  "}, %{name: :string, job: :string}}, %{name: "Snoopy ", job: "		dog"})
		iex> cs = Smoodle.Scheduler.Utils.trim_text_fields(cs, [:name, :job])
		iex> Ecto.Changeset.apply_changes(cs)
		%{name: "Snoopy", job: "dog"}

		iex> cs = Ecto.Changeset.change({%{name: " Snoopy	", job: "		dog"}, %{name: :string, job: :string}})
		iex> cs = Smoodle.Scheduler.Utils.trim_text_fields(cs, [])
		iex> Ecto.Changeset.apply_changes(cs)
		%{name: " Snoopy	", job: "		dog"}

		iex> cs = Ecto.Changeset.change({%{name: " Snoopy	", job: "		dog"}, %{name: :string, job: :string}}, %{name: "Snoopy	", job: "		dog"})
		iex> cs = Smoodle.Scheduler.Utils.trim_text_fields(cs, [])
		iex> Ecto.Changeset.apply_changes(cs)
		%{name: "Snoopy	", job: "		dog"}
 	"""
 	def trim_text_fields(changeset, fields) do
    Enum.reduce(fields, changeset, fn field, cs ->
    	update_change(cs, field, &String.trim/1)
    end)
  end
end