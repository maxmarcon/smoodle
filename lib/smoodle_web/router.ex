defmodule SmoodleWeb.Router do
  use SmoodleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SmoodleWeb.Plugs.Locale
  end

  pipeline :api do
    plug SmoodleWeb.Plugs.Locale, use_session: false
    plug :accepts, ["json"]
  end

  scope "/v1", SmoodleWeb do
    pipe_through :api

    resources "/events", EventController, except: [:new, :edit] do
      resources "/polls", PollController, only: [:create, :index]
    end

    get "/events/:id/schedule", EventController, :schedule

    resources "/polls", PollController, only: [:update, :delete, :show]
  end

  scope "/", SmoodleWeb do
    pipe_through :browser # Use the default browser stack

    get "/home", PageController, :home
    get "/events/new", PageController, :event_new
    get "/events/:event_id/edit", PageController, :event_edit
    get "/events/:event_id/polls/new", PageController, :poll
    get "/events/:event_id", PageController, :event
    get "/polls/:poll_id/edit", PageController, :poll
    get "/", PageController, :redirect_to_home
  end


  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.EmailPreviewPlug
  end

  # Other scopes may use custom stacks.
  # scope "/api", SmoodleWeb do
  #   pipe_through :api
  # end
end
