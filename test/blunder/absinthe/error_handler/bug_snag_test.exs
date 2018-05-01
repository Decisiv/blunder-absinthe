if Code.ensure_loaded?(Bugsnag) do
  defmodule Blunder.Absinthe.ErrorHandler.BugSnagTest do
    use ExUnit.Case, async: false
    doctest Blunder.Absinthe.ErrorHandler.BugSnag

    import Mock

    test_with_mock "reports to Bugsnag with an original error when original error exists",
                   Bugsnag, [report: fn (_, _) -> :ok end] do
      blunder = %Blunder{severity: :error, code: :code, original_error: "unexpected"}
      Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder)
      assert called Bugsnag.report(
        blunder.original_error, context: :code, metadata: :_, severity: "error", stacktrace: blunder.stacktrace
      )
    end

    test_with_mock "reports to Bugsnag with an blunder error when original error does not exist",
                   Bugsnag, [report: fn (_, _) -> :ok end] do
      blunder = %Blunder{severity: :error, code: :code}
      Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder)
      assert called Bugsnag.report(
        blunder, context: :code, metadata: :_, severity: "error", stacktrace: blunder.stacktrace
      )
    end
  end
end
