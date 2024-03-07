defmodule TaxJar.Requests.Error do
  @moduledoc """
  Exception to represent errors during communication with the TaxJar API.
  """

  @type t :: %__MODULE__{
          details: term(),
          message: binary() | nil,
          reason: term()
        }

  # These can be used to lookup a useful reason to provide in the error
  # instead of the integer status code.
  # https://developers.taxjar.com/api/reference/#errors
  @statuses_lookup %{
    400 => :bad_request,
    401 => :unauthorized,
    403 => :forbidden,
    404 => :not_found,
    405 => :method_not_allowed,
    406 => :not_acceptable,
    410 => :gone,
    422 => :unprocessable_entity,
    429 => :too_many_requests,
    500 => :internal_server_error,
    503 => :service_unavailable,
    504 => :gateway_timeout
  }

  def statuses_lookup, do: @statuses_lookup

  defexception [
    :details,
    :message,
    :reason
  ]
end
