defmodule CliTest do
  use ExUnit.Case
  doctest Q

  import Q.CLI, only: [parse_args: 1]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test ":list returned if no arguments provided" do
    assert parse_args([]) == :list
  end

  test ":add returned if arguments provided" do
    assert parse_args(~w{this is a test}) == {:add, ~w{this is a test}}
  end
end
