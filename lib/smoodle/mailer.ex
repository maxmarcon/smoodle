defmodule Smoodle.Mailer do
  use Bamboo.Mailer, otp_app: :smoodle
  require Logger

  @cache :mailer
  @default_time_bucket_sec 3600
  @default_max_emails 10

  def get_config, do: Application.get_env(:smoodle, __MODULE__)

  def reset_counters do
    {:ok, _} = Cachex.reset(cache())
  end

  def max_emails, do: get_in(get_config(), [:rate_limit, :max_emails]) || @default_max_emails

  def time_bucket_msec,
    do: 1000 * (get_in(get_config(), [:rate_limit, :time_bucket_sec]) || @default_time_bucket_sec)

  def cache, do: @cache

  @doc """

  """
  @spec deliver_with_rate_limit(email :: %Bamboo.Email{}, cache_key :: String.t) ::
          tuple() | atom()
  def deliver_with_rate_limit(%Bamboo.Email{} = email, cache_key) do
    {:ok, counter} = Cachex.incr(cache(), cache_key)

    if counter == 1 do
      {:ok, _} = Cachex.expire(cache(), cache_key, time_bucket_msec())
    end

    if counter > max_emails() do
      Logger.info("Rate limit of #{max_emails()} emails exceeded for key #{cache_key}")
      {:error, :rate_limit_exceeded}
    else
      {:ok, deliver_later(email)}
    end
  end
end
