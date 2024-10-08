defmodule Sporadic.Firehose do
  use GenServer
  alias Phoenix.PubSub

  @frequency_ms 10
  @platforms [:ruby, :python, :javascript]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    generate_data()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, :rand.uniform(@frequency_ms))
  end

  defp generate_data do
    entry = %{
      latitude: (:rand.uniform() * 180 - 90) |> Float.round(3),
      longitude: (:rand.uniform() * 360 - 180) |> Float.round(3),
      time: :os.system_time(:millisecond),
      platform: Enum.random(@platforms)
    }

    PubSub.broadcast(Sporadic.PubSub, "firehose", {:feed, entry})
  end
end
