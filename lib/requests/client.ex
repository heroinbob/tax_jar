defmodule TaxJar.Requests.Client do
  @moduledoc """
  HTTP Client for the TaxJar API.

  ## Configuration

  The following are relied on to make calls to the TaxJar API.

  - `:api_key` - Must be a valid TaxJar API auth key for your account.
  - `:api_url` - (Optional) If you want to override the default url for the current env.
  - `:api_version` - Must be a valid TaxJar API version. Default is `"2022-01-24"`.
  """

  alias TaxJar.Requests.Error

  @doc """
  Perform a POST request to the API using the given payload.

  When successful the response body will be decoded into a map which is returned.

  ## Options
  Options are passed to `:hackney.request/5`.
  """
  @spec post(binary(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def post(path, body, opts \\ []) when is_map(body) do
    request("post", path, body, opts)
  end

  @doc """
  Perform an HTTP request using the given method, path and body. Options are passed directly
  to `:hackney.request/5`.
  """
  @spec request(binary(), binary(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def request(method, path, body, opts \\ []) do
    # TODO: emit telemetry
    case :hackney.request(
           method,
           build_url(path),
           headers(),
           Jason.encode!(body),
           [:with_body] ++ opts
         ) do
      {:ok, 200, _headers, response} ->
        {:ok, Jason.decode!(response)}

      {:ok, status_code, _headers, response} ->
        {:error, Error.new(response, status_code)}

      {:error, reason} ->
        {:error, Error.new(reason)}
    end
  end

  defp build_url(path), do: TaxJar.get_api_url() <> path

  defp headers do
    [
      {"Authorization", "Bearer #{TaxJar.get_api_key()}"},
      {"Content-Type", "application/json"},
      {"x-api-version", TaxJar.get_api_version()}
    ]
  end
end
