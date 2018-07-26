defmodule SmoodleWeb.Email do
	use Bamboo.Phoenix, view: SmoodleWeb.EmailView
  import SmoodleWeb.Gettext

	@from_address {"Smoodle Team", "noreply@smoodle.com"}

	def new_event_email(event) do
		new_email()
		|> to({event.organizer, event.email})
		|> from(@from_address)
		|> subject(gettext("Your new event: %{event_name}", event_name: event.name))
		|> assign(:owner_link, SmoodleWeb.EventView.owner_link(event))
		|> assign(:event_name, event.name)
		|> render("new_event.html")
	end
end