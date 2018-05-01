if Code.ensure_loaded(Bugsnag) do
  defmodule Blunder.Absinthe.ErrorHandler.BugSnag do
    @moduledoc """
    Error handler that logs errors using Logger
    """
    use Blunder.Absinthe.ErrorHandler
    require Logger

    @impl Blunder.Absinthe.ErrorHandler
    @spec call(Blunder.t) :: (:ok | {:error, any})
    def call(blunder) do
      Bugsnag.report(
        original_error(blunder.original_error) || blunder,
        context: (if !blunder.stacktrace, do: blunder.code),
        metadata: bugsnag_metadata(blunder),
        severity: bugsnag_severity(blunder),
        stacktrace: blunder.stacktrace
      )
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

    defp bugsnag_metadata(blunder) do
      blunder
      |> Map.from_struct
      |> Map.take([:code, :summary, :details, :severity])
    end

    defp original_error({:error, error}), do: error
    defp original_error(error), do: error
  end
end
