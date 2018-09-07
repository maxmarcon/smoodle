defmodule Smoodle.MailerTest do

	use ExUnit.Case
	import Smoodle.Mailer

	setup do
		reset_counters()
		:ok
	end

	test "mailer sends email and set ttl" do
		email = %Bamboo.Email{
			to: "to@google.com",
			from: "from@google.com",
			subject: "nothing"
		}
		assert {:ok, _} = deliver_with_rate_limit(email, email.to)

		assert {:ok, ttl} = Cachex.ttl(cache_name, email.to)
		assert ttl <= time_bucket_msec
	end

	test "mailer sends up to the number of emails" do
		email = %Bamboo.Email{
			to: "to@google.com",
			from: "from@google.com",
			subject: "nothing"
		}

		for _ <- 0..max_emails-1 do
			assert {:ok, _} = deliver_with_rate_limit(email, email.to)
		end
	end

	test "mailer can send again after key is expired" do
		email = %Bamboo.Email{
			to: "to@google.com",
			from: "from@google.com",
			subject: "nothing"
		}

		for _ <- 0..max_emails-1 do
			assert {:ok, _} = deliver_with_rate_limit(email, email.to)
		end
		assert :error = deliver_with_rate_limit(email, email.to)

		Cachex.expire(:mailer_cache, email.to, -1)

		assert {:ok, _} = deliver_with_rate_limit(email, email.to)
	end
end