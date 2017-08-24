defmodule OpenWeatherMapTest do
  use ExUnit.Case
  doctest OpenWeatherMap

  test "greets the world" do
    assert OpenWeatherMap.hello() == :world
  end
end
