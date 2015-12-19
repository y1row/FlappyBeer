defmodule FlappyBeer.RoomChannel do
  use FlappyBeer.Web, :channel

  def join("rooms:lobby", %{"name" => name}, socket) do
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
    FlappyBeer.Score.put(user, body)
    broadcast! socket, "put_score", %{user: user, body: body}
    {:noreply, socket}
  end

  def handle_in("update_state", %{"body" => body}, socket) do
    user = FlappyBeer.LoginUser.user(socket.channel_pid)
    FlappyBeer.Message.add(user, body)
    broadcast! socket, "new_msg", %{user: user, body: body}
    {:noreply, socket}
  end

end
