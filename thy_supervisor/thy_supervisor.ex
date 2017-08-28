defmodule ThySupervisor do
  use GenServer

  # API

  def start_link(child_spec_list \\ []) do
    GenServer.start_link(__MODULE__, [child_spec_list])
  end

  def start_child(supervisor, child_spec) do
    GenServer.call(supervisor, {:start_child, child_spec})
  end

  def terminate_child(supervisor, pid) when is_pid(pid) do
    GenServer.call(supervisor, {:terminate_child, pid})
  end

  def restart_child(supervisor, pid) when is_pid(pid) do
    GenServer.call(supervisor, {:restart_child, pid})
  end

  def count_children(supervisor) do
    GenServer.call(supervisor, :count_children)
  end

  def which_children(supervisor) do
    GenServer.call(supervisor, :which_children)
  end

  # callbacks

  def init([child_spec_list]) do
    Process.flag(:trap_exit, true)
    state = child_spec_list
              |> start_children
              |> Enum.into(%{})
    {:ok, state}
  end

  def handle_call({:start_child, child_spec}, _from, state) do
    case start_child(child_spec) do
      {:ok, pid} ->
        new_state = state |> Map.put(pid, child_spec)
        {:reply, {:ok, pid}, new_state}
      :error ->
        {:reply, {:error, "error starting child"}, state}
    end
  end

  def handle_call({:terminate_child, pid}, _from, state) do
      case terminate_child(pid) do
        :ok ->
          new_state = state |> Map.delete(pid)
          {:reply, :ok, new_state}
        :error ->
          {:reply, :error, state}
      end
  end

  def handle_call(:count_children, _from, state) do
    count = state |> Kernel.map_size
    {:reply, {:ok, count}, state}
  end

  def handle_call(:which_children, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call({:restart_child, pid}, _from, state) do
    with {:ok, child_spec} <- Map.fetch(state, pid),
         {:ok, new_pid} <- do_restart_child(pid, child_spec)
    do
      new_state = state
                    |> Map.delete(pid)
                    |> Map.put(new_pid, child_spec)
      {:reply, {:ok, new_pid}, new_state}
    else
      err -> IO.inspect "error is #{err}"
      {:reply, {:error, "could not restart child"}, state}
    end

  end

  def handle_info({:EXIT, from, :normal}, state) do
    new_state = Map.delete(state, from)
    {:noreply, new_state}
  end

  def handle_info({:EXIT, from, :killed}, state) do
    new_state = Map.delete(state, from)
    {:noreply, new_state}
  end

  def handle_info({:EXIT, from, _reason}, state) do
    with {:ok, child_spec} <- Map.fetch(state, from),
         {:ok, child} <- do_restart_child(from, child_spec)
    do
      new_state = state
                    |> Map.delete(from)
                    |> Map.put(child, child_spec)
      {:noreply, new_state}
    else
      _ -> {:noreply, state}
    end
  end

  # implementation

  defp start_children([child_spec | rest]) do
    case start_child(child_spec) do
      {:ok, pid} -> [{pid, child_spec}|start_children(rest)]
      _ -> :error
    end
  end

  defp start_children([]), do: []

  defp start_child(child_spec) do
    {module, fun, args} = child_spec
    case apply(module, fun, args) do
      child when is_pid(child) ->
        Process.link(child)
        {:ok, child}
      _ ->
        :error
    end
  end

  defp terminate_child(pid) do
    Process.exit(pid, :kill)
    :ok
  end

  defp do_restart_child(pid, child_spec) do
    with :ok <- terminate_child(pid),
         {:ok, child} <- start_child(child_spec)
    do
      {:ok, child}
    else
      err -> err
    end
  end

end
