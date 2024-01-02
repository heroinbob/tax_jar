defmodule TaxJar do
  @default_api_version "2022-01-24"
  @sandbox_url "https://api.sandbox.taxjar.com/v2"
  @production_url "https://api.taxjar.com/v2"

  @urls %{
    sandbox: @sandbox_url,
    production: @production_url
  }

  defdelegate get_sales_tax_for_order(payload), to: TaxJar.Requests.Taxes

  def get_api_key, do: fetch_env!(:api_key)

  def get_api_url do
    mode = get_mode()
    get_env(:api_url, @urls[mode])
  end

  def get_api_version, do: get_env(:api_version, @default_api_version)

  def get_mode do
    mode = get_env(:mode, :sandbox)

    unless mode in [:sandbox, :production] do
      raise ArgumentError, "invalid mode #{inspect(mode)}: must be :sandbox or :production"
    end

    mode
  end

  def fetch_env!(key), do: Application.fetch_env!(:tax_jar, key)

  def get_env(key, default \\ nil), do: Application.get_env(:tax_jar, key, default)

  def put_env(key, value, opts \\ []), do: Application.put_env(:tax_jar, key, value, opts)
end
