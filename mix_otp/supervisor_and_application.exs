# Supervisor and Application

## Recap


# Before we added monitoring, if a bucket crashed, the registry would forever point to a bucket that no longer exists. If a user tried to read or write to the crashed bucket, it would fail.Any attempt at creating a new bucket with the same name would just return the PID of the crashed bucket. In other words, that registry entry for that bucket would forever be in a bad state.
# Once we added monitoring, the registry automatically removes the entry for the crashed bucket. Trying to lookup the crashed bucket now (correctly) says the bucket does not exist and a user of the system can successfully create a new one if desired.

# Therefore, an Elixir developer prefers to “let it crash” or “fail fast”. And one of the most common ways we can recover from a failure is by restarting whatever part of the system crashed.
# In Elixir, we apply this same approach to software: whenever a process crashes, we start a new process to perform the same job as the crashed process.
# this is done by a Supervisor. A Supervisor is a process that supervises other processes and restarts them whenever they crash. To do so, Supervisors manage the whole life-cycle of any supervised processes, including startup and shutdown


## Supervisor


#A supervisor is a process which supervises other processes, which we refer to as child processes. The act of supervising a process includes three distinct responsibilities. The first one is to start child processes. Once a child process is running, the supervisor may restart a child process, either because it terminated abnormally or because a certain condition was reached
#For example, a supervisor may restart all children if any child dies. Finally, a supervisor is also responsible for shutting down the child processes when the system is shutting down. Please see the Supervisor module for a more in-depth discussion.

#Creating a supervisor is not much different from creating a GenServer. We are going to define a module named KV.Supervisor
defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      KV.Registry
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

#Our supervisor has a single child so far: KV.Registry. After we define a list of children, we call Supervisor.init/2, passing the children and the supervision strategy.
#The supervision strategy dictates what happens when one of the children crashes. :one_for_one means that if a child dies, it will be the only one restarted. Since we have only one child now, that’s all we need. The Supervisor behaviour supports many different strategies

#Once the supervisor starts, it will traverse the list of children and it will invoke the child_spec/1 function on each module.
#The child_spec/1 function returns the child specification which describes how to start the process, if the process is a worker or a supervisor, if the process is temporary, transient or permanent and so on. The child_spec/1 function is automatically defined when we use Agent, use GenServer, use Supervisor, etc.

iex> KV.Registry.child_spec([])
%{id: KV.Registry, start: {KV.Registry, :start_link, [[]]}}

#After the supervisor retrieves all child specifications, it proceeds to start its children one by one, in the order they were defined, using the information in the :start key in the child specification. For our current specification, it will call KV.Registry.start_link([]).
iex> {:ok, sup} = KV.Supervisor.start_link([])
{:ok, #PID<0.148.0>}
iex> Supervisor.which_children(sup)
[{KV.Registry, #PID<0.150.0>, :worker, [KV.Registry]}]

#So far we have started the supervisor and listed its children. Once the supervisor started, it also started all of its children.

#What happens if we intentionally crash the registry started by the supervisor? Let’s do so by sending it a bad input on call:
iex> [{_, registry, _, _}] = Supervisor.which_children(sup)
[{KV.Registry, #PID<0.150.0>, :worker, [KV.Registry]}]
iex> GenServer.call(registry, :bad_input)
08:52:57.311 [error] GenServer KV.Registry terminating
** (FunctionClauseError) no function clause matching in KV.Registry.handle_call/3
iex> Supervisor.which_children(sup)
[{KV.Registry, #PID<0.157.0>, :worker, [KV.Registry]}]

#Notice how the supervisor automatically started a new registry, with a new PID, in place of the first one once we caused it to crash due to a bad input.



## Naming processes


#While our application will have many buckets, it will only have a single registry. Therefore, whenever we start the registry, we want to give it a unique name so we can reach out to it from anywhere.
#Let’s slightly change our children definition (in KV.Supervisor.init/1) to be a list of tuples instead of a list of atoms:
def init(:ok) do
    children = [
      {KV.Registry, name: KV.Registry}
    ]
#With this in place, the supervisor will now start KV.Registry by calling KV.Registry.start_link(name: KV.Registry).
#If you revisit the KV.Registry.start_link/1 implementation, you will remember it simply passes the options to GenServer:
def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end
#which in turn will register the process with the given name. The :name option expects an atom for locally named processes (locally named means it is available to this machine - there are other options, which we won’t discuss here). Since module identifiers are atoms (try i(KV.Registry) in IEx), we can name a process after the module that implements it, provided there is only one process for that name. This helps when debugging and introspecting the system.
#Let’s give the updated supervisor a try inside iex -S mix:

iex> KV.Supervisor.start_link([])
{:ok, #PID<0.66.0>}
iex> KV.Registry.create(KV.Registry, "shopping")
:ok
iex> KV.Registry.lookup(KV.Registry, "shopping")
{:ok, #PID<0.70.0>}

#This time the supervisor started a named registry, allowing us to create buckets without having to explicitly fetch the PID from the supervisor. You should also know how to make the registry crash again, without looking up its PID: give it a try.
#We are getting closer and closer to a fully working system. The supervisor automatically starts the registry. But how can we automatically start the supervisor whenever our system starts? To answer this question, let’s talk about applications.



## Understanding applications


#We have been working inside an application this entire time. Every time we changed a file and ran mix compile, we could see a Generated kv app message in the compilation output.
#We can find the generated .app file at _build/dev/lib/kv/ebin/kv.app. Let’s have a look at its contents:
{application,kv,
             [{applications,[kernel,stdlib,elixir,logger]},
              {description,"kv"},
              {modules,['Elixir.KV','Elixir.KV.Bucket','Elixir.KV.Registry',
                        'Elixir.KV.Supervisor']},
              {registered,[]},
              {vsn,"0.1.0"}]}.
#This file contains Erlang terms (written using Erlang syntax). Even though we are not familiar with Erlang, it is easy to guess this file holds our application definition. It contains our application version, all the modules defined by it, as well as a list of applications we depend on, like Erlang’s kernel, elixir itself, and logger.
#In a nutshell, an application consists of all of the modules defined in the .app file, including the .app file itself. An application has generally only two directories: ebin, for Elixir artefacts, such as .beam and .app files, and priv, with any other artefact or asset you may need in your application.

#Although Mix generates and maintains the .app file for us, we can customize its contents by adding new entries to the application/0 function inside the mix.exs project file. We are going to do our first customization soon.



## Starting applications


# Each application in our system can be started and stopped. The rules for starting and stopping an application are also defined in the .app file. When we invoke iex -S mix, Mix compiles our application and then starts it.
# Let’s see this in practice. Start a console with iex -S mix and try:

iex > Application.start(:kv)
{:error, {:already_started, :kv}}

# Oops, it’s already started. Mix starts the current application and all of its dependencies automatically. This is also true for mix test and many other Mix commands.
# You can change this behaviour by giving the --no-start flag to Mix. It is rarely used in practice but it allows us to understand the underlying mechanisms better.

# Invoking mix is the same as mix run. Therefore, if you want to pass a flag to mix or iex -S mix, we just need to add the task name and the desired flags. For example, run iex -S mix run --no-start:
iex > Application.start(:kv)
:ok

# We can stop our :kv application as well as the :logger application, which is started by default with Elixir:
iex > Application.stop(:kv)
:ok
iex > Application.stop(:logger)
:ok
# If we start our application again:
iex > Application.start(:kv)
{:error, {:not_started, :logger}}

# Now we get an error because an application that :kv depends on (:logger in this case) isn’t started. We need to either start each application manually in the correct order or call Application.ensure_all_started as follows:
iex > Application.ensure_all_started(:kv)
{:ok, [:logger, :kv]}

# In practice, our tools always start our applications for us, but there is an API available if you need fine-grained control


## The application callback


#Whenever we invoke iex -S mix, Mix automatically starts our application by calling Application.start(:kv). But can we customize what happens when our application starts? As a matter of fact, we can! To do so, we define an application callback.

#The first step is to tell our application definition (i.e. our .app file) which module is going to implement the application callback. Let’s do so by opening mix.exs and changing def application to the following:

def application do
    [
      extra_applications: [:logger],
      mod: {KV, []}
    ]
  end

#The :mod option specifies the “application callback module”, followed by the arguments to be passed on application start. The application callback module can be any module that implements the Application behaviour.
#To implement the Application behaviour, we have to use Application and define a start/2 function. The goal of start/2 is to start a supervisor, which will then start any child services or execute any other code our application may need. Let’s use this opportunity to start the KV.Supervisor we have implemented earlier in this chapter.

#Since we have specified KV as the module callback, let’s change the KV module defined in lib/kv.ex to implement a start/2 function:

defmodule KV do
  use Application

  @impl true
  def start(_type, _args) do
    # Although we don't use the supervisor name below directly,
    # it can be useful when debugging or introspecting the system.
    KV.Supervisor.start_link(name: KV.Supervisor)
  end
end

#When we use Application, we may define a couple of functions, similar to when we used Supervisor or GenServer. This time we only had to define a start/2 function. The Application behaviour also has a stop/1 callback, but it is rarely used in practice. You can check the documentation for more information.
#Now that you have defined an application callback which starts our supervisor, we expect the KV.Registry process to be up and running as soon as we start iex -S mix. Let’s give it another try:
iex> KV.Registry.create(KV.Registry, "shopping")
:ok
iex> KV.Registry.lookup(KV.Registry, "shopping")
{:ok, #PID<0.88.0>}



## Projects or applications?


# Mix makes a distinction between projects and applications. Based on the contents of our mix.exs file, we would say we have a Mix project that defines the :kv application. As we will see in later chapters, there are projects that don’t define any application.

# When we say “project” you should think about Mix. Mix is the tool that manages your project. It knows how to compile your project, test your project and more. It also knows how to compile and start the application relevant to your project.

# When we talk about applications, we talk about OTP. Applications are the entities that are started and stopped as a whole by the runtime.
