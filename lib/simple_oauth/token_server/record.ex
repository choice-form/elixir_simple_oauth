defmodule SimpleOAuth.TokenServer.Record do
  @enforce_keys [:provider, :key, :value]
  defstruct [:provider, :key, :value, :expires_in, :updated_at]

  # 提前 20 分钟进入即将失效状态，需要安排延迟刷新
  @expiring_interval 1200

  def new(params) do
    {:ok, hlc} = HLClock.now(SimpleOAuth.HLClock)
    params = Map.put(params, :updated_at, hlc)
    struct(__MODULE__, params)
  end

  def expiring_status(%__MODULE__{expires_in: nil}), do: :valid

  def expiring_status(%__MODULE__{expires_in: expires_in} = record) do
    expired_at =
      record.updated_at.time
      |> DateTime.from_unix!(:millisecond)
      |> DateTime.add(expires_in)

    expiring_at = DateTime.add(expired_at, -@expiring_interval)

    now = DateTime.utc_now()

    cond do
      DateTime.compare(now, expired_at) == :gt -> :expired
      DateTime.compare(now, expiring_at) == :gt -> {:expiring, DateTime.diff(expired_at, now)}
      true -> :valid
    end
  end
end
