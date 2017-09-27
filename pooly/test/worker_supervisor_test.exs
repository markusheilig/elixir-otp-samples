defmodule WorkerSupervisorTest do
  use ExUnit.Case
  alias Pooly.{WorkerSupervisor, SampleWorker}

  test "children are restarted automatically" do
    {:ok, sup} = WorkerSupervisor.start_link({SampleWorker, :start_link, []})
    {:ok, _} = Supervisor.start_child(sup, [[]])
    {:ok, _} = Supervisor.start_child(sup, [[]])
    {:ok, worker_pid} = Supervisor.start_child(sup, [[]])
    SampleWorker.stop(worker_pid)
    %{workers: count} = Supervisor.count_children(sup)
    assert count == 3
    pids = Supervisor.which_children(sup) |> Enum.map(fn {_,pid,_,_} -> pid end)
    assert pids |> contains(worker_pid) == false
  end

  def contains([], _), do: false
  def contains([h|_], h), do: true
  def contains([_|t], x), do: contains(t, x)

end
