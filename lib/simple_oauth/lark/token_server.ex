defmodule SimpleOAuth.Lark.TokenServer do
  use GenServer

  alias SimpleOAuth.Lark.Client

  # 提前 15 分钟过期
  @expires_before 900

  def app_access_token(app_id, app_secret) do
    GenServer.call(__MODULE__, {:app_access_token, app_id, app_secret})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def set_state(state) do
    GenServer.call(__MODULE__, {:set_state, state})
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:app_access_token = key, app_id, app_secret}, _from, state) do
    token =
      case state[key] do
        nil ->
          {:ok, %{"app_access_token" => token, "expire" => expire}} =
            Client.app_access_token(app_id, app_secret)

          # NOTE 为了测试
          if state[:test_flag] do
            Process.send(__MODULE__, {key, expire - @expires_before}, [])
          end

          send_clear_signal(key, expire - @expires_before)
          token

        token ->
          token
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
    {:noreply, Map.delete(state, key)}
  end

  def handle_info({_key, _expires_in} = value, state) do
    {:noreply, Map.put(state, :test_signal, value)}
  end

  defp send_clear_signal(key, expires_in) do
    Process.send_after(__MODULE__, {:clear_cache, key}, expires_in * 1000)
  end
end
