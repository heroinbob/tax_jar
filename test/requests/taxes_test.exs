defmodule TaxJar.Requests.TaxesTest do
  use ExUnit.Case
  use TaxJar.Test.Support.HTTPCase

  alias TaxJar.Requests.Error
  alias TaxJar.Requests.Taxes

  describe "get_sales_tax_for_order/1" do
    test "returns a map with tax info", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        fn conn ->
          assert "POST" == conn.method
          assert "/taxes" == conn.request_path
          assert {:ok, body, _conn} = Plug.Conn.read_body(conn)
          assert body == ~s({"my":"order"})

          ok_tax_response(conn)
        end
      )

      %{"tax" => expected_payload} = Fixtures.tax_payload()

      with_config(
        %{api_url: "localhost:#{bypass.port}"},
        fn ->
          assert {:ok, %{} = tax} = Taxes.get_sales_tax_for_order(%{"my" => "order"})
          assert tax == expected_payload
        end
      )
    end

    test "returns the error when the request fails", %{bypass: bypass} do
      Bypass.expect_once(bypass, &bad_request_response/1)

      with_config(
        %{api_url: "localhost:#{bypass.port}"},
        fn ->
          assert {:error, %Error{reason: :bad_request}} =
                   Taxes.get_sales_tax_for_order(%{"my" => "order"})
        end
      )
    end
  end
end
