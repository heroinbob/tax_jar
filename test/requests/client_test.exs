defmodule TaxJar.Requests.ClientTest do
  use ExUnit.Case
  use TaxJar.Test.Support.HTTPCase

  alias TaxJar.Requests.Client
  alias TaxJar.Requests.Error

  describe "post/3" do
    test "executes a POST request and returns the response", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        fn conn ->
          assert "POST" == conn.method
          assert "/cool_path" == conn.request_path
          assert {:ok, body, _conn} = Plug.Conn.read_body(conn)
          assert body == ~s({"my":"payload"})

          ok_tax_response(conn)
        end
      )

      with_config(
        %{api_url: "localhost:#{bypass.port}"},
        fn ->
          assert {:ok, tax} = Client.post("/cool_path", %{"my" => "payload"})
          assert tax == Fixtures.tax_payload()
        end
      )
    end
  end

  describe "request/4" do
    test "executes the request returns the decoded JSON response", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        fn conn ->
          assert {"x-api-version", "2022-01-24"} in conn.req_headers
          assert {"authorization", "Bearer test-key"} in conn.req_headers
          assert {"content-type", "application/json"} in conn.req_headers
          assert "GET" == conn.method
          assert "/cool_path" == conn.request_path
          assert {:ok, body, _conn} = Plug.Conn.read_body(conn)
          assert body == ~s({"my":"payload"})

          ok_tax_response(conn)
        end
      )

      with_config(
        %{api_url: "localhost:#{bypass.port}"},
        fn ->
          assert {:ok, %{} = tax} = Client.request("GET", "/cool_path", %{"my" => "payload"})
          assert tax == Fixtures.tax_payload()
        end
      )
    end

    test "raises an exception when the response can't be decoded", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        fn conn -> build_response(conn, "whoops") end
      )

      assert_raise(
        Jason.DecodeError,
        fn ->
          with_config(
            %{api_url: "localhost:#{bypass.port}"},
            fn ->
              Client.post("/test", %{"my" => "payload"})
            end
          )
        end
      )
    end

    test "returns supported errors", %{bypass: bypass} do
      # These are the documented api responses.
      for {expected_status, expected_error} <- [
            {400, :bad_request},
            {401, :unauthorized},
            {403, :forbidden},
            {404, :not_found},
            {405, :method_not_allowed},
            {406, :not_acceptable},
            {410, :gone},
            {422, :unprocessable_entity},
            {429, :too_many_requests},
            {500, :internal_server_error},
            {503, :service_unavailable},
            {504, :gateway_timeout}
          ] do
        Bypass.expect_once(
          bypass,
          &build_response(&1, ~s({"error": "oops"}), status: expected_status)
        )

        with_config(
          %{api_url: "localhost:#{bypass.port}"},
          fn ->
            assert {
                     :error,
                     %Error{reason: reason, status: status}
                   } =
                     Client.post("/test", %{"my" => "payload"})

            assert status == expected_status
            assert reason == expected_error
          end
        )
      end
    end

    test "returns the connection error", %{bypass: bypass} do
      Bypass.down(bypass)

      with_config(
        %{api_url: "localhost:#{bypass.port}"},
        fn ->
          assert {
                   :error,
                   %Error{reason: :econnrefused}
                 } = Client.post("/test", %{"my" => "payload"})
        end
      )

      on_exit(fn -> Bypass.up(bypass) end)
    end
  end
end
