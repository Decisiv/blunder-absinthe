if Code.ensure_loaded?(Bugsnag) do
  defmodule Blunder.Absinthe.ErrorHandler.BugSnagTest do
    use ExUnit.Case, async: false
    doctest Blunder.Absinthe.ErrorHandler.BugSnag

    import Mock

    test_with_mock "reports to Bugsnag", Bugsnag, [report: fn (_, _) -> :ok end] do
      blunder = %Blunder{severity: :error, code: :code}
      Blunder.Absinthe.ErrorHandler.BugSnag.call(blunder)
      assert called Bugsnag.report(blunder, context: :code, metadata: :_, severity: "error")
    end
  end
end
