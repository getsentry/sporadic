defmodule Sporadic.Firehose do
  use GenServer

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
    Process.send_after(self(), :work, :rand.uniform(1000))
  end

  defp generate_data do
    entry = [
      (:rand.uniform() * 180 - 90) |> Float.round(3),
      (:rand.uniform() * 360 - 180) |> Float.round(3),
      :os.system_time(:millisecond),
      Enum.random(@platforms)
    ]

    SporadicWeb.FirehoseLive.add_entry(entry)
  end
end
