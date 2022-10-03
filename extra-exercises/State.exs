defmodule State do
  def counter(), do: counter(0)
  defp counter(value) do
    receive do
      {:get, pid} ->
        send(pid, value)
        counter(value)
      {:inc} ->
        counter(value + 1)
      {:dec} ->
        counter(value - 1)
      {:reset} ->
        counter(0)
    end
  end
end

#for calling the counter we need the pid so we can use the comand pid = spawn(State, :counter, [])
#Then if we want sent a message to the counter we can use te comand send: send(pid, {:get, self()}) This return 0, :ok because the counter is 0.
#if we want to increment the counter we can use send(pid, {:inc})
#then we have tu use again get for change the counter
#and if we want to show the result we use the comand flush()
