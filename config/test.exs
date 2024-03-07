import Config

config :tax_jar,
  api_key: "test-key",
  http_adapter: TaxJar.Requests.HTTPAdapters.MockHTTPAdapter
