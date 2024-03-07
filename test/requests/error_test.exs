defmodule TaxJar.Requests.ErrorTest do
  use ExUnit.Case

  alias TaxJar.Requests.Error

  describe "exception/1" do
    test "returns an exception with the given values" do
      assert %Error{
               details: :foo,
               message: "Timeout",
               reason: :timeout
             } =
               error =
               Error.exception(
                 details: :foo,
                 message: "Timeout",
                 reason: :timeout
               )

      assert is_exception(error)
    end
  end
end
