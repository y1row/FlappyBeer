defmodule FlappyBeer.PlayerState do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def put(user, x, y, velocity, rotation) do
    Agent.update(__MODULE__, fn scores ->
      case Enum.find(scores, fn data -> data.user === user end) do
        nil ->
          [%{user: user, x: x, y: y, velocity: velocity, rotation: rotation} | scores]
        _ ->
          [%{user: user, x: x, y: y, velocity: velocity, rotation: rotation} |
            Enum.reject(scores, fn data -> data.user === user end)]
      end
    end)

    get
  end

  def get(n \\ 100) do
    case n do
      :all -> Agent.get(__MODULE__, fn enum -> enum end)
      _    -> Agent.get(__MODULE__, fn enum -> enum end) |> Enum.take(n)
    end
  end
end
