defmodule TaxJar.Requests.Client do
  @moduledoc """
  HTTP Client for the TaxJar API. This is the module to facilitate HTTP requests with
  the configured HTTP adapter.

  ## Configuration

  The following are relied on to make calls to the TaxJar API.

  - `:api_key` - Required. Must be a valid TaxJar API auth key for your account.
  - `:api_url` - Optional. If you want to override the default url for the current env.
  - `:api_version` - Optional. Must be a valid TaxJar API version. Default is `"2022-01-24"`.
  - `:http_adapter` - Optional. Must be a module that implements the `TaxJar.Requests.HTTPBehaviour` protocol.
                      Default is `TaxJar.Requests.HTTPAdapters.Req`. It is read at runtime so the
                      value can be changed on the fly.
  """
  @behaviour TaxJar.Requests.HTTPBehaviour

  @doc """
  Perform a POST request to the API using the given payload.

  When successful the response body will be decoded into a map which is returned.
  """
  @impl TaxJar.Requests.HTTPBehaviour
  def post(path, body, opts \\ []) when is_map(body) do
    http_adapter().post(path, body, opts)
  end

  defp http_adapter, do: Application.fetch_env!(:tax_jar, :http_adapter)
end
