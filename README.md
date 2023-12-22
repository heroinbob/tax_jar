# TaxJar

A simple Elixir library for interacting with the [TaxJar API](https://developers.taxjar.com/api/reference/).

## Installation

Once published you can install by adding `tax_jar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tax_jar, "~> 0.1.0"}
  ]
end
```

For now you must add the git repository to your  `mix.exs` dependencies:

```elixir

def deps do
  [
    {:tax_jar, git: "https://github.com/heroinbob/tax_jar.git"}
  ]
end
```

Once published, the docs can be found at <https://hexdocs.pm/tax_jar>.
