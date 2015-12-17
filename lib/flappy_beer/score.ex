defmodule FlappyBeer.Score do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def put(user, score) do
    Agent.get_and_update(__MODULE__, fn enum ->
      Enum.find(enum, fn {u, s} -> u === user end) |> update_score(score)
    end)
  end

  def update_score({user, score}, new_score) when new_score > score do
    {user, new_score}
  end

  def update_score({user, score}, _new_score) do
    {user, score}
  end

  def get_highscore(n \\ 100) do
    case n do
      :all -> Agent.get(__MODULE__, fn enum -> enum end)
      _    -> Agent.get(__MODULE__, fn enum -> enum end) |> Enum.take(n)
    end
  end
end
