defmodule Derivcotest.App do
  use Application

  alias Derivcotest.FootballMatches
  alias Derivcotest.Router

  @doc """
  Import data once when application starts
  This makes the CSV accessbible from memory which is faster than reading from file
  Then start a cowboy server with Plug router for API
  """
  def start(_type, _args) do
    FootballMatches.import()

    # Start http server on 8000 port for games api
    children = [
      {
        Plug.Cowboy,
        scheme: :http,
        plug: Router,
        options: [port: Application.get_env(:derivcotest, :port, 8000)]
      }
    ]

    opts = [
      strategy: :one_for_one,
      name: Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
