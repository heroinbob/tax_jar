import Config

config :tax_jar,
  env: config_env(),
  http_adapter: TaxJar.Requests.HTTPAdapters.ReqAdapter

if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end
