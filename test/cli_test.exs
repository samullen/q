defmodule CliTest do
  use ExUnit.Case
  doctest Q

  import Q.CLI, only: [parse_args: 1, parse_config: 1]

  describe "parse_args/1" do
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

  describe "parse_config/1" do
    test ":help is returned when :help is passed" do
      assert parse_config(:help) == :help
    end

    test "passing list returns {:list, path}" do
      assert parse_config(:list) == {:list, "test/fixtures/files/queue.txt"}
    end

    test "it creates a .qrc file in the configured qrc path if nonexistent" do
      qrc_path = Path.expand(Application.get_env(:q, :qrc_path))
      File.rename(qrc_path, "#{Path.dirname(qrc_path)}/.qrc_bak")

      parse_config(:list)
      assert File.exists?(qrc_path) == true

      File.rename("#{Path.dirname(qrc_path)}/.qrc_bak", qrc_path)
    end

    test "it sets defaults for created .qrc" do
      qrc_path = Path.expand(Application.get_env(:q, :qrc_path))
      File.rename(qrc_path, "#{Path.dirname(qrc_path)}/.qrc_bak")

      parse_config(:list)
      assert File.read(qrc_path) == {:ok, "[default]\nqrc_path = ~/queue.txt\n"}

      File.rename("#{Path.dirname(qrc_path)}/.qrc_bak", qrc_path)
    end
  end
end
