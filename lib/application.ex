defmodule UrlShortener.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    mongo_url = Application.fetch_env!(:url_shortener, :mongo_string)
    IO.puts(inspect(mongo_url))

    children = [
      {Mongo,
       [
         name: :mongo,
         url: mongo_url,
         pool_size: 2
       ]},
      {Plug.Cowboy, scheme: :http, plug: UrlShortener.Router, port: 3030}

      # Starts a worker by calling: UrlShortener.Worker.start_link(arg)
      # {UrlShortener.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UrlShortener.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
