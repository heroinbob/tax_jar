defmodule TaxJar.Test.Support.HTTPCase do
  @moduledoc """
  ExUnit.CaseTemplate for testing TaxJar requests.

  Use this when you need to work with the MockHTTPAdapter.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      import Hammox
      import TaxJar.Test.Support.Context

      alias TaxJar.Requests.HTTPAdapters.MockHTTPAdapter
      alias TaxJar.Test.Support.Fixtures

      setup :verify_on_exit!
    end
  end
end
