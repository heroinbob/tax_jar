defmodule TaxJar.MixProject do
  use Mix.Project

  def project do
    [
      app: :tax_jar,
      deps: deps(),
      description: "Simple Elixir library for interacting with the TaxJar API",
      dialyzer: [
        list_unused_filters: true,
        plt_file: {:no_warn, "plts/tax_jar.plt"},
        # Be sure that ex_unit is included. This is needed when CI runs it in
        # the test ENV.
        plt_add_apps: [:ex_unit]
      ],
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      start_permanent: Mix.env() == :prod,
      version: "0.2.0"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      # This is only explicitly used in tests. However Hexpm
      # requires it in production.
      {:jason, "~> 1.4.1"},
      {:req, "~> 0.4.0", optional: true},

      # Dev Deps
      {:bypass, "~> 2.1.0", only: :test},
      {:credo, "~> 1.7.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31.1", only: :dev, runtime: false},
      {:hammox, "~> 0.7", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/heroinbob/tax_jar"},
      maintainers: ["Jeff McKenzie"]
    ]
  end
end
