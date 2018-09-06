defmodule Smoodle.Mailer do
	use Bamboo.Mailer, otp_app: :smoodle
	require Logger

	@cache :mailer_cache
	@mails_per_bucket 30
	@bucket_duration 3600*1000 # 1 hour in msec

	@doc """

	"""
	@spec deliver_with_rate_limit(email :: %Bamboo.Email{}, cache_key :: String.t()) :: tuple() | atom()
	def deliver_with_rate_limit(%Bamboo.Email{} = email, cache_key) do
		{:ok, counter} = Cachex.incr(@cache, cache_key)
		if counter == 1 do
			Cachex.expire(@cache, cache_key, @bucket_duration)
		end

		if counter > @mails_per_bucket do
			:error
		else
			{:ok, deliver_later(email)}
		end
	end
end