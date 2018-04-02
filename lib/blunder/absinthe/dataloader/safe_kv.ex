if Code.ensure_loaded?(Dataloader) do
  defmodule Blunder.Absinthe.Dataloader.SafeKV do
    @moduledoc """
    Safe KV based Dataloader source.

    This module provides an enhanced Dataloader.KV source. If there are errors loading the data
    they are added to the resulting map as `{:error}` tuples.
    """

    @spec new(load_function :: fun, opts :: keyword) :: %Dataloader.KV{}
    def new(load_function, opts \\ []) do
      Dataloader.KV.new(make_safe(load_function), opts)
    end

    @spec make_safe(fun) :: fun
    defp make_safe(fun) do
      fn x, keys ->
        fn -> fun.(x, keys) end
        |> Blunder.trap_exceptions
        |> handle_results(keys)
      end
    end

    @spec handle_results(result :: (map | {:error, any}), keys :: [...]) :: map
    defp handle_results({:error, _} = error, keys) do
      build_results_map(error, keys)
    end
    defp handle_results(%{} = results_map, _keys) do
      results_map
    end

    @spec build_results_map(error :: any, keys :: [...]) :: map
    defp build_results_map(error, keys) do
      keys |> Enum.into(%{}, fn key -> {key, error} end)
    end
  end
end
