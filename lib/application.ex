defmodule UrlShortener.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    IO.puts("Starting app")

    children = [
      {Mongo,
       [
         name: :mongo,
         url: "mongo_url",
         pool_size: 4
       ]},
      {Plug.Cowboy, scheme: :http, plug: UrlShortener.Router, port: 3030}
      # Starts a worker by calling: UrlShortener.Worker.start_link(arg)
      # {UrlShortener.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UrlShortener.Supervisor]
    IO.puts("Linking supervisor")
    Supervisor.start_link(children, opts)
  end
end
