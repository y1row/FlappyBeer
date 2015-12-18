defmodule FlappyBeer.Score do

  require Logger

  def start_link do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def put(user, score) do
    Agent.update(__MODULE__, fn dict ->
      update_score(dict, user, dict[user], score)
    end)
  end

  def update_score(dict, user, now_score, new_score) when now_score == nil do
    Logger.debug("score updated. user : #{user}, score : #{new_score}")
    Dict.put(dict, user, new_score)
  end

  def update_score(dict, user, now_score, new_score) when now_score < new_score do
    Logger.debug("score updated(highscore). user : #{user}, score : #{new_score}")
    Dict.put(dict, user, new_score)
  end

  def update_score(dict, user, _now_score, new_score) do
    Logger.debug("score not updated. user : #{user}, score : #{new_score}")
    dict
  end

  def get_highscore(n \\ 100) do
    case n do
      :all -> Agent.get(__MODULE__, fn enum -> enum end)
      _    -> Agent.get(__MODULE__, fn enum -> enum end) |> Enum.take(n)
    end
  end
end
