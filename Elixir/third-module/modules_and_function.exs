# Modules and function

## Modules

#In Elixir they group several functions into modules, like:


String.length("hello")


#We can create new modules and used it, like this:


# The first letter of the module must be in uppercase
defmodule Math do
  def sum(a, b) do
    a + b
  end

  def subs(a, b) do
    a - b
  end
end

# return 13
Math.sum(5, 8)
# return -3
Math.subs(5, 8)


## Compilation

#Elixir can be compiled using elixirc in the terminal.

#This will generate a file named with the type beam and this contains the bytecode. If we did a module inside this file, and we start iex on the terminal, our module definition will be avaible.

#Elixir projects are usually organized into three directories:

#_build - contains compilation artifacts
#lib - contains Elixir code (usually .ex files)
#test - contains tests (usually .exs files)

#Elixir also supports a scripted mode which is more flexible and does not generate any compiled artifacts. the extension is exs

## scripted mode

#ex vs exs:

#The only diference is in intention .ex files are meant to be compiled while .exs files are used for scripting.

#elixir vs elixirc:

#If we use te comand elixirc it will create a file .beam. If we use the comand elixir the module was compiled and loaded into memory.

## Named functions

#Inside a module, we can define functions with def/2 and private functions with defp/2. A function defined with def/2 can be invoked from other modules while a private function can only be invoked locally.


defmodule Math do
  def sum(a, b) do
    do_sum(a, b)
  end

  defp do_sum(a, b) do
    a + b
  end
end

# return 3
IO.puts(Math.sum(1, 2))
# return UndefinedFunctionError
IO.puts(Math.do_sum(1, 2))


#If we put a question mark means that this fucntion return a boolean for example:


defmodule Math do
  def zero?(0) do
    true
  end

  def zero?(x) when is_integer(x) do
    false
  end
end

# return true
IO.puts(Math.zero?(0))
# return false
IO.puts(Math.zero?(1))
# return  FunctionClauseError
IO.puts(Math.zero?([1, 2, 3]))
# return  FunctionClauseError
IO.puts(Math.zero?(0.0))

# a clause error is when we invoque a function and none of the clouses match


#In modules, functions, ifs; you may use do: for one-liners but always use do-blocks for functions spanning multiple lines.

## Function capturing

#Elixir makes a distinction between anonymous functions and named functions.

#Anonymous function must be invoked with a dot (.) and parentheses.

#The capture operator (&) allow named functions to be assigned to variables and passed as arguments in the same way we assign, invoke and pass anonymous functions.


&String.trim/1
cut = &String.trim/1
# return "hello world"
cut.("        hello world          ")


#You can also capture operators:


add = &+/2
add.(1, 2)




## Default arguments

#Named functions in elixir also support default arguments:


defmodule Concat do
  def join(a, b, sep \\ " ") do
    a <> sep <> b
  end
end

# in this case we create a variable sep and assign it the value of " "
IO.puts(Concat.join("Hello", "world", ","))


#If a function with default values has multiple clauses, it is required to create a function head (a function definition without a body) for declaring defaults:


defmodule Concat do
  # A function head declaring defaults
  def join(a, b \\ nil, sep \\ " ")

  def join(a, b, _sep) when is_nil(b) do
    a
  end

  def join(a, b, sep) do
    a <> sep <> b
  end
end

IO.puts(Concat.join("Hello", "world", "_"))


#When using default values, one must be careful to avoid overlapping function definitions. Consider the following example:


defmodule Concat do
  def join(a, b) do
    IO.puts("***First join")
    a <> b
  end

  def join(a, b, sep \\ " ") do
    IO.puts("***Second join")
    a <> sep <> b
  end
end


#The compiler is telling us that invoking the join function with two arguments will always choose the first definition of join whereas the second one will only be invoked when three arguments are passed.

### Notes

#IO.puts = print strings

#IO.inspect = print any value

#on iex we can compile with the function c("module_name")

#to compile a file with the extension ex, we can use the comand elixirc (elixir compile)

#A guard is an if but outside the function. Is useful when you have two function with the same name but with differents processes.

#in the capturing function always have to put the arity of the function like trim/arity

#anonymous function alwas has to be invoke with .()
