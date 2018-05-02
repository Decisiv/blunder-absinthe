defmodule Blunder.Absinthe.ErrorHandler.LogError do
  @moduledoc """
  Error handler that logs errors using Logger
  """
  use Blunder.Absinthe.ErrorHandler
  require Logger

  @impl Blunder.Absinthe.ErrorHandler
  def call(blunder, _opts \\ []) do
    blunder
    |> Blunder.format
    |> log(log_lvl(blunder))
  end

  @spec log(binary, Logger.level) :: :ok | {:error, any}
  defp log(msg, lvl) do
    Logger.log(lvl, msg)
  end

  @spec log_lvl(Blunder.t) :: Logger.level
  defp log_lvl(%Blunder{severity: severity}) do
    case severity do
      :debug -> :debug
      :info -> :info
      :warn -> :warn
      :error -> :error
      :critical -> :error
    end
  end
end
