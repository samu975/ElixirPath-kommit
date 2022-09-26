defmodule KitchenCalculator do
  def get_volume({_unit, volume}) do
    volume
  end

  def to_milliliter({unit, volume}) do
    {:milliliter, volume * transform(unit)}
  end

  def from_milliliter({:milliliter, volume}, unit) do
    {unit, volume / transform(unit)}
  end

  def convert({unit1, volume}, unit) do
    milliliters_transform = to_milliliter({unit1, volume})
    from_milliliter(milliliters_transform, unit)
  end

  defp transform(:cup), do: 240
  defp transform(:fluid_ounce), do: 30
  defp transform(:teaspoon), do: 5
  defp transform(:tablespoon), do: 15
  defp transform(:milliliter), do: 1
end
