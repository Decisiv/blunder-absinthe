defmodule TestError do
  import Blunder.Errors

  deferror :custom_error, summary: "Custom Error Summary"
end

defmodule TestSchema do
  use Absinthe.Schema

  @generic_blunder %Blunder{
    code: :code,
    summary: "summary",
    details: "details",
  }

  object :test_query_results do
    field :success, :string, resolve: fn _, _ -> {:ok, "ok"} end
    field :blunder, :string do
      resolve fn _, _ ->
        {:error, @generic_blunder}
      end
    end
    field :atom, :string, resolve: fn _, _ -> {:error, :some_atom} end
    field :custom_error, :string, resolve: fn _, _ -> {:error, TestError.custom_error details: "Custom Details"} end
    field :string, :string, resolve: fn _, _ -> {:error, "some string"} end
    field :map, :string, resolve: fn _, _ -> {:error, %{a: "a", b: "b"}} end
    field :exception, :string, resolve: fn _, _ -> raise "exception string" end
    field :match_error, :string, resolve: fn _, _ ->
      faulty_function = fn -> {:error, @generic_blunder} end
      {:ok, _} = faulty_function.()
    end
  end

  query do
    field :test_query, :test_query_results do
      resolve fn _, _ -> {:ok, %{}} end
    end
  end

  def middleware(middleware, _field, _object) do
    Blunder.Absinthe.add_error_handling(middleware)
  end
end

defmodule Blunder.Absinthe.IntegrationTest do
  use ExUnit.Case
  doctest Blunder

  setup do
    Blunder.Absinthe.Test.Forwarder.setup(self())
    :ok
  end

  test "passes over successful results without interference" do
    assert %{data: %{"test_query" => %{"success" => "ok"}}} == do_query("{ test_query { success } }")
  end

  test "Blunders rendered as graphql errors" do
    test_query_error "{ test_query { blunder } }", [
      error: %{
        title: "Code",
        code: :code,
        message: "summary",
      },
      details: "details",
    ]
  end

  test "known error atoms are rendered as graphql errors" do
    test_query_error "{ test_query { custom_error } }", [
      error: %{
        title: "Custom Error",
        code: :custom_error,
        message: "Custom Error Summary",
      },
      details: "Custom Details",
    ]
  end

  test "atoms rendered as graphql errors" do
    test_query_error "{ test_query { atom } }", [
      error: %{
        title: "Some Atom",
        code: :some_atom,
        message: "Application Error",
      },
      details: ""
    ]
  end

  test "error strings are rendered as generic application_errors errors" do
    test_query_error "{ test_query { string } }", [
      error: %{
        title: "Application Error",
        code: :application_error,
        message: "Application Error",
      },
      details: "some string"
    ]
  end

  test "maps are rendered as generic application_errors errors" do
    test_query_error "{ test_query { map } }", [
      error: %{
        title: "Application Error",
        code: :application_error,
        message: "Application Error",
      },
      original_error: %{a: "a", b: "b"}
    ]
  end

  test "exceptions are rendered as generic :unexpected_exception errors" do
    test_query_error "{ test_query { exception } }", [
      error: %{
        title: "Unexpected Exception",
        code: :unexpected_exception,
        message: "The application encountered an unexpected exception",
      },
      details: "trapped exception",
      original_error_message: "exception string",
    ]
  end

  test "blunders are extracted from match errors" do
    test_query_error "{ test_query { match_error } }", [
      error: %{
        title: "Code",
        code: :code,
        message: "summary",
      },
      details: "details",
    ]
  end

  describe "detailed error responses" do
    setup do
      Application.put_env(:blunder, :detailed_error_responses, true)
    end

    test "blunder details are included in graphql error when detailed_error_responses flag is set" do
      test_query_error "{ test_query { blunder } }", [
        error: %{
          title: "Code",
          code: :code,
          details: "details",
        },
        details: "details"
      ]
    end
  end

  def test_query_error(query, opts) do
    details_regex = Keyword.get(opts, :details, ~r//)
    original_error_message = Keyword.get(opts, :original_error_message, nil)
    original_error = Keyword.get(opts, :original_error, nil)
    expected_error = Keyword.get(opts, :error)
    expected_keys = Map.keys(expected_error)

    assert %{errors: [error]} = do_query(query)
    observed_attributes = Map.take(error, expected_keys)
    assert observed_attributes == expected_error
    assert {:error_handler_called, %Blunder{} = blunder_sent_to_handler} = forwarded()
    assert blunder_sent_to_handler.details =~ details_regex

    if original_error_message do
      assert blunder_sent_to_handler.original_error.message == original_error_message
    end

    if original_error do
      assert blunder_sent_to_handler.original_error == original_error
    end
  end

  def do_query(query) do
    assert {:ok, result} = Absinthe.run(query, TestSchema)
    result
  end

  def forwarded do
    receive do
      msg -> msg
    after
      500 -> flunk("Error Handler Never Called")
    end
  end
end
