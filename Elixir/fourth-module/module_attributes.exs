# Module attributes

## purposes

#They serve to annotate the module, often with information to be used by the user or the VM.

#They work as constants.

#They work as a temporary module storage to be used during compilation.

## As annotations

#. Elixir has a handful of reserved attributes. Here are a few of them, the most commonly used ones:

#@moduledoc - provides documentation for the current module.

#@doc - provides documentation for the function or macro that follows the attribute.

#@spec - provides a typespec for the function that follows the attribute.

#@behaviour - (notice the British spelling) used for specifying an OTP or user-defined behaviour.

#@moduledoc and @doc are by far the most used attributes. Elixir treats documentation as first-class and provides many functions to access documentation.

```elixir
# this is the way to write documentation in a module: 

defmodule Math do
  @moduledoc """
  Provides math-related functions.

  ## Examples

      iex> Math.sum(1, 2)
      3

  """

  @doc """
  Calculates the sum of two numbers.
  """
  def sum(a, b), do: a + b
end
```

#Elixir also provide a tool called ExDoc which is used to generate HTML pages from the documentation.

## As constants

#Elixir developers often use module attributes when they wish to make a value more visible or reusable:

```elixir
defmodule MyServer do
  @initial_state %{host: "127.0.0.1", port: 3456}
  IO.inspect(@initial_state)
end
```

#Attributes can also be read inside functions:

defmodule MyServer do
  @my_data 14
  def first_data, do: @my_data
  @my_data 13
  def second_data, do: @my_data
end

MyServer.first_data #return 14
MyServer.second_data #return 13

<!-- livebook:{"break_markdown":true} -->

#Every time an attribute is read inside a function, Elixir takes a snapshot of its current value. Therefore if you read the same attribute multiple times inside multiple functions, you may end-up making multiple copies of it. That’s usually not an issue, but if you are using functions to compute large module attributes, that can slow down compilation. The solution is to move the attribute to shared function. Like this:

```elixir
def some_function, do: do_something_with(@example)
def another_function, do: do_something_else_with(@example)

# Prefer this:

def some_function, do: do_something_with(example())
def another_function, do: do_something_else_with(example())
defp example, do: @example
```

## As temporary storage

#ExUnit uses module attributes for multiple different purposes:

```elixir
defmodule MyTest do
  use ExUnit.Case, async: true

  @tag :external
  @tag os: :unix
  test "contacts external service" do
    # ...
  end
end

# ExUnit stores the value of async: true in a module attribute to change how the module is compiled. Tags are also defined as accumulate: true attributes, and they store tags that can be used to setup and filter tests. 
```
