defmodule Secrets do
  def secret_add(secret) do
    fn argument -> argument + secret end 
  end

  def secret_subtract(secret) do
     fn argument -> argument - secret end
  end

  def secret_multiply(secret) do
     fn argument -> argument * secret end
  end

  def secret_divide(secret) do
     fn argument -> div(argument,secret) end
  end

  def secret_and(secret) do
     fn argument -> Bitwise.band(argument, secret) end
  end

  def secret_xor(secret) do
     fn argument -> Bitwise.bxor(argument, secret) end
  end

  def secret_combine(secret_function1, secret_function2) do
     fn (argument) -> 
      first = secret_function1.(argument) 
      secret_function2.(first)
      end
  end
end
