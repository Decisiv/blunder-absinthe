use Mix.Config

config :sasl, sasl_error_logger: false

config :blunder, error_handlers: [
  {Blunder.Absinthe.ErrorHandler.BugSnag, [threshold: :error]}
]

import_config "#{Mix.env}.exs"
