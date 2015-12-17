defmodule FlappyBeer.PlayerState do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def set(user, x, y, velocity, rotation) do
    Agent.cast(__MODULE__, fn enum -> [{user, body}|enum] end)

    Agent.get_and_update(__MODULE__, fn enum ->
      case Enum.any?(enum, fn {_pid, u} -> u === user end) do
        true -> {:error, enum}
        false -> {:ok, [{pid, name}|enum]}
      end
    end)
  end

  def get(n \\ 100) do
    case n do
      :all -> Agent.get(__MODULE__, fn enum -> enum end)
      _    -> Agent.get(__MODULE__, fn enum -> enum end) |> Enum.take(n)
    end
  end
end
