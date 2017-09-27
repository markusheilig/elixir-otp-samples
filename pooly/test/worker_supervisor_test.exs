defmodule SampleRun do
  use ExUnit.Case

  test "children are restarted automatically" do
    {:ok, sup} = Pooly.WorkerSupervisor.start_link({Pooly.SampleWorker,
                                                    :start_link, []})
    {:ok, _} = Supervisor.start_child(sup, [[]])
    {:ok, _} = Supervisor.start_child(sup, [[]])
    {:ok, worker3} = Supervisor.start_child(sup, [[]])
    old_pids = get_child_pids(sup)
    Pooly.SampleWorker.stop(worker3)
    new_pids = get_child_pids(sup)
    assert old_pids != new_pids
  end

  def get_child_pids(supervisor) do
    Supervisor.which_children(supervisor) |> Enum.map(fn {_,pid,_,_} -> pid end)
  end

end
