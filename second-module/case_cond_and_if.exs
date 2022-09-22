# case, cond, and if

## Case

#Allows us to compare a value with many patterns until we find the first one that matches.


case {1, 2, 3} do
  {4, 5, 6} ->
    "this clouse don't match"

  # this clouse print
  {1, x, 3} ->
    'this clouse will match and bind x to 2'

  _ ->
    "this clouse will match for default but our case will match with the first clouse so this clouse never print"
end



x = 20

case 20 do
  ^x -> "Will match"
  _ -> "won't match"
end

# pin operator can be used inside a case



case {1, 2, 3} do
  {1, x, 3} when x > 0 -> "will match because 2 is greater than 0"
  _ -> "only match if the condition was satisfay"
end


#With case, if any case is matched there will be an exception.

## Cond

#case is useful when you need to match the result with different values. In the cond case, you check the result with different conditionals and find the first one that does not give nil or false.


cond do
  2 + 2 == 5 -> "this will not be true"
  2 * 2 == 3 -> "this neither"
  1 + 1 == 2 -> "This will!!!"
end



number = 512

cond do
  rem(number, 2) == 0 && rem(number, 3) == 0 -> "FizzBuzz"
  rem(number, 2) == 0 -> "Fizz"
  rem(number, 3) == 0 -> "Buzz"
  # this is equal to else
  true -> "#{number}"
end

# A simple fizz buzz for practice


## If

#If look for a condition to be true


if true do
  "This block works"
end



# if the result is nil, the block never will executed
if nil do
  "this block never will executed"
else
  "This will"
end


## Unless

#unless look for a condition to be false


unless false do
  "This block is false"
end



unless true do
  "This block never will executed"
else
  "This will"
end

# although the unless block accepts the else block, its use is not recommended. It is recommended to use the if block instead of the unless block.


#!Important. If a variable is declared or changed within a block, the declaration and changes will only be visible within the block.


#To change a global variable within a conditional or another similar block (not recommended) the following is done:


x = 1

x =
  if true do
    x + 2
  end

x
# The variable x was change
