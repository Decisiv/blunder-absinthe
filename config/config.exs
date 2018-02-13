use Mix.Config

config :sasl, sasl_error_logger: false

import_config "#{Mix.env}.exs"
