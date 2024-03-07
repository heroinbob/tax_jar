defmodule TaxJar.Test.Support.HTTPCase do
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
