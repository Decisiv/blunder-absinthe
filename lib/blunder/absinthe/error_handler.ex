defmodule Blunder.Absinthe.ErrorHandler do
  @moduledoc """
  Behaviour for a module that handles Blunder errors in the Blunder.Absinthe middleware

  Creating an error handler is as simple as this:

  ```elixir
  defmodule LogError do
    use Blunder.Absinthe.ErrorHandler
    require Logger

    @impl Blunder.Absinthe.ErrorHandler
    def call(blunder) do
      Logger.error blunder.message
    end

  end
  ```

  Then in your config...

  ```elixir
  config :blunder, error_handlers: [ LogError ]
  ```
  """

  @callback call(Blunder.t) :: (:ok | {:error, any})

  defmacro __using__(_opts \\ []) do
    quote do
      @behaviour unquote(__MODULE__)

      use GenServer

      @impl GenServer
      def init(args) do
        {:ok, args}
      end

      def start_link(_ \\ nil) do
        GenServer.start_link(__MODULE__, nil, name: __MODULE__)
      end

      @impl GenServer
      def handle_cast({:error_event, blunder}, state) do
        call(blunder)
        {:noreply, state}
      end
    end
  end

  @spec error_event(pid :: pid, blunder :: Blunder.t) :: :ok
  def error_event(pid, blunder) do
    GenServer.cast(pid, {:error_event, blunder})
  end
end
