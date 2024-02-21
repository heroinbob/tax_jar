defmodule TaxJar do
  @moduledoc """
  Interact with TaxJar's API.

  ## Configuration

  To be able to use this successfully you need to configure the required values.

  - `:api_key` - The API auth key for your account.
  - `:api_url` - (Optional) If you want to override the default url for the current env.
  - `:api_version` - Must be a valid TaxJar API version. Default is `"2022-01-24"`.
  - `:mode` - (Optional) You can explicitly specify the mode as `:production` or `:sandbox`. The default is `:sandbox`. This will also control which url is used.
  """

  @default_api_version "2022-01-24"
  @sandbox_url "https://api.sandbox.taxjar.com/v2"
  @production_url "https://api.taxjar.com/v2"

  @urls %{
    sandbox: @sandbox_url,
    production: @production_url
  }

  defdelegate get_sales_tax_for_order(payload), to: TaxJar.Requests

  @spec get_api_key() :: binary()
  def get_api_key, do: fetch_env!(:api_key)

  def get_api_url do
    mode = get_mode()
    get_env(:api_url, @urls[mode])
  end

  @spec get_api_version() :: binary()
  def get_api_version, do: get_env(:api_version, @default_api_version)

  @spec get_mode() :: :sandbox | :production
  def get_mode do
    mode = get_env(:mode, :sandbox)

    unless mode in [:sandbox, :production] do
      raise ArgumentError, "invalid mode #{inspect(mode)}: must be :sandbox or :production"
    end

    mode
  end

  @spec fetch_env!(atom()) :: any()
  def fetch_env!(key), do: Application.fetch_env!(:tax_jar, key)

  @spec get_env(atom(), any()) :: any()
  def get_env(key, default \\ nil), do: Application.get_env(:tax_jar, key, default)

  @spec put_env(atom(), any()) :: :ok
  def put_env(key, value, opts \\ []), do: Application.put_env(:tax_jar, key, value, opts)
end
