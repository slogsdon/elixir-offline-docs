defmodule Mix.Tasks.Compile.OfflineDocs do
  @shortdoc "Compile ExDoc for all dependencies"
  @moduledoc """
  """
  def run(args) do
    File.mkdir("docs")
    Mix.Project.config
    |> Keyword.get(:deps)
    |> Enum.map(&OfflineDocs.parse_dep/1)
    |> Enum.filter(&(&1 != nil))
    |> Enum.map(&OfflineDocs.add_options/1)
    |> OfflineDocs.generate_index
    |> Enum.map(&OfflineDocs.generate_docs/1)
  end
end
