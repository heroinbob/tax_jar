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

## Configuration

You'll need to configure the API auth key and possibly the API version depending on what you want to use.

```elixir
config :tax_jar,
    api_key: "YOUR_API_KEY",
    api_version: "2024-01-22",
    mode: :production
```
