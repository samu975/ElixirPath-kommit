defmodule LogLevel do
  def to_label(level, legacy?) do
    cond do 
      level === 0 and not legacy? -> :trace
      level === 1 -> :debug
      level === 2 -> :info 
      level === 3 -> :warning
      level === 4 -> :error
      level === 5 and not legacy? -> :fatal
      true -> :unknown
    end
  end

  def alert_recipient(level, legacy?) do
    cond do 
      to_label(level, legacy?) === :error || to_label(level, legacy?) === :fatal -> :ops
      to_label(level, legacy?) === :unknown && legacy? === true -> :dev1
      to_label(level, legacy?) === :unknown -> :dev2
      true -> nil
    end
  end
end
