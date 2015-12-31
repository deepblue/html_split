defmodule HtmlSplit do
  def main(args) do
    args
    |> parse_args
    |> process
  end

  def process([in: filename, size: size, out: out]) do
    IO.puts "split #{filename} into #{size} pieces"

    File.read!(filename)
    |> Floki.find("ol li")
    |> Enum.chunk(size)
    |> Enum.with_index
    |> Enum.each(&save(&1, out))
  end
  def process(_) do
    IO.puts "No arguments given"
  end

  defp save({list, index}, out) do
    filename = "#{out}_#{index+1}.html"
    IO.puts("Writing #{filename}")

    {:ok, fp} = File.open(filename, [:write])
    content = list |> Enum.map(&Floki.raw_html(&1)) |> Enum.join("\n\n")
    html = """
    <!DOCTYPE html>
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>Instapaper: Export</title>
    </head>
    <body>

    <h1>Unread</h1>
    <ol>

    #{content}

    </ol>

    </body>
    </html>
    """
    IO.binwrite(fp, html)
    File.close(fp)
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args, [switches: [size: :integer]])
    options
  end
end
