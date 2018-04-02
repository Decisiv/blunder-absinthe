defmodule Blunder.Absinthe.Application do
  @moduledoc false
  use Application

  alias Blunder.Absinthe.ErrorHandlerSupervisor

  def start(_type, _args) do
    ErrorHandlerSupervisor.start_link(
      error_handlers()
    )
  end

  defp error_handlers do
    Application.get_env(:blunder, :error_handlers, default_error_handlers())
  end

  defp default_error_handlers do
    [Blunder.Absinthe.ErrorHandler.LogError]
  end
end
