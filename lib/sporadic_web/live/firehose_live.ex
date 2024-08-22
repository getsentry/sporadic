defmodule SporadicWeb.FirehoseLive do
  use SporadicWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(Sporadic.PubSub, "firehose")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen w-screen" id="map_container">
      <svg class="h-full w-full" id="map_svg" phx-hook="DrawMap"></svg>
    </div>
    """
  end

  def handle_info({:feed, entry}, socket) do
    {:noreply, socket |> push_event(:feed, entry)}
  end
end
