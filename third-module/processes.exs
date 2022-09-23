# Processes

## Introduction

#In Elixir, all code runs inside processes. Processes are isolated from each other, run concurrent to one another and communicate via message passing. Processes are not only the basis for concurrency in Elixir, but they also provide the means for building distributed and fault-tolerant programs.

## spawn

#The basic mechanism for spawning new processes is the auto-imported spawn/1 function:


# PID<0.43.0> PID = process identifier
pid = spawn(fn -> 1 + 2 end)

# spawn/1 takes a function which it will execute in another process.
# At this point, the process you spawned is very likely dead. The spawned process will execute the given function and exit after the function is done:
Process.alive?(pid)


## send and receive

#We can send messages to a process with send/2 and receive them with receive/1:


send(self(), {:world, "world"})

receive do
  {:hello, msg} -> msg
  {:world, _msg} -> "won't match"
end

# won't match


#When a message is sent to a process, the message is stored in the process mailbox. The receive/1 block goes through the current process mailbox searching for a message that matches any of the given patterns. receive/1 supports guards and many clauses, such as case/2.

#The process that sends the message does not block on send/2, it puts the message in the recipient’s mailbox and continues. In particular, a process can send messages to itself.

#If there is no message in the mailbox matching any of the patterns, the current process will wait until a matching message arrives. A timeout can also be specified:


receive do
  {:hello, msg} -> msg
after
  4_000 -> "nothing after 4s"
end

# "nothing after 4s"


## Links

#The majority of times we spawn processes in Elixir, we spawn them as linked processes. The procces are insolated so if we want the failure in one process to propagate to another one, we have to link them with spawn_link


self()
spawn_link(fn -> raise "oops" end)
# result: [error] Process #PID<0.289.0> raised an exception
# ** (RuntimeError) oops
# Because processes are linked, we now see a message saying the parent process, which is the shell process, has received an EXIT signal from another process causing the shell to terminate
# Processes and links play an important role when building fault-tolerant systems. Elixir processes are isolated and don’t share anything by default. Therefore, a failure in a process will never crash or corrupt the state of another process.
# While other languages would require us to catch/handle exceptions, in Elixir we are actually fine with letting processes fail because we expect supervisors to properly restart our systems. “Failing fast” (sometimes referred as “let it crash”) is a common philosophy when writing Elixir software!


## Tasks

#Tasks build on top of the spawn functions to provide better error reports and introspection:

Task.start(fn -> raise "oops" end)

## State

#If you are building an application that requires state, for example, to keep your application configuration, or you need to parse a file and keep it in memory, we stored in a process.

#We can write processes that loop infinitely, maintain state, and send and receive messages.


defmodule KV do
  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send(caller, Map.get(map, key))
        loop(map)

      {:put, key, value} ->
        loop(Map.put(map, key, value))
    end
  end
end


#Using processes to maintain state and name registration are very common patterns in Elixir applications. However, most of the time, we won’t implement those patterns manually as above, but by using one of the many abstractions that ship with Elixir.
