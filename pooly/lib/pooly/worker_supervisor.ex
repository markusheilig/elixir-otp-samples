defmodule Pooly.WorkerSupervisor do
  use Supervisor

  # API
  def start_link({_, _, _} = mfa) do
    Supervisor.start_link __MODULE__, mfa
  end


  # Callbacks
  def init({m, f, a}) do
    # :permanent = worker is always to be restarted
    # f = function to start the worker
    worker_opts = [restart: :permanent, function: f]
    # create a list of child processes
    children = [worker(m, a, worker_opts)]
    # supervisor options, give up if there are more than
    # 5 restarts within 5 seconds
    opts = [strategy: :simple_one_for_one, max_restarts: 5, max_seconds: 5]
    # create child specification
    supervise children, opts
  end
end
