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
  By default only the resolvers for root queries & mutations are wrapped with the error handling.
  To wrap all resolvers and stop errors deeper in the tree instead of letting
  them bubble up tp the root, add `wrap_all_resolvers: true` to the options.

  Call it in your Schema in your `&middleware/3` callback like this:
  ```elixir
    def middleware(middleware, field, _object) do
      Blunder.Absinthe.add_error_handling(middleware, field, timeout_ms: 3_000)
    end
  ```
  """
  @spec add_error_handling(
    [Middleware.spec, ...],
    any,
    opts :: [timeout_ms: number]
  ) :: [Middleware.spec, ...]
  def add_error_handling(middleware, field, opts \\ [])
  def add_error_handling(middleware, field, opts)
      when is_list(middleware) do
    Enum.map(
      middleware,
      &add_error_handling(&1, field, opts)
    ) ++ [Blunder.Absinthe.ErrorProcessingMiddleware]
  end

  def add_error_handling({Absinthe.Middleware.MapGet, attr} = spec, %{identifier: attr}, _opts) do
    spec
  end

  def add_error_handling(spec, _field, opts) do
    fn res, config ->
      spec
      |> to_resolver_function(res, config)
      |> to_safely_async(opts)
      |> resolve_safely(res, opts)
    end
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

  @spec resolve_safely(
    (() -> Resolution.t),
    Resolution.t,
    opts :: [timeout_ms: number]
  ) :: Resolution.t
  defp resolve_safely(fun, res, opts) do

    if res.source == %{} || res.source == nil || opts[:wrap_all_resolvers] do
      case Blunder.trap_exceptions(fun, Keyword.merge(opts, blunder: blunder())) do
        {:error, error} ->
          Resolution.put_result(res, {:error, %{error | details:
            "Operation: #{operation_name(res.definition)}, Arguments: #{inspect res.arguments}, #{error.details}"}})
        resolution ->
          resolution
      end
    else
      invoke(fun, res)
    end
  end

  def invoke(fun, res) do
    fun.()
  rescue
    error ->
      detailed_error = [details: "Operation: #{operation_name(res.definition)}, Arguments: #{inspect res.arguments}",
        original_error: error, stacktrace:  System.stacktrace()]
      Resolution.put_result(res, {:error, detailed_error})
  end

  defp operation_name(nil), do: ""
  defp operation_name(definition), do: definition.name

  defp to_safely_async(fun, opts) do
    fn -> fun.() |> to_safe_async_middleware(opts) end
  end

  defp to_safe_async_middleware(%Absinthe.Resolution{middleware: middleware} = resolution, opts) do
    decorated = Enum.map(middleware, &(decorate_async_middleware(&1, opts)))
    %{resolution | middleware: decorated}
  end

  defp decorate_async_middleware({Absinthe.Middleware.Async, {fun, fun_opts}}, opts) do
    {
      Absinthe.Middleware.Async,
      {fn -> Blunder.trap_exceptions(fun, Keyword.merge(opts, blunder: blunder())) end, fun_opts}
    }
  end
  defp decorate_async_middleware(middleware, _opts), do: middleware

  defp blunder do
    %Blunder{
      code: :unexpected_exception,
      summary: "The application encountered an unexpected exception",
    }
  end
end
