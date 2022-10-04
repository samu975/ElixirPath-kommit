# Pattern matching


## Match operator

# In elixir the = doesn't work like other programming languajes. It's not a equivalence o assignament operator. In elixir the = works like a match operator, it means, that you have two parts and the left side it has to match to the right part.

# For example:


x = 9
10 - x
# in this example x it's the same that 9, so if you rest 10 - x it's equal to 1


# lets try to match other number with x
2 = x
# the result is a match error because the left side it's not equal to the right side.

# Be careful with the match operator; variables must always be written on the left side. It is not the same x = 2 to 2 = x because the first one would be saying that x has the same value as 2 while the right one gives an error.

## Pattern matching


# The match operator also works for more complex data such as tuples or lists.


{a, b, c} = {8, 13, 15}


# In this case we are telling elixir that the elements a, b and c are equal to 8, 13, 15; therefore; if we invoke element c it equals 15.


# Be careful with the equivalence operator in two cases:

# -Both sides must have the same number of elements.

# -Both sides must be the same data type.


{a, b, c} = {:apple, "Hello"}
# Match error because the left side has two elements and the right side has three


[a, b, c] = {1, 2, 3}
# Match error because the left side is a list and the right side is a tuple


[head | tail] = [1, 2, 3, 4, 5]
# You can use in list the head tail format to separate the list or add new elements to the list
list = [2, 3, 4, 5]
[2 | list]
# add a new element to the list

## Pin operator ^

# In elixir, you can reassign values. The pin operator causes a previously stored value to be taken. For example:


x = 2
x = 4
# this is possible because you can reasign a value


y = 5
^y = 3
# this is not posible because the pin operator takes the value of 5 and assign to y.

# examples of the usefulness of the pin operator:


{^x, y, z} = {4, 5, 6}

# In this example x is previously defined as 4, so the pin operator is used to take that value. When comparing the two sides elixir notices that x have a value of 4 so it assumes that y & z equal the same as the right side so it assigns them the value 5 and 6.

# The underscore represents something that should be ignored, it is useful in this example:


[head | _] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# head would take the first element
_
# the underscore can not read
