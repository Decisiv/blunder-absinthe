use Mix.Config

config :sasl, sasl_error_logger: false

config :blunder, Blunder.Absinthe.ErrorHandler.BugSnag, ignore_severities: []

import_config "#{Mix.env}.exs"
