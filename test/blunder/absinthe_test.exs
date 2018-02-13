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
    test "{{module, function}, config} specs" do
      [wrapped_middleware | _] = add_error_handling([{{TestMiddleware, :call2}, %{a: 1}}])

      assert %Absinthe.Resolution{
        value: %{
          func: "call2",
          config: %{a: 1}
        }
      } = wrapped_middleware.(%Absinthe.Resolution{}, :ignored)
    end

    test "{module, config} specs" do
      [wrapped_middleware | _] = add_error_handling([{TestMiddleware, %{a: 1}}])

      assert %Absinthe.Resolution{
        value: %{
          func: "call",
          config: %{a: 1}
        }
      } = wrapped_middleware.(%Absinthe.Resolution{}, :ignored)
    end

    test "&fun/2 specs" do
      [wrapped_middleware | _] = add_error_handling([&TestMiddleware.call/2])

      assert %Absinthe.Resolution{
        value: %{
          func: "call",
          config: %{a: 1}
        }
      } = wrapped_middleware.(%Absinthe.Resolution{}, %{a: 1})
    end

    test "&fun/1 specs" do
      [wrapped_middleware | _] = add_error_handling([&TestMiddleware.call(&1, %{a: 1})])

      assert %Absinthe.Resolution{
        value: %{
          func: "call",
          config: %{a: 1}
        }
      } = wrapped_middleware.(%Absinthe.Resolution{}, :ignored)
    end
  end
end
