defmodule TaxJar.Requests.HTTPAdapters.ReqAdapterTest do
  use ExUnit.Case

  import TaxJar.Test.Support.Context

  alias TaxJar.Requests.Error
  alias TaxJar.Requests.HTTPAdapters.ReqAdapter
  alias TaxJar.Test.Support.Fixtures

  @tax_payload Fixtures.tax_payload()

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  defp build_response(conn, body, opts \\ []) do
    status = Keyword.get(opts, :status, 200)

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.resp(status, body)
  end

  defp ok_tax_response(conn), do: build_response(conn, Fixtures.tax_response())

  describe "post/2" do
    test "executes a POST request and returns the decoded response", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        fn conn ->
          assert {"x-api-version", "2022-01-24"} in conn.req_headers
          assert {"authorization", "Bearer test-key"} in conn.req_headers
          assert {"content-type", "application/json"} in conn.req_headers
          assert "POST" == conn.method
          assert "/cool_path" == conn.request_path
          assert {:ok, body, _conn} = Plug.Conn.read_body(conn)
          assert body == ~s({"my":"payload"})

          ok_tax_response(conn)
        end
      )

      with_config(
        %{api_url: "http://localhost:#{bypass.port}"},
        fn ->
          assert {:ok, tax} = ReqAdapter.post("/cool_path", %{"my" => "payload"})
          assert tax == @tax_payload
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
            %{api_url: "http://localhost:#{bypass.port}"},
            fn -> ReqAdapter.post("/test", %{"my" => "payload"}) end
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
        # The payload mimics that of what's defined in the fixtures. See those!
        Bypass.expect_once(
          bypass,
          &build_response(
            &1,
            ~s({"error": "oops", "detail": "foo", "status": #{expected_status}}),
            status: expected_status
          )
        )

        with_config(
          %{api_url: "http://localhost:#{bypass.port}"},
          fn ->
            assert {
                     :error,
                     %Error{
                       details: %{response: %Req.Response{status: ^expected_status}},
                       message: "foo",
                       reason: ^expected_error
                     }
                   } =
                     ReqAdapter.post("/test", %{"my" => "payload"})
          end
        )
      end
    end

    test "returns unsupported errors", %{bypass: bypass} do
      # The payload mimics that of what's defined in the fixtures. See those!
      Bypass.expect_once(
        bypass,
        &build_response(
          &1,
          ~s({"error": "oops", "detail": "I'm a teapot", "status": 418}),
          status: 418
        )
      )

      with_config(
        %{api_url: "http://localhost:#{bypass.port}"},
        fn ->
          assert {
                   :error,
                   %Error{
                     details: %{response: %Req.Response{status: 418}},
                     message: "I'm a teapot",
                     reason: :api_error
                   }
                 } =
                   ReqAdapter.post("/test", %{"my" => "payload"})
        end
      )
    end

    test "returns the connection error", %{bypass: bypass} do
      Bypass.down(bypass)

      with_config(
        %{api_url: "http://localhost:#{bypass.port}"},
        fn ->
          assert {
                   :error,
                   %Error{message: "connection refused", reason: :econnrefused}
                 } = ReqAdapter.post("/test", %{"my" => "payload"})
        end
      )

      on_exit(fn -> Bypass.up(bypass) end)
    end
  end

  describe "post/3" do
    test "merges the given options and passes them to Req.post/2", %{bypass: bypass} do
      Bypass.expect_once(
        bypass,
        fn conn ->
          assert {"authorization", "Bearer test-key"} in conn.req_headers
          assert {"content-encoding", "gzip"} in conn.req_headers
          assert {"content-type", "application/json"} in conn.req_headers
          assert {"x-test", "foo"} in conn.req_headers
          # This wasn't given in the header value in options - so it won't be present.
          refute {"x-api-version", "2022-01-24"} in conn.req_headers
          # It should have cleared out the method option - this is a POST function!
          assert "POST" == conn.method
          assert "/cool_path" == conn.request_path
          assert {:ok, body, _conn} = Plug.Conn.read_body(conn)
          assert body == :zlib.gzip(~s({"my":"payload"}))

          ok_tax_response(conn)
        end
      )

      with_config(
        %{api_url: "http://localhost:#{bypass.port}"},
        fn ->
          assert {:ok, tax} =
                   ReqAdapter.post(
                     "/cool_path",
                     %{"my" => "payload"},
                     compress_body: true,
                     headers: [{"x-test", "foo"}]
                   )

          assert tax == @tax_payload
        end
      )
    end

    test "removes duplicate headers and when unique keeps the values from options", %{
      bypass: bypass
    } do
      Bypass.expect_once(
        bypass,
        fn conn ->
          assert Enum.count(
                   conn.req_headers,
                   fn {key, value} ->
                     key == "authorization" and value == "Bearer test-key"
                   end
                 ) == 1

          assert {"x-api-version", "2024-03-07"} in conn.req_headers
          refute {"x-api-version", "2022-01-24"} in conn.req_headers

          ok_tax_response(conn)
        end
      )

      with_config(
        %{api_url: "http://localhost:#{bypass.port}"},
        fn ->
          assert {:ok, tax} =
                   ReqAdapter.post(
                     "/cool_path",
                     %{"my" => "payload"},
                     headers: [
                       # Overrride the configured value that it puts in.
                       {"x-api-version", "2024-03-07"},
                       # Duplicate!
                       {"authorization", "Bearer test-key"}
                     ]
                   )

          assert tax == @tax_payload
        end
      )
    end
  end
end
