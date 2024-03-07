defmodule TaxJar.Test.Support.Context do
  @moduledoc """
  Helper functions for changing the runtime configuration during a test.
  """

  @doc """
  Execute the given function using the given config overrides.

  After the function is executed the original values are restored.
  """
  def with_config(overrides, callback) when is_map(overrides) and is_function(callback) do
    originals =
      for {key, _value} <- overrides,
          do: {key, Application.get_env(:tax_jar, key, :none)},
          into: %{}

    try do
      for {key, value} <- overrides, do: TaxJar.put_env(key, value)
      callback.()
    after
      restore_env(originals)
    end
  end

  defp restore_env(originals) do
    for {key, value} <- originals do
      if value == :none do
        Application.delete_env(:tax_jar, key)
      else
        TaxJar.put_env(key, value)
      end
    end
  end
end
