use Mix.Config

config :ex_unit, capture_log: true

config :blunder, error_handlers: [Blunder.Absinthe.Test.ErrorHandler]
