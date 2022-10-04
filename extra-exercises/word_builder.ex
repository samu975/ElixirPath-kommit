defmodule WordBuilder do
  # def build(alphabet, positions) do
  #   partials = fn at -> String.at(alphabet, at) end
  #   letters = Enum.map(positions, partials)
  #   Enum.join(letters)
  # end

  #Same but with function capturing
  def build(alphabet, positions) do
    letters = Enum.map(positions, &(String.at(alphabet, &1)))
    Enum.join(letters)
  end
end
