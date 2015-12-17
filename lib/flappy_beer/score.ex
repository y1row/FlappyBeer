defmodule FlappyBeer.Score do

  require Logger

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def put(user, score) do
    Agent.get_and_update(__MODULE__, fn enum ->
      case Enum.find(enum, fn {u, s}, sc -> u === user end) do
        true -> update_score(enum, score)
        nil -> update_score({user, 0}, score)
      end
    end)
  end

  def update_score({user, score}, new_score) when new_score > score do
    Logger.debug("score updated. user : #{user}, score : #{new_score}")
    {user, new_score}
  end

  def update_score({user, score}, _new_score) do
    Logger.debug("score updated. user : #{user}, score : #{score}")
    {user, score}
  end

  def get_highscore(n \\ 100) do
    case n do
      :all -> Agent.get(__MODULE__, fn enum -> enum end)
      _    -> Agent.get(__MODULE__, fn enum -> enum end) |> Enum.take(n)
    end
  end
end
