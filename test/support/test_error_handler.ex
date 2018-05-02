defmodule Blunder.Absinthe.Test.ErrorHandler do
  @moduledoc """
  A mock error handler that just uses Forwarder to notify the tests when it get's called.
  """
  use Blunder.Absinthe.ErrorHandler

  @impl Blunder.Absinthe.ErrorHandler
  def call(blunder, _opts) do
    Blunder.Absinthe.Test.Forwarder.send({:error_handler_called, blunder})
  end
end
