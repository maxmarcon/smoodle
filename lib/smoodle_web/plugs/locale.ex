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

  defp parse_accept_language_header(header) do
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

  defp locale_from_params(conn, config) do
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
