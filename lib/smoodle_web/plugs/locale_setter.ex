defmodule SmoodleWeb.Plugs.Locale do
  import Plug.Conn

  def init(config), do: Keyword.merge(Application.get_env(:smoodle, SmoodleWeb.Plugs.Locale), config)

  def call(conn, config) do
    locale = Enum.find([
      locale_from_params(conn, config),
      locale_from_session(conn, config),
      locale_from_header(conn, config)
    ], &!is_nil(&1))
    if locale do
      set_locale(conn, locale, config)
    else
      conn
    end
  end

  @doc """

    iex> SmoodleWeb.Plugs.Locale.parse_accept_language_header("fr-CH")
    [{"fr-CH", 1.0}]

    iex> SmoodleWeb.Plugs.Locale.parse_accept_language_header("fr-CH, de-AU;q=0.9, it;q=0.1")
    [{"fr-CH", 1.0}, {"de-AU", 0.9}, {"it", 0.1}]

    iex> SmoodleWeb.Plugs.Locale.parse_accept_language_header("en-US,en;q=0.9,de;q=0.8")
    [{"en-US", 1.0}, {"en", 0.9}, {"de", 0.8}]

    iex> SmoodleWeb.Plugs.Locale.parse_accept_language_header("")
    []
  """
  def parse_accept_language_header(header) do
    with {:ok, header} <- Enum.fetch(header, 0) do
      header
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&parse_locale_tag/1)
      |> Enum.sort_by(&elem(&1, 1), &>=/2)
    else
      _ -> []
    end
  end

  defp parse_locale_tag(tag) do
    [_, locale | rest] = Regex.run(~r/([\w-]+)(?:;q=(\d\.\d+))?/, tag)
    if length(rest) > 0 do
      [quality] = rest
      {quality, _} = Float.parse(quality)
      {locale, quality}
    else
      {locale, 1.0}
    end
  end

  @doc """
    iex> SmoodleWeb.Plugs.Locale.locale_from_params(%{params: %{"locale" => "de"}}, available_locales: ~w(fr en de))
    "de"

    iex> SmoodleWeb.Plugs.Locale.locale_from_params(%{params: %{"locale" => "de"}}, available_locales: ~w(fr en))
    nil

    iex> SmoodleWeb.Plugs.Locale.locale_from_params(%{params: %{"locale" => "de"}}, available_locales: ~w(fr en de))
    "de"
  """
  def locale_from_params(conn, config) do
    with %{params: %{"locale" => locale}} <- conn,
      true <- locale in config[:available_locales]
    do
      locale
    else
      _ -> nil
    end
  end

  defp locale_from_session(conn, config) do
    with true <- config[:use_session],
      locale <- get_session(conn, :locale),
      true <- locale in config[:available_locales]
    do
      locale
    else
      _ -> nil
    end
  end

  defp locale_from_header(conn, config) do
    # TODO: proper decoding of a real header: fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5
    # should return "fr"
    parse_accept_language_header(get_req_header(conn, "accept-language"))
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&Enum.fetch!(String.split(&1, "-"), 0))
    |> Enum.find(&(&1 in config[:available_locales]))
  end

  defp set_locale(conn, locale, config) do
    Gettext.put_locale(SmoodleWeb.Gettext, locale)
    if config[:use_session] do
      put_session(conn, :locale, locale)
    else
      conn
    end
  end
end
