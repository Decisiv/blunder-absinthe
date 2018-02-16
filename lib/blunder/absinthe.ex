defmodule Blunder.Absinthe do
  @moduledoc """
  Helpers for Absinthe Integration
  """

  alias Absinthe.{Middleware, Resolution}

  @doc """
  This function takes an Absinthe middleware stack and adds error handling.
  Each middleware will be wrapped in a `&Blunder.trap_exceptions/2` call and
  `Blunder.Absinthe.ErrorProcessingMiddleware` appended to the end of the stack
  to handle those and any other errors.

  Call it in your Schema in your `&middleware/3` callback like this:
  ```elixir
    def middleware(middleware, _field, _object) do
      Blunder.Absinthe.add_error_handling(middleware)
    end
  ```
  """
  @spec add_error_handling([Middleware.spec, ...]) :: [Middleware.spec, ...]
  def add_error_handling(middleware) do
    Enum.map(middleware, fn spec ->
      fn res, config ->
        spec
        |> to_resolver_function(res, config)
        |> resolve_safely(res)
      end
    end) ++ [Blunder.Absinthe.ErrorProcessingMiddleware]
  end

  @spec to_resolver_function(Middleware.spec, Resolution.t, any) ::
    (() -> Resolution.t)
  defp to_resolver_function({{module, function}, config}, res, _config) do
    fn -> apply(module, function, [res, config]) end
  end

  defp to_resolver_function({module, config}, res, _config) do
    fn -> apply(module, :call, [res, config]) end
  end

  defp to_resolver_function(module, res, config) when is_atom(module) do
    fn -> apply(module, :call, [res, config]) end
  end

  defp to_resolver_function(fun, res, _config) when is_function(fun, 1) do
    fn -> fun.(res) end
  end

  defp to_resolver_function(fun, res, config) when is_function(fun, 2) do
    fn -> fun.(res, config) end
  end

  @spec resolve_safely((() -> Resolution.t), Resolution.t) :: Resolution.t
  defp resolve_safely(fun, res) do
    blunder = %Blunder{
      code: :unexpected_exception,
      summary: "The application encountered an unexpected exception",
    }

    case Blunder.trap_exceptions(fun, blunder: blunder) do
      {:error, error} ->
        Resolution.put_result(res, {:error, error})
      resolution ->
        resolution
    end
  end
end
