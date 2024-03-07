defmodule TaxJar.Requests.Taxes do
  alias TaxJar.Requests.Client
  alias TaxJar.Requests.Error

  @doc """
  Request sales tax for the given order.

  The API response is a map with the tax liability wrapped in a map with a single
  key `"tax"`. This returns the content without the wrapper.

  See [Sales Tax API](https://developers.taxjar.com/api/reference/#post-calculate-sales-tax-for-an-order)
  for details.
  """
  @spec get_sales_tax_for_order(map()) :: {:ok, map()} | {:error, Error.t()}
  def get_sales_tax_for_order(payload) when is_map(payload) do
    case Client.post("/taxes", payload) do
      {:ok, %{"tax" => tax}} -> {:ok, tax}
      error -> error
    end
  end
end
