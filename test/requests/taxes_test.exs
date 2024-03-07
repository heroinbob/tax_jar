defmodule TaxJar.Requests.TaxesTest do
  use TaxJar.Test.Support.HTTPCase

  alias TaxJar.Requests.Error
  alias TaxJar.Requests.Taxes

  @tax_payload Fixtures.tax_payload()

  setup :verify_on_exit!

  describe "get_sales_tax_for_order/1" do
    test "POSTs to the taxes endpoint and returns the taxes" do
      expect(
        MockHTTPAdapter,
        :post,
        fn path, body, opts ->
          assert path == "/taxes"
          assert body == %{"my" => "order"}
          assert opts == []

          {:ok, @tax_payload}
        end
      )

      %{"tax" => expected_payload} = @tax_payload

      assert {:ok, %{} = tax} = Taxes.get_sales_tax_for_order(%{"my" => "order"})
      assert tax == expected_payload
    end

    test "returns the error when the request fails" do
      expect(
        MockHTTPAdapter,
        :post,
        fn _path, _body, _opts ->
          {:error, Error.exception(reason: :bad_request)}
        end
      )

      assert {:error, %Error{reason: :bad_request}} =
               Taxes.get_sales_tax_for_order(%{"my" => "order"})
    end
  end
end
