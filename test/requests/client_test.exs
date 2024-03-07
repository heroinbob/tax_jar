defmodule TaxJar.Requests.ClientTest do
  use TaxJar.Test.Support.HTTPCase

  alias TaxJar.Requests.Client

  defmodule OtherHTTPAdapter do
    @behaviour TaxJar.Requests.HTTPBehaviour

    @impl TaxJar.Requests.HTTPBehaviour
    def post(path, body, opts) do
      {:ok, %{body: body, opts: opts, path: path}}
    end
  end

  describe "post/2" do
    test "delegates to the configured HTTP adapter and returns the response" do
      expect(
        MockHTTPAdapter,
        :post,
        fn path, body, opts ->
          assert path == "/cool_path"
          assert body == %{"my" => "payload"}
          assert opts == []

          {:ok, %{rad: "stuff"}}
        end
      )

      assert {:ok, %{rad: "stuff"}} = Client.post("/cool_path", %{"my" => "payload"})
    end

    test "the http adapter can be configured at runtime" do
      with_config(
        %{http_adapter: OtherHTTPAdapter},
        fn ->
          assert {
                   :ok,
                   %{
                     body: %{"my" => "payload"},
                     opts: [compress_body: true],
                     path: "/cool_path"
                   }
                 } = Client.post("/cool_path", %{"my" => "payload"}, compress_body: true)
        end
      )
    end
  end

  describe "post/3" do
    test "passes the options to the http adapter" do
      expect(
        MockHTTPAdapter,
        :post,
        fn _path, _body, opts ->
          assert opts == [compressed: true]

          {:ok, %{rad: "stuff"}}
        end
      )

      assert {:ok, %{rad: "stuff"}} =
               Client.post(
                 "/cool_path",
                 %{"my" => "payload"},
                 compressed: true
               )
    end
  end
end
