defmodule TaxJar.Requests do
  @moduledoc false
  defdelegate get_sales_tax_for_order(params), to: TaxJar.Requests.Taxes
end
