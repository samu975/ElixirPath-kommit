# Keyword lists and maps

## Associative structures

#In other languajes exist associative structures like objects, dictionaries, maps, et.

#In elixir there exist two associative structures; the keyword list and maps.

## Keyword list


# this return ["Hello", "", "", "", "world", "", "", "", "", "1", "", "2", "", "", "", "3", "", "", ""]
String.split("Hello    world     1  2    3   ", " ")
# this return ["Hello", "world", "1", "2", "3"]
String.split("Hello    world     1  2    3   ", " ", trim: true)

# this is the same but when the keyword list is at the final we will be able to skip the parentheses
String.split("Hello    world     1  2    3   ", " ", trim: true)



# the second one is syntactic sugar of the first one
[{:trim, true}] == [trim: true]



# A keylist is a list with kay-value elements
list = [a: 1, b: 2, c: 3]
# You can add new elements with the ++ operator
list ++ [c: 3]
# You can add element at the first position in a list
[d: 4] ++ list
# This way you can acces to a value
list[:b]
new_list = [a: 0] ++ list
# if we have 2 equal kays, elixir only shows the first one
new_list[:a]


#It is only recommended to use the keyword list when little data is to be stored because elixir has to go through the whole list to find the element and this can be slow.

## Map

#Maps in elixir are often used


map = %{:a => 1, :b => 2}
map[:a]
#
map[0]



# pattern matching in map
map2 = %{:a => 1, :b => 2, :c => 3}
%{:a => a, :b => b} = map2
# return 1
a
# return 2
b

# map's functions
# returns 1
Map.get(map2, :a)
# return %{a: 1, b: 2, c: 3, d: 34}
Map.put(map2, :d, 34)

# update map keys
# return %{a: 1, b: "two", c: 3}
%{map2 | :b => "two"}

# calling a element with the dot
# return 1
map2.a
# return3
map2.c

# return an error to contrast with the [] notation, if doest't find an element in a map this return nil
map2.d
# return nil
map2[:d]

# When all the elements are atoms you can write them with syntatic sugar

# return true
%{a: 1, b: 2, c: 3} == %{:a => 1, :b => 2, :c => 3}


##Keywords vs Maps

#-The maps dont have an spesific order

#-The maps recive any kind of data

#-If you don't find a valid keyword it return nil, on the contrary, the keyword list return an error

#-maps are usseful with pattern match
