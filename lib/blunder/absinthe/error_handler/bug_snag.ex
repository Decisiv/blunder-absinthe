defmodule Blunder.Absinthe.ErrorHandler.BugSnag do
  @moduledoc """
  Error handler that logs errors using Logger
  """
  use Blunder.Absinthe.ErrorHandler
  require Logger

  @impl Blunder.Absinthe.ErrorHandler
  @spec call(Blunder.t) :: (:ok | {:error, any})
  def call(blunder) do
    Bugsnag.report(blunder, severity: bugsnag_severity(blunder))
    :ok
  end

  @spec bugsnag_severity(Blunder.t) :: binary
  def bugsnag_severity(%Blunder{severity: severity}) do
    case severity do
      :debug -> "info"
      :info -> "info"
      :warn -> "warning"
      :error -> "error"
      :critical -> "error"
      _ -> "error"
    end
  end
end
