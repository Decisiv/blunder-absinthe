defmodule TestMiddleware do
  @behaviour Absinthe.Middleware
  import Absinthe.Resolution

  def call(resolution, config) do
    resolution |> put_result({:ok, %{func: "call", config: config}})
  end

  def call2(resolution, config) do
    resolution |> put_result({:ok, %{func: "call2", config: config}})
  end
end

defmodule Blunder.AbsintheTest do
  use ExUnit.Case
  doctest Blunder.Absinthe

  import Blunder.Absinthe

  @field %Absinthe.Type.Field{identifier: :some_field}

  describe "&add_error_handling/1" do
    test "default resolver not altered" do
      default_middleware = {Absinthe.Middleware.MapGet, @field.identifier}
      assert [^default_middleware | _] = add_error_handling([default_middleware], @field)
    end

    test "MapGet middleware with different field not treated like default resolver" do
      default_middleware = {Absinthe.Middleware.MapGet, :different_attr_name}
      [wrapped_middleware | _] = add_error_handling([default_middleware], @field)

      # Retruns a "safe" function that does the MapGet
      assert %Absinthe.Resolution{value: 42} =
        wrapped_middleware.(%Absinthe.Resolution{source: %{different_attr_name: 42}}, [])

      # catches errors
      not_a_map = []
      assert %Absinthe.Resolution{errors: [%Blunder{original_error: %BadMapError{}}]} =
        wrapped_middleware.(%Absinthe.Resolution{source: not_a_map}, [])
    end

    test "{{module, function}, config} specs" do
      [wrapped_middleware | _] = add_error_handling([{{TestMiddleware, :call2}, %{a: 1}}], @field)

      assert %Absinthe.Resolution{
        value: %{
          func: "call2",
          config: %{a: 1}
        }
      } = wrapped_middleware.(%Absinthe.Resolution{}, :ignored)
    end

    test "{module, config} specs" do
      [wrapped_middleware | _] = add_error_handling([{TestMiddleware, %{a: 1}}], @field)

      assert %Absinthe.Resolution{
        value: %{
          func: "call",
          config: %{a: 1}
        }
      } = wrapped_middleware.(%Absinthe.Resolution{}, :ignored)
    end

    test "module specs" do
      [wrapped_middleware | _] = add_error_handling([TestMiddleware], @field)

      assert %Absinthe.Resolution{
        value: %{
          func: "call",
          config: %{a: 1}
        }
      } = wrapped_middleware.(%Absinthe.Resolution{}, %{a: 1})
    end

    test "&fun/2 specs" do
      [wrapped_middleware | _] = add_error_handling([&TestMiddleware.call/2], @field)

      assert %Absinthe.Resolution{
        value: %{
          func: "call",
          config: %{a: 1}
        }
      } = wrapped_middleware.(%Absinthe.Resolution{}, %{a: 1})
    end

    test "&fun/1 specs" do
      [wrapped_middleware | _] = add_error_handling([&TestMiddleware.call(&1, %{a: 1})], @field)

      assert %Absinthe.Resolution{
        value: %{
          func: "call",
          config: %{a: 1}
        }
      } = wrapped_middleware.(%Absinthe.Resolution{}, :ignored)
    end

    test "&add_error_handling/1 with Absinthe.Middleware.Async middleware" do
      opts = [foo: :bar]
      config = fn (_, _, _) -> {:middleware, Absinthe.Middleware.Async, {&crush_call/0, opts }} end
      [wrapped_middleware | _] = add_error_handling([{{Absinthe.Resolution, :call}, config}], @field)

      assert %Absinthe.Resolution{middleware: [{Absinthe.Middleware.Async, {fun, ^opts}}]}
             = wrapped_middleware.(%Absinthe.Resolution{}, :unresolved)

      assert {:error, %Blunder{
        code: :unexpected_exception,
        details: "Blunder trapped exception",
        original_error: %RuntimeError{
          message: "Unexpected Error"
        }
      }} = fun.()
    end
  end

  defp crush_call() do
    raise "Unexpected Error"
  end
end
