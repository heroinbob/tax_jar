defmodule TaxJar.Requests.ErrorTest do
  use ExUnit.Case, async: true

  alias TaxJar.Requests.Error
  alias TaxJar.Test.Support.Fixtures

  describe "new/1" do
    test "returns a struct with :reason populated" do
      assert %Error{
               decoded_response: :none,
               message: "Connection error",
               reason: :econnrefused,
               response: :none,
               status: :none
             } = Error.new(:econnrefused)
    end
  end

  describe "new/2" do
    test "returns the struct with data from the response" do
      response = Fixtures.bad_request_response()

      assert %Error{
               decoded_response: %{},
               message: "No amount or line items provided",
               reason: :bad_request,
               response: ^response,
               status: 400
             } = Error.new(response, 400)
    end

    test "returns a custom error when the json can't be decoded" do
      assert %Error{
        decoded_response: :none,
        message: "blah",
        reason: :invalid_json,
        response: "not json",
        status: 400
      }

      Error.new("not json", 400)
    end

    test "returns defaults when the response doesn't match a known error" do
      assert %Error{
               decoded_response: %{},
               message: nil,
               reason: :unknown,
               response: "{}",
               status: 444
             } = Error.new("{}", 444)
    end
  end
end
