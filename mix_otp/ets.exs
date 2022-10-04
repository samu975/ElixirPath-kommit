# ETS

## ETS as a cache


# ETS (Erlang Term Storage) ETS allows us to store any Elixir term in an in-memory table. Working with ETS tables is done via Erlang’s :ets module:
iex> table = :ets.new(:buckets_registry, [:set, :protected])
#Reference<0.1885502827.460455937.234656>
iex> :ets.insert(table, {"foo", self()})
true
iex> :ets.lookup(table, "foo")
[{"foo", #PID<0.41.0>}]

#When creating an ETS table, two arguments are required: the table name and a set of options. From the available options, we passed the table type and its access rules. We have chosen the :set type, which means that keys cannot be duplicated. We’ve also set the table’s access to :protected, meaning only the process that created the table can write to it, but all processes can read from it. The possible access controls:

# :public — Read/Write available to all processes.

# :protected — Read available to all processes. Only writable by owner process. This is the default.

# :private — Read/Write limited to owner process.

#ETS tables can also be named, allowing us to access them by a given name:

iex> :ets.new(:buckets_registry, [:named_table])
:buckets_registry
iex> :ets.insert(:buckets_registry, {"foo", self()})
true
iex> :ets.lookup(:buckets_registry, "foo")
[{"foo", #PID<0.41.0>}]

#Let’s change the KV.Registry to use ETS tables. The first change is to modify our registry to require a name argument, we will use it to name the ETS table and the registry process itself. ETS names and process names are stored in different locations, so there is no chance of conflicts.

defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry with the given options.

  `:name` is always required.
  """
  def start_link(opts) do
    # 1. Pass the name to GenServer's init
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    # 2. Lookup is now done directly in ETS, without accessing the server
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Server callbacks

  @impl true
  def init(table) do
    # 3. We have replaced the names map by the ETS table
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs  = %{}
    {:ok, {names, refs}}
  end

  # 4. The previous handle_call callback for lookup was removed

  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    # 5. Read and write to the ETS table instead of the map
    case lookup(names, name) do
      {:ok, _pid} ->
        {:noreply, {names, refs}}
      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:noreply, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # 6. Delete from the ETS table instead of the map
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end

#n order for the cache mechanism to work, the created ETS table needs to have access :protected (the default), so all clients can read from it, while only the KV.Registry process writes to it. We have also set read_concurrency: true when starting the table, optimizing the table for the common scenario of concurrent read operations.

# The changes we have performed above have broken our tests because the registry requires the :name option when starting up. Furthermore, some registry operations such as lookup/2 require the name to be given as an argument, instead of a PID, so we can do the ETS table lookup. Let’s change the setup function in test/kv/registry_test.exs to fix both issues:

setup context do
    _ = start_supervised!({KV.Registry, name: context.test})
    %{registry: context.test}
  end

#Once we change setup, some tests will continue to fail. You may even notice tests pass and fail inconsistently between runs. For example, the “spawns buckets” test:
test "spawns buckets", %{registry: registry} do
  assert KV.Registry.lookup(registry, "shopping") == :error

  KV.Registry.create(registry, "shopping")
  assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

  KV.Bucket.put(bucket, "milk", 1)
  assert KV.Bucket.get(bucket, "milk") == 1
end

#may be failing on this line:
{:ok, bucket} = KV.Registry.lookup(registry, "shopping")

# The reason those failures are happening is because, for didactic purposes, we have made two mistakes:

## We are prematurely optimizing (by adding this cache layer)
## We are using cast/2 (while we should be using call/2)


## Race conditions?


# Developing in Elixir does not make your code free of race conditions. However, Elixir’s abstractions where nothing is shared by default make it easier to spot a race condition’s root cause.

# What is happening in our tests is that there is a delay in between an operation and the time we can observe this change in the ETS table. Here is what we were expecting to happen:
# # We invoke KV.Registry.create(registry, "shopping")
# # The registry creates the bucket and updates the cache table
# # We access the information from the table with KV.Registry.lookup(registry, "shopping")
# # The command above returns {:ok, bucket}

# However, since KV.Registry.create/2 is a cast operation, the command will return before we actually write to the table! In other words, this is happening:

# # We invoke KV.Registry.create(registry, "shopping")
# # We access the information from the table with KV.Registry.lookup(registry, "shopping")
# # The command above returns :error
# # The registry creates the bucket and updates the cache table

# To fix the failure we need to make KV.Registry.create/2 synchronous by using call/2 rather than cast/2. This will guarantee that the client will only continue after changes have been made to the table. Let’s back to lib/kv/registry.ex and change the function and its callback as follows:

def create(server, name) do
  GenServer.call(server, {:create, name})
end

@impl true
def handle_call({:create, name}, _from, {names, refs}) do
  case lookup(names, name) do
    {:ok, pid} ->
      {:reply, pid, {names, refs}}

    :error ->
      {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      :ets.insert(names, {name, pid})
      {:reply, pid, {names, refs}}
  end
end

# We changed the callback from handle_cast/2 to handle_call/3 and changed it to reply with the pid of the created bucket. Generally speaking, Elixir developers prefer to use call/2 instead of cast/2 as it also provides back-pressure - you block until you get a reply. Using cast/2 when not necessary can also be considered a premature optimization.

# Let’s run the tests once again. This time though, we will pass the --trace option:

mix(test -- trace)

# The --trace option is useful when your tests are deadlocking or there are race conditions, as it runs all tests synchronously (async: true has no effect) and shows detailed information about each test.

# According to the failure message, we are expecting that the bucket no longer exists on the table, but it still does! This problem is the opposite of the one we have just solved: while previously there was a delay between the command to create a bucket and updating the table, now there is a delay between the bucket process dying and its entry being removed from the table. Since this is a race condition, you may not be able to reproduce it on your machine, but it is there.

# Last time we fixed the race condition by replacing the asynchronous operation, a cast, by a call, which is synchronous. Unfortunately, the handle_info/2 callback we are using to receive the :DOWN message and delete the entry from the ETS table does not have a synchronous equivalent. This time, we need to find a way to guarantee the registry has processed the :DOWN notification sent when the bucket process terminated.

# An easy way to do so is by sending a synchronous request to the registry before we do the bucket lookup. The Agent.stop/2 operation is synchronous and only returns after the bucket process terminates and all :DOWN messages are delivered. Therefore, once Agent.stop/2 returns, the registry has already received the :DOWN message but it may not have processed it yet. In order to guarantee the processing of the :DOWN message, we can do a synchronous request. Since messages are processed in order, once the registry replies to the synchronous request, then the :DOWN message will definitely have been processed.

# Let’s do so by creating a “bogus” bucket, which is a synchronous request, after Agent.stop/2 in both “remove” tests at test/kv/registry_test.exs:

test "removes buckets on exit", %{registry: registry} do
  KV.Registry.create(registry, "shopping")
  {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
  Agent.stop(bucket)

  # Do a call to ensure the registry processed the DOWN message
  _ = KV.Registry.create(registry, "bogus")
  assert KV.Registry.lookup(registry, "shopping") == :error
end

test "removes bucket on crash", %{registry: registry} do
  KV.Registry.create(registry, "shopping")
  {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

  # Stop the bucket with non-normal reason
  Agent.stop(bucket, :shutdown)

  # Do a call to ensure the registry processed the DOWN message
  _ = KV.Registry.create(registry, "bogus")
  assert KV.Registry.lookup(registry, "shopping") == :error
end

# Our tests should now (always) pass!

# Note that the purpose of the test is to check whether the registry processes the bucket’s shutdown message correctly. The fact that the KV.Registry.lookup/2 sends us a valid bucket does not mean that the bucket is still alive by the time you call it. For example, it might have crashed for some reason. The following test depicts this situation:

test "bucket can crash at any time", %{registry: registry} do
  KV.Registry.create(registry, "shopping")
  {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

  # Simulate a bucket crash by explicitly and synchronously shutting it down
  Agent.stop(bucket, :shutdown)

  # Now trying to call the dead process causes a :noproc exit
  catch_exit(KV.Bucket.put(bucket, "milk", 3))
end
