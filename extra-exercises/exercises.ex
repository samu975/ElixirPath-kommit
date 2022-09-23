defmodule Exercises do
  def can_get_into(age) do
    if age >= 18 do
      IO.puts("you can go into the bar")
    else
      remaining_years = 18 - age
      IO.puts("you can't go into the bar please come back in #{remaining_years} years")
    end
  end

  def is_admin(boolean) when is_boolean(boolean) === false do
    "No es un booleano"
  end

  def is_admin(boolean) do
    unless boolean do
      "You can't change the website"
    else
      "You can change the website"
    end
  end

  def factorial(0) do
    1
  end

  def factorial(num) do
    num * factorial(num - 1)
  end

end
