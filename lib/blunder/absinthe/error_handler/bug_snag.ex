if Code.ensure_loaded(Bugsnag) do
  defmodule Blunder.Absinthe.ErrorHandler.BugSnag do
    @moduledoc """
    Error handler that logs errors using Logger
    configurable within the config/config.exs on what should be notified
    depending on threshold
    """
    use Blunder.Absinthe.ErrorHandler
    require Logger

    @impl Blunder.Absinthe.ErrorHandler
    @spec call(Blunder.t) :: (:ok | {:error, any})

    def call(blunder, opts \\ []) do
      if should_report?(blunder, opts) do
        Bugsnag.sync_report(
          bugsnag_exception(blunder),
          context: (if !blunder.stacktrace, do: blunder.code),
          metadata: bugsnag_metadata(blunder),
          severity: bugsnag_severity(blunder),
          stacktrace: blunder.stacktrace
        )
      else
        :ok
      end
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

    defp should_report?(blunder, opts) do
      severity_numerical_value(blunder.severity) >= severity_numerical_value(Keyword.get(opts, :threshold, :error))
    end

    defp severity_numerical_value(severity) do
      case severity do
        :debug -> 0
        :info -> 1
        :warn -> 2
        :error -> 3
        :critical -> 4
      end
    end

    defp bugsnag_metadata(blunder) do
      blunder
      |> Map.from_struct
      |> Map.take([:code, :summary, :details, :severity])
    end

    defp bugsnag_exception(%Blunder{original_error: {:error, original_error}}), do: original_error
    defp bugsnag_exception(%Blunder{original_error: nil} = blunder), do: blunder
    defp bugsnag_exception(%Blunder{original_error: original_error}), do: original_error
  end
end
