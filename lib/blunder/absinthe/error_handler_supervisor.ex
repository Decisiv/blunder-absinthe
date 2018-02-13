defmodule Blunder.Absinthe.ErrorHandlerSupervisor do
  @moduledoc false
  use Supervisor

  def start_link(handlers) do
    Supervisor.start_link(__MODULE__, handlers, name: __MODULE__)
  end

  def init(handlers) do
    Supervisor.init(handlers, strategy: :one_for_one, max_restarts: 100, max_seconds: 1)
  end

  @spec error_event(Blunder.t) :: :ok
  def error_event(error) do
    Supervisor.which_children(__MODULE__)
    |> Enum.each(fn {_, pid, _, _} -> Blunder.Absinthe.ErrorHandler.error_event(pid, error) end)
  end
end
