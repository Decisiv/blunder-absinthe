use Mix.Config

config :blunder, error_handlers: [Blunder.Absinthe.ErrorHandler.LogError]
