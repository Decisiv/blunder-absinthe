use Mix.Config

config :blunder, error_handers: [Blunder.Absinthe.ErrorHandler.LogError]
