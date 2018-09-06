defmodule Smoodle.Mailer do
	use Bamboo.Mailer, otp_app: :smoodle
	require Logger

	@cache :mailer_cache

	@doc """

	"""
	@spec deliver_with_rate_limit(email :: %Bamboo.Email{}, cache_key :: String.t()) :: tuple() | atom()
	def deliver_with_rate_limit(%Bamboo.Email{} = email, cache_key) do
		{max_emails, bucket_duration} = Application.get_env(:smoodle, __MODULE__)[:rate_limit]

		{:ok, counter} = Cachex.incr(@cache, cache_key)
		if counter == 1 do
			Cachex.expire(@cache, cache_key, bucket_duration*1000)
		end

		if counter > max_emails do
			:error
		else
			{:ok, deliver_later(email)}
		end
	end
end