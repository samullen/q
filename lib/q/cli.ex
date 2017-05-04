defmodule Q.CLI do
  @qpath Application.get_env(:q, :path)

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    options = OptionParser.parse(argv, switches: [help: :boolean],
                                       aliases:  [h: :help])

    case options do
      {[help: true], _, _} 
        -> :help

      {_, [], _} 
        -> :list

      {_, argv, _} 
        -> {:add, argv}

      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
      usage: q [string ...]
    """
  end

  def process(:list) do
    case File.read(@qpath) do
      {:ok, data} -> IO.write data
      {:error, error} -> IO.puts "Error: #{:file.format_error(error)}"
    end
  end

  def process({:add, argv}) do
    File.write(@qpath, Enum.join(argv, " ") <> "\n", [:append])
  end
end
