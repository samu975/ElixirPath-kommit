# Agent

## The trouble with state


# Elixir is an immutable language where nothing is shared by default. If we want to share information, which can be read and modified from multiple places, we have two main options in Elixir:

# Using Processes and message passing
# ETS (Erlang Term Storage)

# we rarely hand-roll our own, instead we use the abstractions available in Elixir and OTP:
# Agent - Simple wrappers around state.
# GenServer - “Generic servers” (processes) that encapsulate state, provide sync and async calls, support code reloading, and more.
# Task - Asynchronous units of computation that allow spawning a process and potentially retrieving its result at a later time.


## Agents


# Agents are simple wrappers around state. If all you want from a process is to keep state, agents are a great fit.
{:ok, agent} = Agent.start_link(fn -> [] end)
# return {:ok, #PID<0.57.0>}
Agent.update(agent, fn list -> ["eggs" | list] end)
# return :ok
Agent.get(agent, fn list -> list end)
# return ["eggs"]
Agent.stop(agent)
# return :ok

# We started an agent with an initial state of an empty list. We updated the agent’s state, adding our new item to the head of the list. The second argument of Agent.update/3 is a function that takes the agent’s current state as input and returns its desired new state. Finally, we retrieved the whole list. The second argument of Agent.get/3 is a function that takes the state as input and returns the value that Agent.get/3 itself will return. Once we are done with the agent, we can call Agent.stop/3 to terminate the agent process
# The Agent.update/3 function accepts as a second argument any function that receives one argument and returns a value
{:ok, agent} = Agent.start_link(fn -> [] end)
# return{:ok, #PID<0.338.0>}
Agent.update(agent, fn _list -> 123 end)
# return:ok
Agent.update(agent, fn content -> %{a: content} end)
# return:ok
Agent.update(agent, fn content -> [12 | [content]] end)
# return:ok
Agent.update(agent, fn list -> [:nop | list] end)
# return:ok
iex > Agent.get(agent, fn content -> content end)
# return [:nop, 12, %{a: 123}]

# As you can see, we can modify the agent state in any way we want. Therefore, we most likely don’t want to access the Agent API throughout many different places in our code. Instead, we want to encapsulate all Agent-related functionality in a single module, which we will call KV.Bucket.
defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  test "stores values by key" do
    {:ok, bucket} = KV.Bucket.start_link([])
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end
end

# use ExUnit.Case is responsible for setting up our module for testing and imports many test-related functionality, such as the test/2 macro.
# Our first test starts a new KV.Bucket by calling the start_link/1 and passing an empty list of options. Then we perform some get/2 and put/3 operations on it, asserting the result
# the async: true option passed to ExUnit.Case. This option makes the test case run in parallel with other :async test cases by using multiple cores in our machine. This is extremely useful to speed up our test suite. However, :async must only be set if the test case does not rely on or change any global values.

# Module creation:
defmodule KV.Bucket do
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end

# The first step in our implementation is to call use Agent.
# Then we define a start_link/1 function, which will effectively start the agent. It is a convention to define a start_link/1 function that always accepts a list of options.
# . We then proceed to call Agent.start_link/1, which receives an anonymous function that returns the Agent’s initial state.
# We are keeping a map inside the agent to store our keys and values. Getting and putting values on the map is done with the Agent API and the capture operator &.The agent passes its state to the anonymous function via the &1 argument when Agent.get/2 and Agent.update/2 are called.
# Now that the KV.Bucket module has been defined, our test should pass!


## Test setup with ExUnit callbacks


# ExUnit supports callbacks that allow us to skip such repetitive tasks.
defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end
end

# We have first defined a setup callback with the help of the setup/1 macro. The setup/1 macro defines a callback that is run before every test, in the same process as the test itself.
# When we return %{bucket: bucket} from the callback, ExUnit will merge this map into the test context. Since the test context is a map itself, we can pattern match the bucket out of it, providing access to the bucket inside the test:
test "stores values by key", %{bucket: bucket} do
  # `bucket` is now the bucket from the setup block
end


## Other agent actions


# Besides getting a value and updating the agent state, agents allow us to get a value and update the agent state in one function call via Agent.get_and_update/2.
@doc """
Deletes `key` from `bucket`.

Returns the current value of `key`, if `key` exists.
"""
def delete(bucket, key) do
  Agent.get_and_update(bucket, &Map.pop(&1, key))
end

# deletes a key from the bucket.


## Client/Server in agents


# Expand the delete/2 function:
def delete(bucket, key) do
  Agent.get_and_update(bucket, fn dict ->
    Map.pop(dict, key)
  end)
end

# Everything that is inside the function we passed to the agent happens in the agent process. In this case, since the agent process is the one receiving and responding to our messages, we say the agent process is the server. Everything outside the function is happening in the client.
# This distinction is important. If there are expensive actions to be done, you must consider if it will be better to perform these actions on the client or on the server.
def delete(bucket, key) do
  # puts client to sleep
  Process.sleep(1000)

  Agent.get_and_update(bucket, fn dict ->
    # puts server to sleep
    Process.sleep(1000)
    Map.pop(dict, key)
  end)
end

# When a long action is performed on the server, all other requests to that particular server will wait until the action is done, which may cause some clients to timeout.
