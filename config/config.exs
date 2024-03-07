import Config

config :tax_jar, env: config_env()

if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end
