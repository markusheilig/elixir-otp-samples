defmodule Worker do

  def start_link do
    spawn(fn -> loop() end)
  end

  defp loop do
    receive do
      :stop -> :ok
      msg ->
        IO.inspect msg
        loop()
    end
  end

end
