defmodule Personalfin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Personalfin.Repo,
      # Start the Telemetry supervisor
      PersonalfinWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Personalfin.PubSub},
      # Start the Endpoint (http/https)
      PersonalfinWeb.Endpoint,
      # Start a worker by calling: Personalfin.Worker.start_link(arg)
      # {Personalfin.Worker, arg}
      {ConCache,
       [
         name: :api,
         ttl_check_interval: :timer.seconds(3600),
         global_ttl: :timer.seconds(86_400)
       ]},
      Personalfin.Periodically
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Personalfin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PersonalfinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
