# alias, require, and import

## Introduction


# In order to facilitate software reuse, Elixir provides three directives (alias, require and import) plus a macro called use summarized below:
# Alias the module so it can be called as Bar instead of Foo.Bar
alias Foo.Bar, as: Bar

# Require the module in order to use its macros
require Foo

# Import functions from Foo so they can be called without the `Foo.` prefix
import Foo

# Invokes the custom code defined in Foo as an extension point
use Foo


## alias

#alias allows you to set up aliases for any given module name.


defmodule Stats do
  alias Math.List, as: List
  # In the remaining module definition List expands to Math.List.
end


#Aliases are frequently used to define shortcuts. In fact, calling alias without an :as option sets the alias automatically to the last part of the module name


alias Math.List
# is the same as
alias Math.List, as: List


#alias is lexically scoped, which allows you to set aliases inside specific functions:


defmodule Math do
  def plus(a, b) do
    alias Math.List
  end

  def minus(a, b) do
  end
end

# In the example above, since we are invoking alias inside the function plus/2, the alias will be valid only inside the function plus/2. minus/2 won’t be affected at all.In the example above, since we are invoking alias inside the function plus/2, the alias will be valid only inside the function plus/2. minus/2 won’t be affected at all.


## require

#Elixir provides macros as a mechanism for meta-programming (writing code that generates code). Macros are expanded at compile time.



#Public functions in modules are globally available, but in order to use macros, you need to opt-in by requiring the module they are defined in. like this:


require Integer
Integer.is_odd(3)


## import

#We use import whenever we want to access functions or macros from other modules without using the fully-qualified name. we can only import public functions, as private functions are never accessible externally.


# import the duplicate from the list.
import List, only: [duplicate: 2]

# [:ok, :ok, :ok]
duplicate(:ok, 3)


#import is lexically scoped too. This means that we can import specific macros or functions inside function definitions:


defmodule Math do
  def some_function do
    import List, only: [duplicate: 2]
    duplicate(:ok, 10)
  end
end

# In the example above, the imported List.duplicate/2 is only visible within that specific function. duplicate/2 won’t be available in any other function in that module


## use

#The use macro is frequently used as an extension point. This means that, when you use a module FooBar, you allow that module to inject any code in the current module, such as importing itself or other modules, defining new functions, setting a module state, etc.


defmodule AssertionTest do
  use ExUnit.Case, async: true

  test "always pass" do
    assert true
  end
end

# use requires the given module and then calls the __using__/1 callback on it allowing the module to inject some code into the current context.



defmodule Example do
  use Feature, option: :value
end

# is compiled to
defmodule Example do
  require Feature
  Feature.__using__(option: :value)
end


#use has to be used carefully. We could create side effects if we don't read the documentation. Don't use use where an import or alias would do.

## Understanding aliases.

#An alias in Elixir is a capitalized identifier (like String, Keyword, etc) which is converted to an atom during compilation. For instance, the String alias translates by default to the atom :"Elixir.String":

to_string(String)
"Elixir.String" == String #true

#By using the alias/2 directive, we are changing the atom the alias expands to.

#Aliases expand to atoms because in the Erlang VirtualMachine (and consequently Elixir) modules are always represented by atoms.

## Module nesting

defmodule Foo do
  defmodule Bar do
  end
end
#The example above will define two modules: Foo and Foo.Bar. The second can be accessed as Bar inside Foo as long as they are in the same lexical scope.

#If, later, the Bar module is moved outside the Foo module definition, it must be referenced by its full name (Foo.Bar) or an alias must be set using the alias directive discussed above.

#Note: in Elixir, you don’t have to define the Foo module before being able to define the Foo.Bar module, as they are effectively independent. The above could also be written as:

defmodule Foo.Bar do
end

defmodule Foo do
  alias Foo.Bar
  # Can still access it as `Bar`
end

#aliases play a crucial role in macros, to guarantee they are hygienic.

## Multi alias/import/require/use

#It is possible to alias, import, require, or use multiple modules at once. This is particularly useful on nesting modules, which is very common when building Elixir applications. For example, imagine you have an application where all modules are nested under MyApp, you can alias the modules MyApp.Foo, MyApp.Bar and MyApp.Baz at once as follows:

alias MyApp.{Foo, Bar, Baz}
