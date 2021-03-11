defmodule SmoodleWeb.Email do
  use Bamboo.Phoenix, view: SmoodleWeb.EmailView
  import SmoodleWeb.Gettext

  @from_address "noreply@lets-meet.app"

  def new_event_email(event) do
    new_email()
    |> to(event.email)
    |> from({gettext("Your LetsMeet! Bot"), @from_address})
    |> subject(gettext("Your new event: %{event_name}", event_name: event.name))
    |> assign(:owner_link, SmoodleWeb.EventController.owner_link(event))
    |> assign(:share_link, SmoodleWeb.EventController.share_link(event))
    |> assign(:event_organizer, event.organizer)
    |> assign(:event_name, event.name)
    |> render("new_event.html")
  end
end
