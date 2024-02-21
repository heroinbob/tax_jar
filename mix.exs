defmodule TaxJar.MixProject do
  use Mix.Project

  def project do
    [
      app: :tax_jar,
      deps: deps(),
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
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
      {:bypass, "~> 2.1.0", only: :test},
      {:dialyxir, "~> 1.4.1", only: [:dev, :test], runtime: false},
      {:hackney, "~> 1.20.1"},
      {:jason, "~> 1.4.1"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
