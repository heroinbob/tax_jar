defmodule TaxJar.Test.Support.Requests do
  alias TaxJar.Test.Support.Fixtures

  def bad_request_response(conn) do
    build_response(
      conn,
      Fixtures.bad_request_response(),
      status: 400
    )
  end

  def ok_tax_response(conn), do: build_response(conn, Fixtures.tax_response())

  def build_response(conn, body, opts \\ []) do
    status = Keyword.get(opts, :status, 200)

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.resp(status, body)
  end
end
