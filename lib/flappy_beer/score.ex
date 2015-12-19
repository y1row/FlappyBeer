defmodule FlappyBeer.Score do

  require Logger

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def put(user, score) do
    Agent.update(__MODULE__, fn scores ->
      case Enum.find(scores, fn data -> data.user === user end) do
        %{user: _u, score: s} when score > s ->
          [%{user: user, score: score} |
            Enum.reject(scores, fn data -> data.user === user end)]
        nil ->
          [%{user: user, score: score} | scores]
        _ ->
          scores
      end
    end)
  end

  def get_highscore(n \\ 100) do
    case n do
      :all -> Agent.get(__MODULE__, fn enum -> enum end)
      _    -> Agent.get(__MODULE__, fn enum -> enum end) |> Enum.take(n)
    end
  end
end
