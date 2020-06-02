defmodule SmoodleWeb.Router do
  use SmoodleWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(SmoodleWeb.Plugs.Locale, use_session: false)
    plug(:accepts, ["json"])
  end

  scope "/v1", SmoodleWeb do
    pipe_through(:api)

    resources "/events", EventController, except: [:new, :edit] do
      resources("/polls", PollController, only: [:create, :index])
    end

    get("/events/:id/schedule", EventController, :schedule)

    resources("/polls", PollController, only: [:update, :delete, :show])
  end

  if Application.get_env(:smoodle, Smoodle.Mailer)[:adapter] == Bamboo.LocalAdapter do
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end

  scope "/", SmoodleWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/events/:event_id", PageController, :event)
    get("/*path", PageController, :app)
  end

  # Other scopes may use custom stacks.
  # scope "/api", SmoodleWeb do
  #   pipe_through :api
  # end
end
