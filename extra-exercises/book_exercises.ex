#Create an expression that solves the following problem: Sarah has bought
#ten slices of bread for ten cents each, three bottles of milk for two dollars
#each, and a cake for fifteen dollars. How many dollars has Sarah spent?


bread = fn (slices) -> slices * 0.10 end
milk = fn (bottles) -> bottles * 2 end
cake = fn (how_many) -> how_many * 15 end

sum_of_the_bought = round(bread.(10) + milk.(3) + cake.(1))
result = "Sarah spent #{sum_of_the_bought} dollars"

IO.inspect(result)


#Bob has traveled 200 km in four hours. Using variables, print a message showing his travel distance, time, and average velocity.

travel_distance = 200
travel_time =  4
average_velocity = travel_distance / travel_time

print_message = fn -> IO.inspect("Travel distance: #{travel_distance} km\nTravel time: #{travel_time} hours\nAverage velocity: #{average_velocity}k/h")end
print_message.()

#Build an anonymous function that applies a tax of 12% to a given price. It should print a message with the new price and tax value. Bind the anonymous function to a variable called apply_tax. You should use apply_tax with Enum.each/2,

tax_percentage = 12
apply_tax = fn (price) ->
    price_taxes = price / tax_percentage
    result = price - price_taxes
    IO.inspect("Price: #{price} - Tax: #{price_taxes} = #{result} dollars")
end

Enum.each [12.5, 30.99, 250.49, 18.80], apply_tax
