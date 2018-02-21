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

  describe "&add_error_handling/1" do
    @field %Absinthe.Type.Field{identifier: :some_field}

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
      [wrapped_middleware | _] = add_error_handling([TestMiddleware])

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
  end
end
