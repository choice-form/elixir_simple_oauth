defmodule SimpleOAuth.TokenServer.IsolateContext do
  alias SimpleOAuth.TokenServer.Record
  alias SimpleOAuth.TokenServer

  def sync_from_other_nodes, do: []

  def get_record(provider, key, state) do
    state
    |> Enum.find(&(&1.provider == provider and &1.key == key))
    |> then(fn
      nil -> nil
      record -> {Record.expiring_status(record), record}
    end)
    |> case do
      {:valid, %Record{} = record} -> {:ok, record}
      {{:expiring, expiring_seconds}, %Record{} = record} -> {:ok, record, expiring_seconds}
      _ -> {:ok, nil}
    end
  end

  def fetch_and_broadcast_cache(%Record{fetcher: fetcher}), do: fetch_and_broadcast_cache(fetcher)

  def fetch_and_broadcast_cache(fetcher) when is_function(fetcher), do: fetcher.()

  def update_record_if_needed(record, state) do
    case Enum.split_with(state, &(&1.provider == record.provider and &1.key == record.key)) do
      {[], _} -> [record | state]
      {[_old_record], remains} -> [record | remains]
    end
  end

  def renew_record_in_1_minute(record) do
    renew_record_in(record, 60)
  end

  def renew_record_in(record, seconds) do
    random_interval = Enum.random(1..seconds//3) * 1000
    Process.send_after(TokenServer, {:renew, record}, random_interval)
  end
end
