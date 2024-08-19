defmodule Sporadic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SporadicWeb.Telemetry,
      # Sporadic.Repo,
      {DNSCluster, query: Application.get_env(:sporadic, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sporadic.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Sporadic.Finch},
      # Start a worker by calling: Sporadic.Worker.start_link(arg)
      # {Sporadic.Worker, arg},
      # Start to serve requests, typically the last entry
      SporadicWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sporadic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SporadicWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
