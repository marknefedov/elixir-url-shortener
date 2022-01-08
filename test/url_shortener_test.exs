defmodule UrlShortenerTest do
  use ExUnit.Case
  doctest UrlShortener

  test "greets the world" do
    assert UrlShortener.hello() == :world
  end
end
