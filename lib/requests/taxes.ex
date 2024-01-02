defmodule TaxJar.Requests.Taxes do
  alias TaxJar.Requests.Client

  @doc """
  Request the sales tax for the given order.

  https://developers.taxjar.com/api/reference/#post-calculate-sales-tax-for-an-order
  """
  def get_sales_tax_for_order(payload) when is_map(payload) do
    Client.post("/taxes", payload)
  end
end
