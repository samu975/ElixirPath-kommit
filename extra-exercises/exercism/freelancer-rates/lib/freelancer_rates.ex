defmodule FreelancerRates do
  def daily_rate(hourly_rate) do
    hourly_rate * 8.0
  end

  def apply_discount(before_discount, discount) do
    before_discount - ((before_discount * discount) / 100)   
  end

  def monthly_rate(hourly_rate, discount) do
    day = daily_rate(hourly_rate) 
    discount = apply_discount(day, discount)
    discount * 22
    |> Float.ceil
    |> trunc
  end

  def days_in_budget(budget, hourly_rate, discount) do
    daily = daily_rate(hourly_rate)
    discount = apply_discount(daily, discount)
    budget / discount
    |> Float.floor(1)
  end
end
