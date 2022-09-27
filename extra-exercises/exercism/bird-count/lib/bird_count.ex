defmodule BirdCount do
  def today([]), do: nil
  def today([head | _tail]), do: head

  def increment_day_count([]), do: [1]
  def increment_day_count([head|tail]), do: [head + 1 | tail]

  def has_day_without_birds?([]), do: false
  def has_day_without_birds?([0| _tail]), do: true
  def has_day_without_birds?([_head | tail]), do: has_day_without_birds?(tail)
    

  def total([]), do: 0
  def total([head | tail]), do: head + total(tail)

  def busy_days(list), do: busy_days(list, 0)
  defp busy_days([], count), do: count
  defp busy_days([head | tail], count) when head >= 5, do: busy_days(tail, count + 1)
  defp busy_days([_head | tail], count), do: busy_days(tail, count)
  
end
