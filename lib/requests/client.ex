defmodule TaxJar.Requests.Client do
  @moduledoc """
  - describe default api api_version
  - describe sandbox is default mode
  - :api_key is a required config value
  - requests raise errors when json can't encode/decode.
  """

  alias TaxJar.Requests.Error

  @doc """
  Perform a POST request to the API using the given payload.

  When successful the response body will be decoded into a map which is returned.

  ## Options
  Options are passed to `:hackney.request/5`.
  """
  def post(path, body, opts \\ []) when is_map(body) do
    request("post", path, body, opts)
  end

  def request(method, path, body, opts \\ []) do
    # TODO: emit telemetry
    try do
      :hackney.request(
        method,
        build_url(path),
        headers(),
        Jason.encode!(body),
        [:with_body] ++ opts
      )
    catch
      kind, reason ->
        :erlang.raise(kind, reason, __STACKTRACE__)
    else
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
