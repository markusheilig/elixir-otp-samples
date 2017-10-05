defmodule WorkerSupervisorTest do
  use ExUnit.Case

  test "children are restarted automatically" do
    {:ok, sup} = Pooly.WorkerSupervisor.start_link({SampleWorker, :start_link, []})
    {:ok, _} = Supervisor.start_child(sup, [[]])
    {:ok, _} = Supervisor.start_child(sup, [[]])
    {:ok, worker_pid} = Supervisor.start_child(sup, [[]])
    :ok = SampleWorker.stop(worker_pid)
    %{workers: count} = Supervisor.count_children(sup)
    assert count == 3
    worker_pids =
      Supervisor.which_children(sup)
      |> Enum.map(fn {_, pid, _, _} -> pid end)
    assert worker_pid not in worker_pids
  end
end
