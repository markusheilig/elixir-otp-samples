defmodule Sample do

  @default_spec {Worker, :start_link, []}

  def sample() do
    {:ok, supervisor} = ThySupervisor.start_link()
    {:ok, child1} = ThySupervisor.start_child(supervisor, @default_spec)
    {:ok, 1} = ThySupervisor.count_children(supervisor)
    {:ok, child2} = ThySupervisor.start_child(supervisor, @default_spec)
    {:ok, 2} = ThySupervisor.count_children(supervisor)
    {:ok, _} = ThySupervisor.which_children(supervisor)
    :ok = ThySupervisor.terminate_child(supervisor, child1)
    {:ok, 1} = ThySupervisor.count_children(supervisor)
    {:ok, child2} = ThySupervisor.restart_child(supervisor, child2)
    {:ok, 1} = ThySupervisor.count_children(supervisor)
    :ok = ThySupervisor.terminate_child(supervisor, child2)
    {:ok, 0} = ThySupervisor.count_children(supervisor)
  end

end
