defmodule SmoodleWeb.Plugs.Locale do
  import Plug.Conn

  @locales ["en", "de", "it"]

  def init(default), do: default

  def call(conn = %Plug.Conn{params: %{"locale" => locale}}, _default) when locale in @locales do
    set_locale(conn, locale)
  end

  def call(conn, default) do
    if (locale = get_session(conn, :locale)) in @locales do
      set_locale(conn, locale)
    else
      set_locale(conn, default)
    end
  end

  defp set_locale(conn, locale) do 
    Gettext.put_locale(SmoodleWeb.Gettext, locale)
    put_session(conn, :locale, locale)
  end
end
