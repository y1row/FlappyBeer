defmodule FlappyBeer.RoomChannel do
  use FlappyBeer.Web, :channel
  #require Logger

  def join("rooms:score", %{"name" => name}, socket) do
    case FlappyBeer.LoginUser.login(socket.channel_pid, name) do
      :ok ->
        {:ok, FlappyBeer.Score.get_highscore, socket}
      :error ->
        {:error, %{}}
    end
  end

  def terminate(_reason, socket) do
    FlappyBeer.LoginUser.logout(socket.channel_pid)
  end

  def handle_in("put_score", %{"body" => body}, socket) do
    user = FlappyBeer.LoginUser.user(socket.channel_pid)

    case FlappyBeer.Score.put(user, body) do
      %{user: user, score: upd_score} when body == upd_score ->
        broadcast! socket, "put_score", %{user: user, body: body}
      _ ->
    end

    {:noreply, socket}
  end

  def handle_in("update_state", %{"x" => x, "y" => y, "velocity" => velocity, "rotation" => rotation}, socket) do
    user = FlappyBeer.LoginUser.user(socket.channel_pid)
    FlappyBeer.PlayerState.put(user, x, y, velocity, rotation)
    broadcast! socket, "update_state", %{user: user, x: x, y: y, velocity: velocity, rotation: rotation}

    #Logger.debug("state updated. user #{user}, x #{x}, y #{y}, velocity #{velocity}, rotation #{rotation}")
    {:noreply, socket}
  end

end
