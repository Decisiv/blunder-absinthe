defmodule Blunder.Absinthe.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    Blunder.Absinthe.ErrorHandlerSupervisor.start_link(
      Application.get_env(:blunder, :error_handers)
    )
  end
end
