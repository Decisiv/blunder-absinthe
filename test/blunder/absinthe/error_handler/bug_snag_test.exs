if Code.ensure_loaded?(Bugsnag) do
  defmodule Blunder.Absinthe.ErrorHandler.BugSnagTest do
    use ExUnit.Case, async: false
    doctest Blunder.Absinthe.ErrorHandler.BugSnag

    import Mock

    test_with_mock "reports to Bugsnag with an original error when original error exists",
                   Bugsnag, [sync_report: fn (_, _) -> :ok end] do
      blunder = %Blunder{severity: :error, code: :code, original_error: "unexpected"}
      Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder)
      assert called Bugsnag.sync_report(
        blunder.original_error, context: :code, metadata: :_, severity: "error", stacktrace: blunder.stacktrace
      )
    end

    test_with_mock "reports to Bugsnag with an blunder error when original error does not exist",
                   Bugsnag, [sync_report: fn (_, _) -> :ok end] do
      blunder = %Blunder{severity: :error, code: :code}
      Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder)
      assert called Bugsnag.sync_report(
        blunder, context: :code, metadata: :_, severity: "error", stacktrace: blunder.stacktrace
      )
    end

    test_with_mock "reports to Bugsnag with an original error when original error is a tuple",
                   Bugsnag, [sync_report: fn (_, _) -> :ok end] do
      blunder = %Blunder{severity: :error, code: :code, original_error: {:error, "unexpected"}}
      Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder)
      assert called Bugsnag.sync_report(
        elem(blunder.original_error, 1), context: :code, metadata: :_, severity: "error", stacktrace: blunder.stacktrace
      )
    end

    test_with_mock "reports to Bugsnag", Bugsnag, [sync_report: fn (_, _) -> :ok end] do
      blunder = %Blunder{severity: :error, code: :code}
      Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder)
      assert called Bugsnag.sync_report(blunder, context: :code, metadata: :_, severity: "error", stacktrace: blunder.stacktrace)
    end

    test_with_mock "when Bugsnag returns error", Bugsnag, [sync_report: fn (_, _) -> :error end] do
      blunder = %Blunder{severity: :error, code: :code}
      assert Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder) == :error
    end

    describe "ignore severities below threshold" do
      test_with_mock "test no report is sent to bugsnag", Bugsnag, [sync_report: fn (_, _) -> :ok end] do
        blunder = %Blunder{severity: :debug, code: :code}
        Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder)
        refute called Bugsnag.sync_report(:_, :_)
      end

      test_with_mock "test report is sent to bugsnag", Bugsnag, [sync_report: fn (_, _) -> :ok end] do
        blunder = %Blunder{severity: :error, code: :code}
        Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder)
        assert called Bugsnag.sync_report(blunder, context: :code, metadata: :_, severity: "error", stacktrace: blunder.stacktrace)
      end

      test_with_mock "when threshold is debug", Bugsnag, [sync_report: fn (_, _) -> :ok end] do
        blunder = %Blunder{severity: :debug, code: :code}
        Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder, threshold: :debug)
        assert called Bugsnag.sync_report(blunder, :_)
      end
    end
  end
end
