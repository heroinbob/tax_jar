defmodule TaxJar.Requests.Error do
  # https://developers.taxjar.com/api/reference/#errors
  @statuses %{
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

  def statuses, do: @statuses

  defstruct [
    :message,
    :reason,
    :status,
    decoded_response: :none,
    response: :none
  ]

  # Hackney will return a reason - usually an atom. However it's spec is `term()`.
  def new(reason) do
    %__MODULE__{
      decoded_response: :none,
      message: "Connection error",
      reason: reason,
      response: :none
    }
  end

  def new(response, status) when is_binary(response) do
    attrs =
      response
      |> Jason.decode()
      |> build_attrs(response, status)

    struct(__MODULE__, attrs)
  end

  defp build_attrs({:ok, decoded_response}, raw_response, status) do
    # The "error" attr in the response is usually a human readable title which is
    # not needed since we can translate the code. If we can't translate it for
    # some reason like the consumer is using a proxy and returns other http statuses
    # or the API changes/misbehaves then they can rely on the `status` from the response.
    %{
      decoded_response: decoded_response,
      message: Map.get(decoded_response, "detail"),
      reason: Map.get(@statuses, status, :unknown),
      response: raw_response,
      status: status
    }
  end

  defp build_attrs(_error, raw_response, status) do
    %{
      message: "The response could not be decoded.",
      reason: :invalid_json,
      response: raw_response,
      status: status
    }
  end
end
