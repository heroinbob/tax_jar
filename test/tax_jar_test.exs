defmodule TaxJarTest do
  use TaxJar.Test.Support.HTTPCase

  describe "get_api_key/0" do
    test "returns the configured API key" do
      assert TaxJar.get_api_key() == "test-key"
    end

    test "raises an error when there is none defined" do
      Application.delete_env(:tax_jar, :api_key)

      assert_raise ArgumentError, fn -> TaxJar.get_api_key() end

      on_exit(fn -> TaxJar.put_env(:api_key, "test-key") end)
    end
  end

  describe "get_api_url/0" do
    test "returns the sandbox url when mode is not defined" do
      assert TaxJar.get_api_url() == "https://api.sandbox.taxjar.com/v2"
    end

    test "returns the sandbox url when in sandbox mode" do
      with_config(
        %{mode: :sandbox},
        fn -> assert TaxJar.get_api_url() == "https://api.sandbox.taxjar.com/v2" end
      )
    end

    test "returns the prod url when in production mode" do
      with_config(
        %{mode: :production},
        fn -> assert TaxJar.get_api_url() == "https://api.taxjar.com/v2" end
      )
    end
  end

  describe "get_api_version/0" do
    test "returns 2022-01-24 by default" do
      assert TaxJar.get_api_version() == "2022-01-24"
    end

    test "returns the configured API version" do
      with_config(
        %{api_version: "9999-09-09"},
        fn -> assert TaxJar.get_api_version() == "9999-09-09" end
      )
    end
  end

  describe "get_mode/0" do
    test "returns :sandbox by default" do
      assert TaxJar.get_mode() == :sandbox
    end

    test "returns :production when configured" do
      with_config(
        %{mode: :production},
        fn -> assert TaxJar.get_mode() == :production end
      )
    end

    test "raises an error when value is not supported" do
      assert_raise(
        ArgumentError,
        "invalid mode :foo: must be :sandbox or :production",
        fn ->
          with_config(
            %{mode: :foo},
            fn -> assert TaxJar.get_mode() == :production end
          )
        end
      )
    end
  end

  describe "get_tax_rates_for_order/1" do
    setup :verify_on_exit!

    test "delegates to TaxJar.Requests.Taxes" do
      expect(
        MockHTTPAdapter,
        :post,
        fn _, _, _ -> {:ok, Fixtures.tax_payload()} end
      )

      assert {
               :ok,
               %{
                 "order_total_amount" => 10.0,
                 "shipping" => +0.0,
                 "taxable_amount" => 10.0,
                 "amount_to_collect" => 0.5,
                 "rate" => 0.05,
                 "has_nexus" => true,
                 "freight_taxable" => true,
                 "tax_source" => "destination",
                 "jurisdictions" => %{
                   "country" => "US",
                   "state" => "CA",
                   "county" => "LOS ANGELES",
                   "city" => "LOS ANGELES"
                 }
               }
             } = TaxJar.get_sales_tax_for_order(%{"my" => "order"})
    end
  end
end
