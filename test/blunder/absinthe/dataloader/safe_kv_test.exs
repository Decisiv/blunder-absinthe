defmodule Blunder.Absinthe.Dataloader.SafeKVTest  do
  use ExUnit.Case, async: true

  alias Blunder.Absinthe.Dataloader.SafeKV

  test "Works like a normal KV Dataloader when the loading function does not fail" do
    echo_load_function = fn _batch, ids -> Enum.into(ids, %{}, &{&1, &1}) end
    source = SafeKV.new(echo_load_function)
    loader = Dataloader.new
      |> Dataloader.add_source(:test_source, source)
      |> Dataloader.load(:test_source, :batch, 999)
      |> Dataloader.load_many(:test_source, :batch, Enum.to_list(1..10))
      |> Dataloader.run


    assert Dataloader.get_many(loader, :test_source, :batch, [1, 2, 3, 999]) == [1, 2, 3, 999]
  end

  test "traps errors and returns them as {:error, %Blunder{}} tuples" do
    unreliable_loading_fn = fn
      :failing_batch, _ids -> raise "ERROR"
      _batch, ids -> Enum.into(ids, %{}, &{&1, &1})
    end

    source = SafeKV.new(unreliable_loading_fn)
    loader = Dataloader.new
      |> Dataloader.add_source(:test_source, source)
      |> Dataloader.load(:test_source, :failing_batch, 1)
      |> Dataloader.load(:test_source, :good_batch, 1)
      |> Dataloader.run


    assert [
      {:error, %Blunder{original_error: %{message: "ERROR"}}}
    ] = Dataloader.get_many(loader, :test_source, :failing_batch, [1])

    assert [1] = Dataloader.get_many(loader, :test_source, :good_batch, [1])
  end
  
end
