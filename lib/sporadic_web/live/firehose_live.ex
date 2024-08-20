defmodule SporadicWeb.FirehoseLive do
  use SporadicWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :buffer, [])}
  end

  def render(assigns) do
    ~H"""
    <p>Boo</p>
    <div :for={entry <- @streams.buffer} id={entry[2]}>
      <%= entry |> Enum.join(", ") %>
    </div>
    """
  end

  def handle_info({:feed, entry}, socket) do
    {:noreply, socket |> stream_insert(:buffer, entry)}
  end

  def add_entry(entry) do
    IO.inspect(entry)
    send(self(), {:feed, entry})
  end
end
