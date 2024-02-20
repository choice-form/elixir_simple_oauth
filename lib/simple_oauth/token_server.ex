defmodule SimpleOAuth.TokenServer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get(provider, key, fetcher) do
    GenServer.call(__MODULE__, {:get, provider, key, fetcher})
  end

  # for test
  def state(state \\ nil) do
    if state do
      GenServer.call(__MODULE__, {:set_state, state})
    else
      GenServer.call(__MODULE__, :get_state)
    end
  end

  def init(_args) do
    {:ok, [], {:continue, nil}}
  end

  def handle_continue(_arg, _state) do
    new_state = mod().sync_from_other_nodes()

    {:noreply, new_state}
  end

  def handle_call(signal, _from, state) when signal in [:get_state, :sync] do
    {:reply, state, state}
  end

  def handle_call({:set_state, state}, _from, _state) do
    {:reply, :ok, state}
  end

  def handle_call({:get, provider, key, fetcher}, _from, state) do
    state =
      case state do
        [] -> mod().sync_from_other_nodes()
        _ -> state
      end

    case mod().get_record(provider, key, state) do
      {:ok, nil} ->
        {returning, new_state} =
          case mod().fetch_and_broadcast_cache(fetcher) do
            {:ok, record} ->
              new_state = mod().update_record_if_needed(record, state)
              {{:ok, record.value}, new_state}

            {:error, _} = err ->
              {err, state}
          end

        {:reply, returning, new_state}

      {:ok, record, seconds} ->
        mod().renew_record_in(record, seconds)
        {:reply, {:ok, record.value}, state}

      {:ok, record} ->
        {:reply, {:ok, record.value}, state}
    end
  end

  def handle_call({:set, record}, _from, state) do
    new_state = mod().update_record_if_needed(record, state)
    {:reply, :ok, new_state}
  end

  def handle_info({:renew, record}, state) do
    new_state =
      case mod().fetch_and_broadcast_cache(record) do
        {:ok, record} ->
          mod().update_record_if_needed(record, state)

        {:error, _} ->
          mod().renew_record_in_1_minute(record)
          state
      end

    {:noreply, new_state}
  end

  defp mod do
    if Application.get_env(:simple_oauth, :distributed, false) do
      SimpleOAuth.TokenServer.Context
    else
      SimpleOAuth.TokenServer.IsolateContext
    end
  end
end
