defmodule Blunder.Absinthe.ErrorHandler.LogErrorTest do
  use ExUnit.Case, async: false
  doctest Blunder.Absinthe.ErrorHandler.LogError

  import ExUnit.CaptureLog

  test "logs the error" do
    blunder = %Blunder{summary: "the summary", severity: :warn}
    assert capture_log([level: :warn], fn ->
      Blunder.Absinthe.ErrorHandler.LogError.call(blunder)
    end) =~ "the summary"
  end
end
