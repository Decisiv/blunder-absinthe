defmodule Blunder.Absinthe.Application do
  @moduledoc false
  use Application

  alias Blunder.Absinthe.ErrorHandlerSupervisor

  def start(_type, _args) do
    ErrorHandlerSupervisor.start_link(
      Application.get_env(:blunder, :error_handers)
    )
  end
end
