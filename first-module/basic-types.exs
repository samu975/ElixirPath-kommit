# basic types

## data types



1 # integer
1.0 # float
true # bool
[1,2,3] # list
{1,2,3} # tuples
"Strings" #strings
:atom # atom or symbol


## Arithmetic operations


# sum
1 + 5



# multiply
5 * 5



# division with float result
10 / 2



# division with integer result
div(10, 2)



# residual of the division
rem(10, 3)



# round to up
round(3.547)



# round to down
trunc(3.547)


## Identifying functions

# h trunc/1 : when we want to know what a function does from the iex in elixir we can put the command h followed by a function + /  + number of parameters it receives

# The function can be accessed by its name or by the number of parameters, for example: trunc would be the function that only takes the integer of a floating number, while trunc/2 does not exist.

## Boolean values


# elixir has two boolean values true and false
true == false



# To know if a value is a boolean you can use funcion is_boolean/1
is_boolean(true)


# In elixir exist other functions such as s_integer for integers, is_float for floats or is_number for both cases

## Symbols o atomos


:melon
:apple
:orange



:melon == :apple


# According to the documentation an atom express states of an operation like :ok or :error.
# An atom is a data type whose value is its own name. They are especially useful for encoding words.

# !important boolean values are also atoms; words beginning with capital letters are also considered atoms; nil is also an atom and is equal to null in other programming languages.


is_atom(Hello)


## String


"hello"



# a string can has interpolation with atoms or numbers
string = :wold
"Hello #{string}"



# Line breaks can be made
"Hello \nworld"



string = "hello"
string2 = "HELLLOOOOOOOOOOOOOOOOOOOOOOW"



# to know the length of a string
String.length(string)



# transformar en uppercase
String.upcase(string)



# transform to lowercase
String.downcase(string2)



#capitalize the word
String.capitalize(string2)


## Anonymous functions

# Anonymous functions can be invoked with the word fn and always end with the word 'end'.


sum = fn a, b -> a + b end
sum.(5, 3)


# To verify if it is a function you can use the word is_function. This function receives two parameters, the first one is the function to evaluate and the second one is the number of parameters that the function has.

is_function(sum, 1)



is_function(sum, 2)


# !important, functions can receive other functions as parameters or use other functions into them, but, functions cannot rewrite variables that were defined outside the function or rewrite other functions.


other_function = fn number -> sum.(number, number) end
other_function.(8)



x = 50
error_function = (fn -> x = 10 end).()


## List


# the lists can be of any type
list1 = [1, 2, 3, 4, true, :apple]



# function to know the length
length(lista1)



list2 = [8, 9, 10, false]
concat_list = list1 ++ list2
# It is possible to concat two lists



list3 = [3, 4, true, 10]
substracted_list = concat_list -- lista3
# values can be subtracted from a list



hd(substracted_list)
# hd or head is used to know the first element of a list.



tl(list1)
# tl or tail is used to look at the elements of a list without counting the head


## Tuples

# The tuples are stored continuously in memory, therefore, accessing the elements of the tuples is faster.


new_tuple = {1, 2, 3, 4, true, :apple}
# Tuples such as lists can receive any element



tuple_size(new_tuple)
# To know the tuple size



elem(new_tuple, 0)
# to know the element of a tuple, use elem and start counting from index 0.



put_elem(tupla_nueva, 0, "nueva palabra")
# to add a new element


## Currency Converter Challenge


dollar_value_to_peso = 4411.48
dollars_to_pesos_converter = fn dollars_to_convert -> dollars_to_convert * dollar_value_to_peso end
trunc(dollars_to_pesos_converter.(250))

# Function to convert from dollars to pesos



peso_value_to_dollar = 0.00022731600613753
pesos_to_dollars_converter = fn pesos_to_convert -> pesos_to_convert * peso_value_to_dollar end
result = pesos_to_dollars_converter.(1_102_870)
trunc(result)

# function to convert from pesos to dollars
