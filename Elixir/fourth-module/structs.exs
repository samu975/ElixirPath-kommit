# Structs

## Introduction

#Structs are extensions built on top of maps that provide compile-time checks and default values.

## Defining structs


defmodule User do
  # {:module, User, <<70, 79, 82, 49, 0, 0, 7, ...>>, %User{name: "John", age: 27}
  defstruct name: "John", age: 27
end


## Accessing and updating structs

The same techniques of maps (and the same syntax) apply to structs as well:


john = %User{}
%User{age: 27, name: "John"}
john.name


#Structs can also be used in pattern matching:


%User{name: name} = john
%User{age: 27, name: "John"}
name


## Structs are bare maps underneath

#As maps, structs store a “special” field named __struct__ that holds the name of the struct:


# true
is_map(john)
# User
john.__struct__


#Structs are just maps, they work with the functions from the Map module:


# %User{name: "Jane", age: 27}
jane = Map.put(%User{}, :name, "Jane")
# %User{name: "John", age: 27}
Map.merge(jane, %User{name: "John"})
# :age, :name
Map.keys(jane)

# Structs alongside protocols provide one of the most important features for Elixir developers: data polymorphism.


## Default values and required keys


# If you don’t specify a default key value when defining a struct, nil will be assumed:
defmodule Product do
  defstruct [:name]
end

# %Product{name: nil}
%Product{}



#you can use default values
defmodule User do
  defstruct [:email, name: "Jhon", age: 24]
end
%User{} #%User{email: nil, name: "Jhon", age: 24}

#Doing it in reverse order will raise a syntax error:
defmodule User do
  defstruct [name: "John", age: 27, :email] #(SyntaxError) #cell:9:35: unexpected expression after keyword list
end






# certain keys have to be specified when creating the struct via the @enforce_keys module attribute
defmodule Car do
  @enforce_keys [:make]
  defstruct [:model, :make]
end

# (ArgumentError) the following keys must also be given when building struct Car: [:make]
%Car{}
