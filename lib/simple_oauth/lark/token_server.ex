defmodule SimpleOAuth.Lark.TokenServer do
  use GenServer

  alias SimpleOAuth.Lark.Client

  # 提前 15 分钟过期
  @expires_before 900

  def app_access_token do
    GenServer.call(__MODULE__, :app_access_token)
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(config) do
    {:ok, %{config: config, cached: %{}}}
  end

  def handle_call(:app_access_token = key, _from, %{config: config} = state) do
    {app_access_token, new_state} =
      case read_from_cache(key, state) do
        nil ->
          {:ok, %{"app_access_token" => token, "expire" => expire}} =
            Client.app_access_token(config[:app_id], config[:app_secret])

          send_clear_signal(key, expire - @expires_before)
          {token, update_cache({key, token}, state)}

        token ->
          {token, state}
      end

    {:reply, {:ok, token}, Map.put(state, key, token)}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_state, state}, _from, _state) do
    {:reply, :ok, state}
  end

  def handle_info({:clear_cache, key}, state) do
    new_state = %{state | cached: Map.delete(state.cached, key)}
    {:noreply, new_state}
  end

  defp read_from_cache(key, state), do: state.cached[key]

  defp update_cache({key, value}, state) do
    %{state | cached: Map.put(state.cached, key, value)}
  end

  defp send_clear_signal(key, expires_in) do
    Process.send_after(__MODULE__, {:clear_cache, key}, expires_in * 1000)
  end
end
