defmodule TaxJar.Requests.HTTPBehaviour do
  @moduledoc """
  Behaviour to define an HTTP adapter for the TaxJar API.
  """
  alias TaxJar.Requests.Error

  @doc """
  Perform an HTTP POST request to the given path with the given body.

  The options should be utilized to the configured adapter so that one can specify
  additional configuration like timeouts, headers, etc.
  """
  @callback post(
              path :: binary(),
              body :: map(),
              opts :: keyword()
            ) :: {:ok, map()} | {:error, Error.t()}
end
