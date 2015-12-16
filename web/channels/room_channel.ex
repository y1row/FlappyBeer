defmodule FlappyBeer.RoomChannel do
  use FlappyBeer.Web, :channel

  def join("rooms:lobby", %{"name" => name}, socket) do
    case FlappyBeer.LoginUser.login(socket.channel_pid, name) do
      :ok ->
        messages = FlappyBeer.Message.get
          |> Enum.map(fn {user, body} -> %{user: user, body: body} end)
            {:ok, %{messages: messages}, socket}
      :error ->
        {:error, %{}}
    end
  end

  def terminate(_reason, socket) do
    FlappyBeer.LoginUser.logout(socket.channel_pid)
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    user = FlappyBeer.LoginUser.user(socket.channel_pid)
    FlappyBeer.Message.add(user, body)
    broadcast! socket, "new_msg", %{user: user, body: body}
    {:noreply, socket}
  end
end
