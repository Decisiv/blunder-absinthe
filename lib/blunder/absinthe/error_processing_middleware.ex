defmodule Blunder.Absinthe.ErrorProcessingMiddleware do
  @doc """
  Absinthe middleware that extracts all errors in the graphql response, converts them to Blunder structs, dispatches them to all registered ErrorHandlers for processing, then converts each Blunder into a graphql error representation and puts it back in the response.
  """

  @behaviour Absinthe.Middleware

  import Blunder.Absinthe.ErrorHandlerSupervisor, only: [error_event: 1]

  @impl Absinthe.Middleware
  @spec call(Absinthe.Resolution.t, term) :: Absinthe.Resolution.t
  def call(resolution, _config) do
    errors = for error <- resolution.errors do
      error = Blunder.new(error)
      error_event(error)
      to_graphiql_error(error)
    end

    %{resolution | errors: errors}
  end

  @spec to_graphiql_error(Blunder.t) :: %{code: atom, title: binary, message: binary}
  defp to_graphiql_error(%Blunder{} = blunder) do
    to_graphiql_error(blunder, Application.get_env(:blunder, :detailed_error_responses))
  end

  @spec to_graphiql_error(Blunder.t, boolean) :: %{code: atom, title: binary, message: binary}
  defp to_graphiql_error(%Blunder{} = blunder, detailed_error_responses)
  when detailed_error_responses in [false, nil]
  do
    %{
      code: blunder.code,
      title: humanize(blunder.code),
      message: blunder.summary,
    }
  end

  defp to_graphiql_error(%Blunder{} = blunder, true) do
    blunder
    |> to_graphiql_error(false)
    |> Map.put(:details, blunder.details)
  end

  @spec humanize(atom) :: binary
  defp humanize(atom) do
    atom
    |> to_string
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

end
