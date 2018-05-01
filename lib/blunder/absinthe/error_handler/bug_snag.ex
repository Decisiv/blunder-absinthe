if Code.ensure_loaded(Bugsnag) do
  defmodule Blunder.Absinthe.ErrorHandler.BugSnag do
    @moduledoc """
    Error handler that logs errors using Logger
    """
    use Blunder.Absinthe.ErrorHandler
    require Logger
    @opts Application.get_env(:blunder, Blunder.Absinthe.ErrorHandler.BugSnag)

    @impl Blunder.Absinthe.ErrorHandler
    @spec call(Blunder.t) :: (:ok | {:error, any})

    def call(%Blunder{severity: s} = blunder) do
      ignore = Keyword.get(@opts, :ignore_severities, [])
      if Enum.member?(ignore, s) do
        {:ok, :ignored}
      else
        Bugsnag.report(
        bugsnag_excpetion(blunder),
        context: (if !blunder.stacktrace, do: blunder.code),
        metadata: bugsnag_metadata(blunder),
        severity: bugsnag_severity(blunder)
        )
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

    defp bugsnag_metadata(blunder) do
      blunder
      |> Map.from_struct
      |> Map.take([:code, :summary, :details, :severity])
    end

    defp bugsnag_excpetion(%Blunder{original_error: {:error, original_error}}), do: original_error
    defp bugsnag_excpetion(%Blunder{original_error: nil} = blunder), do: blunder
    defp bugsnag_excpetion(%Blunder{original_error: original_error}), do: original_error
  end
end
