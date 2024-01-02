defmodule TaxJar.Test.Support.Fixtures do
  @tax_response ~s(
    {
      "tax": {
        "order_total_amount": 10.0,
        "shipping": 0.0,
        "taxable_amount": 10.0,
        "amount_to_collect": 0.5,
        "rate": 0.05,
        "has_nexus": true,
        "freight_taxable": true,
        "tax_source": "destination",
        "jurisdictions": {
          "country": "US",
          "state": "CA",
          "county": "LOS ANGELES",
          "city": "LOS ANGELES"
        }
      }
    }
  )

  @tax_payload Jason.decode!(@tax_response)

  @bad_request_response ~s(
    {
      "error": "Bad Request",
      "detail": "No amount or line items provided",
      "status": 400
    }
  )

  @bad_request_payload Jason.decode!(@bad_request_response)

  # They return an HTML page on a 404 {:ok, 404, headers, ""}
  # test "returns :not_found when server responds with 404"

  @not_acceptable_response ~s(
    {
      "error": "Not Acceptable",
      "detail": "shipping is missing",
      "status": "406"
    }
  )

  def bad_request_payload, do: @bad_request_payload
  def bad_request_response, do: @bad_request_response
  def not_acceptable_response, do: @not_acceptable_response
  def tax_payload, do: @tax_payload
  def tax_response, do: @tax_response
end
