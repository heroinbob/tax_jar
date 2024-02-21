defmodule TaxJar.Test.Support.HTTPCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import TaxJar.Test.Support.Context
      import TaxJar.Test.Support.Requests

      alias TaxJar.Test.Support.Fixtures
    end
  end

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end
end
