# Protocols

## Introduction

#Protocols are a mechanism to achieve polymorphism in Elixir when you want behavior to vary depending on the data type.


defmodule Utility do
  def type(value) when is_binary(value), do: "string"
  def type(value) when is_integer(value), do: "integer"
end

# If the use of this module were confined to your own project, you would be able to keep defining new type/1 functions for each new data type. However, this code could be problematic if it was shared as a dependency by multiple apps because there would be no easy way to extend its functionality.


#protocols allow us to extend the original behavior for as many data types as we need. That’s because dispatching on a protocol is available to any data type that has implemented the protocol and a protocol can be implemented by anyone, at any time.


# we could write the same Utility.type/1 functionality as a protocol
defprotocol Utility do
  @spec type(t) :: String.t()
  def type(value)
end

defimpl Utility, for: BitString do
  def type(_value), do: "string"
end

defimpl Utility, for: Integer do
  def type(_value), do: "integer"
end

# is like invoke a module
Utility.type("foo")


#We define the protocol using defprotocol - its functions and specs may look similar to interfaces or abstract base classes in other languages. We can add as many implementations as we like using defimpl. The output is exactly the same as if we had a single module with multiple functions:

## Example


# On elixir we have map_size(map) byte_size(string) or tuple_size(tuple). But we can use a protocol to size any type of data.
defprotocol Size do
  @doc "Calculates the size (and not the length!) of a data structure"
  def size(data)
end

defimpl Size, for: BitString do
  def size(string), do: byte_size(string)
end

defimpl Size, for: Map do
  def size(map), do: map_size(map)
end

defimpl Size, for: Tuple do
  def size(tuple), do: tuple_size(tuple)
end

# 7
Size.size("abcdefg")
# 3
Size.size(%{a: "a", b: "b", c: "c"})
# 5
Size.size({"abcd", 1, 2, 3, "hi"})


## Protocols and structs

#The power of Elixir’s extensibility comes when protocols and structs are used together.

#If desired, you could come up with your own semantics for the size of your struct. Not only that, you could use structs to build more robust data types, like queues, and implement all relevant protocols, such as Enumerable and possibly Size, for this data type.


defmodule User do
  defstruct [:name, :age]
end

defimpl Size, for: User do
  def size(_user), do: 2
end


## Implementing Any

#Manually implementing protocols for all types can quickly become repetitive and tedious. In such cases, Elixir provides two options: we can explicitly derive the protocol implementation for our types or automatically implement the protocol for all types. In both cases, we need to implement the protocol for Any.


defimpl Size, for: Any do
  def size(_), do: 0
end

defmodule OtherUser do
  @derive [Size]
  defstruct [:name, :age]
end

# When deriving, Elixir will implement the Size protocol for OtherUser based on the implementation provided for Any.
defprotocol Size do
  @fallback_to_any true
  def size(data)
end

# Otra alternativa a @derive es indicar explícitamente al protocolo que recurra a Any cuando no se pueda encontrar una implementación. Esto puede lograrse estableciendo @fallback_to_any a true en la definición del protocolo:


## Built-in protocols

#Enum module which provides many functions that work with any data structure that implements the Enumerable protocol:


Enum.map([1, 2, 3], fn x -> x * 2 end) #2,4,6
#Another useful example is the String.Chars
to_string :hello
The snippet above only works because numbers implement the String protocol.


#The Inspect protocol is the protocol used to transform any data structure into a readable textual representation. This is what tools like IEx use to print results:


IO.inspect(456)
