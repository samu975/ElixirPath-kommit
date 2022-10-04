# try, catch, and rescue

## Errors


#Elixir has three error mechanisms: errors, throws, and exits. In this chapter, we will explore each of them and include remarks about when each should be used.
#Errors (or exceptions) are used when exceptional things happen in the code.
:foo + 1 #ArithmeticError) bad argument in arithmetic expression: :foo + 1

#A runtime error can be raised any time by using raise/1:
raise "oops"

#Other errors can be raised with raise/2 passing the error name and a list of keyword arguments:
raise ArgumentError, message: "invalid argument foo"

#You can also define your own errors by creating a module and using the defexception construct inside it.
defmodule MyError do
  defexception message: "default message"
end
raise MyError #(MyError) default message

#Errors can be rescued using the try/rescue construct:

try do
  raise "oops"
rescue
  in RuntimeError -> e
end
%RuntimeError{message: "oops"}

#If you don’t have any use for the exception, you don’t have to pass a variable to rescue
try do
  raise "oops"
rescue
  RuntimeError -> "Error!"
end
"Error!"

#in practice, Elixir developers rarely use the try/rescue construct.


## Fail fast / Let it crash


# One saying that is common in the Erlang community, as well as Elixir’s, is “fail fast” / “let it crash”. The idea behind let it crash is that, in case something unexpected happens, it is best to let the exception happen, without rescuing it
# all Elixir code runs inside processes that are isolated and don’t share anything by default. Therefore, an unhandled exception in a process will never crash or corrupt the state of another process. This allows us to define supervisor processes, which are meant to observe when a process terminates unexpectedly, and starts a new one in its place.
# At the end of the day, “fail fast” / “let it crash” is a way of saying that, when something unexpected happens, it is best to start from scratch within a new processes, freshly started by a supervisor, rather than blindly trying to rescue all possible error cases without the full context of when and how they can happen.


## Reraise


# While we generally avoid using try/rescue in Elixir, one situation where we may want to use such constructs is for observability/monitoring.
try do
  ...(some(code(...)))
rescue
  e ->
    Logger.error(Exception.format(:error, e, __STACKTRACE__))
    reraise e, __STACKTRACE__
end

# we rescued the exception, logged it, and then re-raised it. We use the __STACKTRACE__ construct both when formatting the exception and when re-raising. This ensures we reraise the exception as is, without changing value or its origin


## Throws


# In Elixir, a value can be thrown and later be caught. throw and catch are reserved for situations where it is not possible to retrieve a value unless by using throw and catch.
# Those situations are quite uncommon in practice except when interfacing with libraries that do not provide a proper API
try do
  Enum.each(-50..50, fn x ->
    if rem(x, 13) == 0, do: throw(x)
  end)

  "Got nothing"
catch
  x -> "Got #{x}"
end

# "Got -39"


## Exits


# All Elixir code runs inside processes that communicate with each other. When a process dies of “natural causes” (e.g., unhandled exceptions), it sends an exit signal. A process can also die by explicitly sending an exit signal:
# evaluator process exited with reason: 1
spawn_link(fn -> exit(1) end)

# exit signals are an important part of the fault tolerant system provided by the Erlang VM. Processes usually run under supervision trees which are themselves processes that listen to exit signals from the supervised processes. Once an exit signal is received, the supervision strategy kicks in and the supervised process is restarted.


## After


# Sometimes it’s necessary to ensure that a resource is cleaned up after some action that could potentially raise an error. The try/after construct allows you to do that. For example, we can open a file and use an after clause to close it–even if something goes wrong:
{:ok, file} = File.open("sample", [:utf8, :write])

try do
  IO.write(file, "olá")
  raise "oops, something went wrong"
after
  File.close(file)
end

# (RuntimeError) oops, something went wrong


## Variables scope

#Similar to case, cond, if and other constructs in Elixir, variables defined inside try/catch/rescue/after blocks do not leak to the outer context.
#Furthermore, variables defined in the do-block of try are not available inside rescue/after/else either. This is because the try block may fail at any moment and therefore the variables may have never been bound in the first place.
