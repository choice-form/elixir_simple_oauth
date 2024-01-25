defmodule SimpleOAuth.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: SimpleOAuth.Worker.start_link(arg)
      # {SimpleOAuth.Worker, arg}
      SimpleOAuth.TokenServer,
      {HLClock, name: SimpleOAuth.HLClock}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimpleOAuth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
