defmodule SporadicWeb.FirehoseLive do
  use SporadicWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(Sporadic.PubSub, "firehose")
    {:ok, socket |> stream_configure(:buffer, dom_id: &"#{&1[:time]}") |> stream(:buffer, [])}
  end

  def render(assigns) do
    ~H"""
    <p>Boo</p>
    <table>
      <tbody id="firehose" phx-update="stream">
        <tr :for={{dom_id, entry} <- @streams.buffer} id={dom_id}>
          <td><%= entry[:latitude] %></td>
          <td><%= entry[:longitude] %></td>
          <td><%= entry[:time] %></td>
          <td><%= entry[:platform] %></td>
        </tr>
      </tbody>
    </table>
    """
  end

  def handle_info({:feed, entry}, socket) do
    {:noreply, socket |> stream_insert(:buffer, entry, limit: -10)}
  end
end
