defmodule Derivcotest.FootballMatches do
  @moduledoc """
  This modules is responsable for data modeling
  @columns has the names and order of columns from the data file

  Data is imported into a in-memory ets table named 'games`
  I removed the ID column because it had no relevance

  The first approach for this was using mnesia module as storage,
  but there were problems sometimes, as I didn't how to use it yet
  so I switched to file import method where you can filter and
  group by any fields.

  But this is not a good approach and switched back to build-in storage,
  :ets, which is simpler to use but does not have the power of mnesia
  for machine-to-machine communication

  This is not the fastest, not best pattern matched structure,
  but it fits the purpose of the data, as it does not require
  update or removing and does not have to be stored in a database

  A note:
  I didn't know if season should be left as it is or transfermed into
  full year to year, eg. 2016-2016. At first groups were returned
  by the formated season, but I decided to exclude this as it would be a frontend decision
  """
  require Logger
  require IEx

  alias Derivcotest.Messages

  @columns [:division,:season,:date,:home_team,:away_team,:fthg,:ftah,:ftr,:hthg,:htag,:htr]

  def import do
    :ets.new(:games, [:named_table, :duplicate_bag, :public])
    [_ | data] = read_rows()
    :ets.insert(:games, Enum.map(data, &List.to_tuple/1))
    Logger.info("Data was successfully imported.")
  end

  @doc """
  Filter rows by divison and season
  Build the structure for each row and "group_by" params requested
  Group them by division or season or both
  """
  @spec get(Map.t()) :: [Map.t()]
  def get(opts) do
    filter(opts)
      |> Enum.map(&build_row/1)
      |> grouper(opts)
  end

  def get_proto(opts) do
    data = get(opts)
      |> to_proto_response

    {:ok, data}
  end

  defp build_row(row) do
    Enum.into(
      Enum.zip(@columns, Tuple.to_list(row)),
      %{}
    )
  end

  @doc """
  Filter rows which contain selected params data
  ex. Season: 201517
  """
  @spec filter(Map.t()) :: [Tuple.t()]
  def filter(%{"division" => division}) do
    :ets.match_object(:games, {division,:_, :_,:_,:_, :_,:_,:_,:_,:_,:_})
  end
  def filter(%{"season" => season}) do
    :ets.match_object(:games, {:_,season,:_,:_,:_,:_,:_,:_,:_,:_,:_})
  end
  def filter(%{"division" => division, "season" => season}) do
    :ets.match_object(:games, {division,season,:_,:_,:_,:_,:_,:_,:_,:_,:_})
  end
  def filter(%{}) do
    :ets.match_object(:games, {:_,:_,:_,:_,:_,:_,:_,:_,:_,:_,:_})
  end

  @spec grouper([List.t()], Map.t()) :: [Tuple.t()]
  def grouper(rows, opts) do
    case Map.get(opts, "group_by") do
      ["division"] ->
        Enum.group_by(rows, fn %{:division => division} -> division end)
      ["season"] ->
        Enum.group_by(rows, fn %{:season => season} -> season end)
      ["season", "divison"] ->
        Enum.group_by(rows, fn %{:division => division, :season => season} -> "#{season} #{division}" end)
      ["division", "season"] ->
        Enum.group_by(rows, fn %{:division => division, :season => season} -> "#{division} #{season}" end)
      _ -> rows
    end
  end

  @spec to_proto_response(%{ String.t() => List.t() }) :: binary
  defp to_proto_response(groups) when is_map(groups) do
    groups = Enum.map(groups, fn {name, games} ->
      Messages.GroupMatches.new(%{
        name: name,
        list: games_to_proto(games)
      })
    end)

    Messages.GroupResponse.encode(
      Messages.GroupResponse.new(%{
        groups: groups
      })
    )
  end

  @spec to_proto_response([Map.t()]) :: binary
  defp to_proto_response(rows) when is_list(rows) do
    Messages.Response.encode(games_to_proto(rows))
  end

  defp games_to_proto(rows) do
    Messages.Response.new(%{
      games: rows |> Enum.map(&Messages.FootballMatch.new/1)
    })
  end

  # @spec get(Map.t(), [String.t()]) :: [Map.t()]
  # def get(params, group_by) do
  #   map_rows()
  #     |> filter(params)
  #     |> group(group_by)
  # end

  # @doc """
  # Filter rows which contain selected params data
  # ex. Season: 201517
  # """
  # @spec filter(rows :: [Map], params :: Map) :: [map]
  # def filter(rows, %{}), do: rows
  # def filter(rows, params) do
  #   rows
  #     |> Enum.filter(fn row ->
  #         Enum.filter(params, fn {key, val} -> row[key] == val end)
  #           |> Enum.count == Enum.count(params)
  #        end)
  # end

  # @doc """

  # """
  # @spec group(rows :: [Map], group :: [String]) :: [map]
  # def group(rows, []), do: rows
  # def group(rows, grouper) do
  #   rows
  #   |> Enum.group_by(fn row ->
  #       grouper
  #         |> Enum.map(&Map.get(row, &1))
  #         |> Enum.join(" ")
  #      end)
  # end

  # defp format_season(ses) do
  #   <<fyear::binary-size(4), syear::binary>> = ses
  #   "#{fyear}-20#{syear}"
  # end

  @doc """
    Here we open data file and read footbal matches rows
    Remove the Windows newline, id column and header row
    Then save it to the mnesia table for easier match
  """
  def map_rows do
    [headers | data] = read_rows()
    data
      |> Enum.map(fn (row) ->
        Enum.zip(headers, row) |> Enum.into(%{})
      end)
  end

  def read_rows do
    File.read!("data/matches.csv")
      |> String.split("\n")
      |> Enum.map(&String.replace(&1, "\r", ""))
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(fn
        [_ | cols] -> cols
      end)
      |> Enum.filter(fn
        [] -> false
        _ ->true
      end)
  end
end
