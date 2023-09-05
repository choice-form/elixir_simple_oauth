defmodule SimpleOAuth.MixProject do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :simple_oauth,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      description: description(),
      source_url: github_url()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SimpleOAuth.Application, []}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"Github" => github_url()}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17", optional: true},
      {:jason, "~> 1.0"}
    ]
  end

  defp github_url do
    "https://github.com/choice-form/es_oauth.git"
  end

  defp description do
    "Implement the most popular login requirements."
  end

  defp docs do
    [
      main: "readme",
      source_url: github_url(),
      source_ref: "v#{@version}",
      extras: ["README.md", "LICENSE"]
    ]
  end
end
