# Blunder.Absinthe

Package for simplifying error representation and handling in an Absinthe application using [`Blunder`](https://github.decisiv.net/PlatformServices/blunder)

## Usage

### Add Blunder to your Absinthe Middleware Stack

Add Blunder error handling to your resolvers by letting Blunder wrap your middleware. You can do this by implementing the middleware callback in your schema like this:

```elixir
  def middleware(middleware, _field, _object) do
    Blunder.Absinthe.add_error_handling(middleware)
  end
```

This will catch all exceptions as well as provide special handling for any `%Blunder{}` errors returned from resolver functions.

### Start returning Blunder Errors

Now that the middleware is installed you can return `{:error, %Blunder{}}` from your resolvers when there is an error. This gives you a lot more expressiveness than `{:error, "error string"}`. The `%Blunder{}` struct has the following properties you can set.

* `code` - An atom describing the error in a machine-readable way. Defaults to `:application_error`
* `summary` - Displayed to the client in graphql errors
* `details` - Hidden from the client in graphql errors (by default), but can be logged, etc
* `severity` - Can be used to determine what to log or alert on
* `stacktrace` - Allows you to attach a stacktrace to the error, `nil` by default
* `original_error` - The original error if this Blunder error is wrapping a lower-level exception

In order to simplify the creation of these error structs you're encouraged to create an `Errors` module in your app that exports functions for creating Blunder errors. This serves as a conveniance as well as a central place to document error types. Blunder provides the `deferror` macro in `Blunder.Errors` to make this easier.

```elixir
defmodule MyApp.Errors do
  import Blunder.Errors

  deferror :flagrant_system_error, 
    message: "MUCH ERRORZ!",
    severity: :critical

  deferror :boring_error, message: "whatevs"
end

defmodule MyApp.DoTheWork do
  import MyApp.Errors

  def add(x, y) do
    case get_system_status do
      :server_is_on_fire -> {:error, flagrant_system_error()},
      :server_is_le_tired -> {:error, boring_error()},
      :server_ready_to_work -> {:ok, x + y},
    end
  end
end
```

### Handle Errors In Your Absinthe Schema

Now that you've got all of your errors normalized into a common format and being handled in a central place in the Absinthe middleware, you probably want to do something with them. This is where the `ErrorHandler` comes in. You can create any number of `ErrorHander` modules, register them with `Blunder` in your config, and every error will get passed to every handler asynchonously.

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

Blunder ships with Error Handlers for [BugSnag](lib/blunder/absinthe/error_handler/bug_snag.ex) and [logging](lib/blunder/absinthe/error_handler/log_error.ex) that you can use right out of the box.
