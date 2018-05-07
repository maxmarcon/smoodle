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

  defp locale_from_params(conn, config) do
    with %{params: %{"locale" => locale}} <- conn,
      true <- Enum.member?(config[:available_locales], locale)
    do
      locale
    else
      _ -> nil
    end
  end

  defp locale_from_session(conn, config) do
    with true <- config[:use_session],
      locale <- get_session(conn, :locale),
      true <- Enum.member?(config[:available_locales], locale)
    do
      locale
    else
      _ -> nil
    end
  end

  defp locale_from_header(conn, config) do
    # TODO: proper decoding of a real header: fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5
    # should return "fr"
    with [locale | _] <- get_req_header(conn, "accept-language"),
      true <- Enum.member?(config[:available_locales], locale)
    do
      locale
    else
      _ -> nil
    end
  end

  defp set_locale(conn, locale, config) do
    Gettext.put_locale(SmoodleWeb.Gettext, locale)
    if config[:use_session] do
      put_session(conn, locale, locale)
    else
      conn
    end
  end
end
