defmodule Recursivity do
  def up_to(0), do: 0
  def up_to(x) do
    x + (up_to(x - 1))
  end

  def list_sum([], acc), do: acc
  def list_sum(list, acc)  do
    [head | tail] = list
    result = acc + head
    list_sum(tail,result)
  end

  def add_element_to_list(element, list), do: [element | list]

  def factorial(0), do: 1
  def factorial(x) when x > 0 do
    x * factorial(x - 1)
  end
  def factorial(x) when x < 0 do
    "no esta permitido"
  end

  def max_number([], max), do: max
  def max_number(list_numbers, max) do
    [head | tail] = list_numbers
    if max > head do
      max_number(tail, max)
    else
      max_number(tail, head)
    end
  end

  def min_number([], min), do: min
  def min_number(list_numbers, min) do
    [head | tail] = list_numbers
    if min < head do
      min_number(tail, min)
    else
      min_number(tail, head)
    end
  end
end
