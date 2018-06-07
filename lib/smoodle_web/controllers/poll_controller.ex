defmodule SmoodleWeb.PollController do
  use SmoodleWeb, :controller

  alias Smoodle.Scheduler
  alias Smoodle.Scheduler.Event
  alias Smoodle.Scheduler.Poll
  action_fallback SmoodleWeb.FallbackController

end