defmodule SimpleOAuth.Lark.TokenServer do
  use GenServer

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(config) do
    {:ok, %{config: config}}
  end
end
