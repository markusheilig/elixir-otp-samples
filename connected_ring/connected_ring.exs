defmodule ConnectedRing do

  def create_processes(n) do
    1..n |> Enum.map(fn _ -> spawn(fn -> ConnectedRing.loop end) end)
  end

  def loop do
    receive do
      {:link, to} when is_pid(to) ->
        Process.link(to)
        loop()
      :crash -> 1/0 # we want the process to crash
    end
  end

  def link(processes), do: _link(processes, [])

  defp _link([process1, process2 | tail], linked_processes) do
    send(process1, {:link, process2})
    _link([process2 | tail], [process1 | linked_processes])
  end

  defp _link([process | _tail], linked_processes) do
    last_process = linked_processes |> List.last
    send(process, {:link, last_process})
    :ok
  end

  def sample() do
    processes = create_processes 10
    :ok = link(processes)
    random_process = processes |> Enum.shuffle |> List.first
    IO.puts (processes |> state)
    send(random_process, :crash)
    :timer.sleep(500)
    IO.puts (processes |> state)
  end

  def state(processes) do
    processes |> Enum.map(&("#{inspect &1} alive? #{Process.alive?(&1)}\n"))
  end

end
