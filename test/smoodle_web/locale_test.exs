defmodule LocaleSetterTest do
  use SmoodleWeb.ConnCase

  setup do
  	{:ok, [available_locales: ["de", "it", "en"]]}
  end

  test "setting locale through request parameters works", config do
  	SmoodleWeb.Plugs.Locale.call build_conn(:get, "/", %{"locale" => "de"}), config
  	assert Gettext.get_locale(SmoodleWeb.Gettext) == "de"
  end

  describe "when setting the loacle through the accept-lanugage header" do

	  test "header: 'de' works", config do
	  	conn = put_req_header(build_conn(), "accept-language", "de")
	  	SmoodleWeb.Plugs.Locale.call conn, config
	  	assert Gettext.get_locale(SmoodleWeb.Gettext) == "de"
	  end

	  test "header: 'de-CH, en;q=0.9, it;q=0.4' works", config do
	  	conn = put_req_header(build_conn(), "accept-language", "de-CH, en;q=0.9, it;q=0.4")
	  	SmoodleWeb.Plugs.Locale.call conn, config
	  	assert Gettext.get_locale(SmoodleWeb.Gettext) == "de"
	  end

	  test "header: 'de-CH;q=0.8, en;q=0.9, it;q=0.91' works", config do
	  	conn = put_req_header(build_conn(), "accept-language", "de-CH;q=0.8, en;q=0.9, it;q=0.91")
	  	SmoodleWeb.Plugs.Locale.call conn, config
	  	assert Gettext.get_locale(SmoodleWeb.Gettext) == "it"
	  end

	  test "header: 'de-US;q=0.8, de-DE, it;q=0.91' works", config do
	  	conn = put_req_header(build_conn(), "accept-language", "de-US;q=0.8, de-DE, it;q=0.91")
	  	SmoodleWeb.Plugs.Locale.call conn, config
	  	assert Gettext.get_locale(SmoodleWeb.Gettext) == "de"
	  end

	  test "invalid header is ignored", config do
	  	conn = put_req_header(build_conn(), "accept-language", "xxxx")
	  	SmoodleWeb.Plugs.Locale.call conn, config
	  	assert Gettext.get_locale(SmoodleWeb.Gettext) == "en"
	  end
	end

	test "no header and no parameter results in default locale", config do
		SmoodleWeb.Plugs.Locale.call build_conn(), config
  	assert Gettext.get_locale(SmoodleWeb.Gettext) == "en"
	end
end