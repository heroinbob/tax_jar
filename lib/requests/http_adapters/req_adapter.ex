defmodule TaxJar.Requests.HTTPAdapters.ReqAdapter do
  @moduledoc """
  An HTTP adapter using the `Req` library. See [the Hex docs](https://hexdocs.pm/req)
  for more information on it's features.
  """
  @behaviour TaxJar.Requests.HTTPBehaviour

  alias TaxJar.Requests.Error

  @statuses_lookup TaxJar.Requests.Error.statuses_lookup()

  @doc """
  Perform a POST request to the API using the Req library.

  ## Options

  The given options are passed to `Req.post/2`. See [the Req docs](https://hexdocs.pm/req/Req.html#new/1)
  for all of the available options and what they do.

  The following default options are provided (but can be overriden):

  - `auth`: The configured `:api_key` is used.
  - `base_url`: The configured `:api_url` is used.
  - `headers`: The default headers contain the configured `:api_version`.
  - `json`: The given `body` is encoded as JSON.

  ## Errors

  When a request is not successful a `TaxJar.Requests.Error` is returned.

  ### When the API returns an error

  The error fields will be as follows:

  - `:details`: The `Req.Response` struct received as the response.
  - `:message`: The error message as defined in the API. Default is `"Request failed"`.
  - `:reason`: An atom representing the status code. See `TaxJar.Requests.Error.statuses_lookup`.
               Default is `:api_error` if the status is outside what the API supports.
  """
  @impl TaxJar.Requests.HTTPBehaviour
  def post(path, body, opts \\ []) when is_map(body) do
    opts = merge_opts(opts, body)

    case Req.post(path, opts) do
      {:ok, %Req.Response{status: 200, body: tax}} ->
        {:ok, tax}

      {:ok, %Req.Response{status: status, body: body} = response} ->
        {
          :error,
          Error.exception(
            details: response,
            message: Map.get(body, "detail", "Request failed"),
            reason: Map.get(@statuses_lookup, status, :api_error)
          )
        }

      # Mint.HTTPError and Mint.TransportError only have one public field.
      # In any case this will work for any exception that exposes :reason.
      {:error, %{reason: reason} = exception} when is_exception(exception) ->
        {
          :error,
          Error.exception(
            message: Exception.message(exception),
            reason: reason
          )
        }
    end
  end

  defp merge_opts(opts, body) do
    headers =
      Enum.uniq(
        [{"x-api-version", TaxJar.get_api_version()}] ++
          Keyword.get(opts, :headers, [])
      )

    Keyword.merge(
      [
        auth: {:bearer, TaxJar.get_api_key()},
        base_url: TaxJar.get_api_url(),
        headers: headers,
        json: body
      ],
      opts
    )
  end
end
