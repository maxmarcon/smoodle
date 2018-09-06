defmodule Smoodle.MailerTest do

	use ExUnit.Case
	import Smoodle.Mailer

	setup do
		Cachex.reset(:mailer_cache)
		{max_emails, bucket_duration} = Application.get_env(:smoodle, Smoodle.Mailer)[:rate_limit]
		[max_emails: max_emails, bucket_duration: bucket_duration]
	end

	test "mailer sends email" do
		email = %Bamboo.Email{
			to: "to@google.com",
			from: "from@google.com",
			subject: "nothing"
		}
		assert {:ok, _} = deliver_with_rate_limit(email, email.to)
	end

	test "mailer sends up to the number of emails", %{max_emails: max_emails} do
		email = %Bamboo.Email{
			to: "to@google.com",
			from: "from@google.com",
			subject: "nothing"
		}

		for _ <- 0..max_emails-1 do
			assert {:ok, _} = deliver_with_rate_limit(email, email.to)
		end
	end

	test "mailer can send again after key is expired", %{max_emails: max_emails} do
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