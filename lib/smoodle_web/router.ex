defmodule SmoodleWeb.Router do
  use SmoodleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SmoodleWeb.Plugs.Locale, "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SmoodleWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :welcome
    get "/new_event", PageController, :new_event
    get "/poll", PageController, :poll
  end

  scope "/v1", SmoodleWeb do
    pipe_through :api

    resources "/events", EventController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  # scope "/api", SmoodleWeb do
  #   pipe_through :api
  # end
end
