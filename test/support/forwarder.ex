defmodule Blunder.Absinthe.Test.Forwarder do
  @moduledoc """
  A simple genserver that forwards any messages it recievies to a configured pid.

  Useful in tests that need to wait for async events to happen.

  Stolen from: http://openmymind.net/Testing-Asynchronous-Code-In-Elixir/
  """
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def setup(pid) do
    GenServer.cast(__MODULE__, {:setup, pid})
  end

  def send(msg) do
    GenServer.cast(__MODULE__, {:send, msg})
  end

  def handle_cast({:setup, pid}, _state) do
    {:noreply, pid}
  end

  def handle_cast({:send, msg}, pid) do
    send(pid, msg)
    {:noreply, pid}
  end
end
