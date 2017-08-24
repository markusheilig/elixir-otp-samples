defmodule OpenWeatherMap.Worker do
    use GenServer

    def start_link(opts \\ []) do
        GenServer.start(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        {:ok, %{}}
    end

    def get_temparature(pid, location) do
        GenServer.call(pid, {:location, location})
    end

    def handle_call({:location, location}, _from, stats) do
        case temparature_of(location) do
            {:ok, temp} -> 
                new_status = update_status(stats, location)                
                {:reply, "#{temp}°C", new_status}
            _ ->
                {:reply, :error, stats}
        end
    end

    defp temparature_of(location) do
        url_for(location) |> HTTPoison.get |> parse_response    
    end

    defp url_for(location) do         
        apikey = "TODO: INSERT API KEY"
        "http://api.openweathermap.org/data/2.5/weather?q=#{location}&APPID=#{apikey}" 
    end

    defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
        body |> JSON.decode! |> compute_temparature
    end

    defp parse_response(_), do: :error

    defp compute_temparature(json) do
        try do            
            temp = json["main"]["temp"] |> to_grad_celsius |> Float.round(1)
            {:ok, temp}
        rescue
            _ -> :error
        end
    end

    defp to_grad_celsius(kelvin), do: kelvin - 273.15

    defp update_status(old_stats, location) do
        case Map.has_key?(old_stats, location) do            
            true -> Map.update!(old_stats, location, &(&1 + 1))
            false -> Map.put_new(old_stats, location, 1)
        end
    end

end