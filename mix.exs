defmodule Freshen.MixProject do
  use Mix.Project

  @version "0.1.0"

  @description "Searcher for the RT site"
  @repo_url "https://github.com/at88mph/freshen.git"

  def project do
    [
      app: :freshen,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      package: hex_package(),
      description: @description,

      # Docs
      name: "freshen",
      docs: [
        source_ref: "v#{@version}",
        main: "Freshen",
        source_url: @repo_url
      ]
    ]
  end

  def hex_package do
    [
      maintainers: ["Dustin Jenkins"],
      licenses: ["GNU General Public License v3.0"],
      links: %{"GitHub" => @repo_url},
      files: ~w(lib mix.exs *.md)
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2.2"},
      {:floki, "~> 0.32.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
