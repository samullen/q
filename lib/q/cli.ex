defmodule Q.CLI do
  @qrc_path Path.expand(Application.get_env(:q, :qrc_path))

  def main(argv) do
    argv
    |> parse_args
    |> parse_config
    |> process
  end

  def parse_args(argv) do
    options = OptionParser.parse(argv, switches: [help: :boolean],
                                       aliases:  [h: :help])

    case options do
      {[help: true], _, _} -> :help
      {_, [], _}           -> :list
      {_, item, _}         -> {:add, item}
      _                    -> :help
    end
  end

  def parse_config(:help), do: :help
  def parse_config(:list) do 
    {:list, do_parse_config(@qrc_path, File.exists?(@qrc_path))}
  end
  def parse_config({:add, item}) do
    {:add, item, do_parse_config(@qrc_path, File.exists?(@qrc_path))}
  end

  def process(:help) do
    IO.puts """
      usage: q [string ...]
    """
  end

  def process({:list, filepath}) do
    case File.read(filepath) do
      {:ok, data} -> IO.write data
      {:error, error} -> IO.puts "Error: #{:file.format_error(error)}"
    end
  end

  def process({:add, argv, filepath}) do
    File.write(filepath, Enum.join(argv, " ") <> "\n", [:append])
  end

  defp do_parse_config(path, true) do
    {:ok, results} = ConfigParser.parse_file(path)
    results["default"]["qrc_path"]
  end
  defp do_parse_config(path, false) do
    content = "[default]\nqrc_path = ~/queue.txt\n"

    case File.write(path, content) do
      :ok -> 
        do_parse_config(path, true)

      {:error, message} -> 
        IO.puts(:stderr, message) && System.halt(2)
    end
  end
end
