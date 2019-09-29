defmodule Derivcotest.Router do
  use Plug.Router
  alias Derivcotest.FootballMatches

  @moduledoc """
  ## GET /api/games
  Endpoint for footbal matches which accept filters and groupers in query params.
  Both features implemented only for "division" and "season" columns.

  This endpoint does return an array, when filters are present and an object
  when "group_by" is present.

  ex. GET /api/games?division=SP1&season=201617
  Return a JSON array only with games from the SP1 division in the 2016-2017 season

    [{ "home_team": ..., }, { "home_team": ..., }]

  ex. GET/api/games?group_by=division
  Return JSON object with games grouped by country division

    { "SP1" : [...], "SP2": [...] }


  ## GET /proto/games
  This endpoint return a Protocol Buffer response
  """

  plug(Plug.Logger, log: :debug)
  plug(Plug.Parsers, parsers: [:urlencode])
  plug(:match)
  plug(:dispatch)

  get "/api/games" do
    filters =
      case conn.params do
        %{"group_by" => group_by} ->
          %{ conn.params |
            "group_by" => group_by
              |> String.downcase
              |> String.split(",", trim: true)
          }
        params -> params
      end

    with {:ok, data} <- FootballMatches.get(filters) |> Poison.encode do
      send_resp(conn, 200, data)
    else
      {:error, message} ->
        IO.inspect(message)
        send_resp(conn, 500, "Bad things happens")
    end
  end

  get "/proto/games" do
    filters =
      case conn.params do
        %{"group_by" => group_by} ->
          %{ conn.params |
            "group_by" => group_by
              |> String.downcase
              |> String.split(",", trim: true)
          }
        params -> params
      end

    {:ok, data} =
      FootballMatches.get_proto(filters)

    send_resp(conn, 200, data)
  end

  match _ do
    send_resp(conn, 404, "there is nothing else here")
  end
end
