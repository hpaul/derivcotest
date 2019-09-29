use Mix.Config

config :derivcotest,
  port: 8000

import_config "#{Mix.env()}.exs"
