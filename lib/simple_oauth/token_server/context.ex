defmodule SimpleOAuth.TokenServer.Context do
  alias SimpleOAuth.TokenServer.Record
  alias SimpleOAuth.TokenServer

  # 从其他节点获取最新的记录
  def sync_from_other_nodes do
    {results, _} = GenServer.multi_call(remaining_nodes(), TokenServer, :sync)

    results
    |> Enum.map(fn {_node, value} -> value end)
    |> Enum.sort_by(&length/1, :desc)
    |> List.first([])
  end

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

  def fetch_and_broadcast_cache(fetcher) when is_function(fetcher) do
    case fetcher.() do
      {:ok, record} ->
        GenServer.multi_call(remaining_nodes(), TokenServer, {:set, record})
        {:ok, record}

      err ->
        err
    end
  end

  def update_record_if_needed(record, state) do
    case Enum.split_with(state, &(&1.provider == record.provider and &1.key == record.key)) do
      {[], _} ->
        HLClock.recv_timestamp(SimpleOAuth.HLClock, record.updated_at)
        [record | state]

      {[old_record], remains} ->
        if HLClock.before?(old_record.updated_at, record.updated_at) do
          HLClock.recv_timestamp(SimpleOAuth.HLClock, record.updated_at)
          [record | remains]
        else
          state
        end
    end
  end

  def renew_record_in_1_minute(record) do
    renew_record_in(record, 60)
  end

  def renew_record_in(record, seconds) do
    random_interval = Enum.random(1..seconds//3) * 1000
    Process.send_after(TokenServer, {:renew, record}, random_interval)
  end

  def remaining_nodes do
    Enum.filter(Node.list(), fn node ->
      name = Atom.to_string(node)

      case cluster_prefix() do
        prefixs when is_list(prefixs) ->
          Enum.any?(prefixs, &String.starts_with?(name, &1))

        prefix ->
          String.starts_with?(name, prefix)
      end
    end)
  end

  defp cluster_prefix do
    Application.get_env(:simple_oauth, :cluster_prefix, "")
  end
end
