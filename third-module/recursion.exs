# Recursion

## Loops through recursion

#In imperative languages we use for if we want loops. But, in elixir data structures are immutable. For that reason, elixir rely on recursion: a funvtion is called recursively until a condition is reached that stops the recursive action from continuing. No data is mutated.


# Example of recursion

defmodule Recursion do
  def print_multiple_times(msg, n) when n > 0 do
    IO.puts(msg)
    print_multiple_times(msg, n - 1)
  end

  def print_multiple_times(_msg, 0) do
    :ok
  end
end

Recursion.print_multiple_times("Hello!", 3)
# Hello!
# Hello!
# Hello!
#:ok


## Reduce and map algorithms


# sum list of numbers
defmodule Math do
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end
end

# => 6
IO.puts(Math.sum_list([1, 2, 3], 0))



# double each element of a list

defmodule Math do
  def double_each([head | tail]) do
    [head * 2 | double_each(tail)] # The | in here is for make just one list with the elements inside, if this element doesn't write here the result it will be [2[4[6[]]]]
  end

  def double_each([]) do
    []
  end
end
IO.puts(Math.double_each([1,2,3])) #[2,4,6]
