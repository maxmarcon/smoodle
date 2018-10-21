defmodule Smoodle.MailerTest do
  use ExUnit.Case
  use Bamboo.Test

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
    assert_delivered_email(email)

    assert {:ok, ttl} = Cachex.ttl(cache_name(), email.to)
    assert ttl <= time_bucket_msec()
  end

  test "mailer sends only up to the maximum number of emails in the bucket and sends again after the cache key as expired" do
    for n <- 0..(max_emails() - 1) do
      email = %Bamboo.Email{
        to: "to@google.com",
        from: "from@google.com",
        subject: "nothing #{n}"
      }

      assert {:ok, _} = deliver_with_rate_limit(email, email.to)
      assert_delivered_email(email)
    end

    email = %Bamboo.Email{
      to: "to@google.com",
      from: "from@google.com",
      subject: "nothing #{max_emails() + 1}"
    }

    assert {:error, :rate_limit_exceeded} = deliver_with_rate_limit(email, email.to)
    refute_delivered_email(email)

    Smoodle.Mailer.reset_counters()

    email = %Bamboo.Email{
      to: "to@google.com",
      from: "from@google.com",
      subject: "nothing #{max_emails() + 2}"
    }

    assert {:ok, _} = deliver_with_rate_limit(email, email.to)
    assert_delivered_email(email)
  end
end
