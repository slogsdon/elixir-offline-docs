defmodule OfflineDocs do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
    ]

    opts = [strategy: :one_for_one, name: OfflineDocs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def parse_dep({dep, constraint}) when constraint |> is_binary, do: parse_dep({dep, constraint, []})
  def parse_dep({dep, options}) when options |> is_list, do: parse_dep({dep, "", []})
  def parse_dep({dep, _contraint, options}) do
    if options[:only] == nil or options[:only] == env do
      [dep: dep]
    else
      nil
    end
  end

  def add_options(dependency) do
    dep = dependency[:dep]
    opts = default_opts
           |> Keyword.update!(:output, &(&1 <> "#{dep}"))
           |> Keyword.update!(:source_root, &(&1 <> "#{dep}"))
           |> Keyword.update!(:source_beam, &(&1 <> "#{env}/lib/#{dep}/ebin"))
    dependency
    |> Keyword.put(:opts, opts)
  end

  def generate_docs(dep) do
    try do
      ExDoc.generate_docs("#{dep[:dep]}", "", dep[:opts])
    rescue
      e in Earmark.HtmlRenderer.EarmarkError ->
        e.message
    end
  end

  def generate_index(deps) do
    links = deps
            |> Enum.map(fn dep ->
              "<a href=\"#{dep[:dep]}/index.html\">#{dep[:dep]}</a><br />"
            end)
            |> Enum.join("")
    File.write! "docs/index.html", [
      "<doctype html><html><body>",
      links,
      "</body></html>"
    ]
    deps
  end

  defp default_opts do
    [output:      "docs/",
     source_root: "deps/",
     source_beam: "_build/",
     homepage_url: "",
     main:        "overview"]
  end

  defp env do
    Mix.env
  end
end
