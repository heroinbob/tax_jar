# TaxJar

A simple Elixir library for interacting with the [TaxJar API](https://developers.taxjar.com/api/reference/).

## Installation

You can install by adding `tax_jar` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tax_jar, "~> 0.3.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/tax_jar>.

## Configuration

You'll need to configure the API auth key and possibly the API version depending on what you want to use.

```elixir
config :tax_jar,
    api_key: "YOUR_API_KEY",
    api_version: "2024-01-22",
    mode: :production
```

## HTTP Adapters

This library provides the [Req](https://hexdocs.pm/req) library for the HTTP adapter if you decide to rely
on the optional `Req` dependency. However your project may require something different. Feel free to
implement your own adapter by using the `TaxJar.Requests.HTTPBehavior` and then configure it using the
`:http_adapter` key in your config.

```elixir
config :tax_jar, http_adapter: YourApp.HTTPAdapter
```
