# Types and specs

## Types and specs


# Elixir is a dynamically typed language, so all types in Elixir are checked at runtime. Nonetheless, Elixir comes with typespecs, which are a notation used for:
# 1. declaring typed function signatures (also called specifications);
# 2. declaring custom types


## Function specifications


#Elixir provides many built-in types, such as integer or pid, that can be used to document function signatures
round(number()) :: integer()
#The syntax is to put the function and its input on the left side of the :: and the return value’s type on the right side. Be aware that types may omit parentheses.


#In code, function specs are written with the @spec attribute, typically placed immediately before the function definition. Specs can describe both public and private functions. The function name and the number of arguments used in the @spec attribute must match the function it describes.
defmodule Person do
   @typedoc """
   A 4 digit year, e.g. 1984
   """
   @type year :: integer

   @spec current_age(year) :: integer
   def current_age(year_of_birth), do: # implementation
end

#The @typedoc attribute, similar to the @doc and @moduledoc attributes, is used to document custom types.

defmodule LousyCalculator do
  @spec add(number, number) :: {number, String.t}
  def add(x, y), do: {x + y, "You need a calculator to do that?!"}

  @spec multiply(number, number) :: {number, String.t}
  def multiply(x, y), do: {x * y, "Jeez, come on!"}
end

#instead of returning numbers, it returns tuples with the result of an operation as the first element and a random remark as the second element


## Behaviours


# Behaviours provide a way to:

# define a set of functions that have to be implemented by a module;
# ensure that a module implements all the functions in that set.
# If you have to, you can think of behaviours like interfaces in object oriented languages like Java: a set of function signatures that a module has to implement. Unlike Protocols, behaviours are independent of the type/data.

# Example of parser behaviour:

defmodule Parser do
  @doc """
  Parses a string.
  """
  @callback parse(String.t()) :: {:ok, term} | {:error, String.t()}

  @doc """
  Lists all supported file extensions.
  """
  @callback extensions() :: [String.t()]
end

# Modules adopting the Parser behaviour will have to implement all the functions defined with the @callback attribute.
# callback expects a function name but also a function specification like the ones used with the @spec attribute


## Dynamic dispatch


# Behaviours are frequently used with dynamic dispatching. For example, we could add a parse! function to the Parser module that dispatches to the given implementation and returns the :ok result or raises in cases of :error:

defmodule Parser do
  @callback parse(String.t()) :: {:ok, term} | {:error, String.t()}
  @callback extensions() :: [String.t()]

  def parse!(implementation, contents) do
    case implementation.parse(contents) do
      {:ok, data} -> data
      {:error, error} -> raise ArgumentError, "parsing error: #{error}"
    end
  end
end
