# Enumerables and streams

## Enumerables

#Elixir provides the concept of enumerables and the Enum module to work with them. The Enum module provides a huge range of functions to transform, sort, group, filter and retrieve items from enumerables. It is one of the modules developers use frequently in their Elixir code.

#The list and the maps are enums.


# 2,4,6
Enum.map(1..3, fn x -> x * 2 end)
# 6
Enum.reduce(1..3, 0, &+/2)


#The functions in the Enum module are limited to, as the name says, enumerating values in data structures. For specific operations, like inserting and updating particular elements, you may need to reach for modules specific to the data type. For example, if you want to insert an element at a given position in a list, you should use the List.insert_at/3 function from the List module



#the Enum module can work with any data type that implements the Enumerable protocol

## Eager vs Lazy

#All the functions in the Enum module are 'eager'. Many functions expect an enumerable and return a list back:


# list of odds
odd? = &(rem(&1, 2) != 0)
# [1,3]
Enum.filter(1..3, odd?)


#This means that when performing multiple operations with Enum, each operation is going to generate an intermediate list until we reach the result:


1..100_000
|> Enum.map(&(&1 * 3))
|> Enum.filter(odd?)
# 7500000000
|> Enum.sum()

# First start with a range, then multiply each element by 3, then create a new list with odds and finally sum all the elements


## The pipe operator |>

#it takes the output from the expression on its left side and passes it as the first argument to the function call on its right side. It’s similar to the Unix | operator. Its purpose is to highlight the data being transformed by a series of functions.

## Streams

#As an alternative to Enum, Elixir provides the Stream module which supports lazy operations:


1..100_000
|> Stream.map(&(&1 * 3))
|> Stream.filter(odd?)
|> Enum.sum()

7_500_000_000


#Instead of generating intermediate lists, streams build a series of computations that are invoked only when we pass the underlying stream to the Enum module. Streams are useful when working with large, possibly infinite, collections.



#Many functions in the Stream module accept any enumerable as an argument and return a stream as a result. It also provides functions for creating streams. For example, Stream.cycle/1 can be used to create a stream that cycles a given enumerable infinitely. Be careful to not call a function like Enum.map/2 on such streams, as they would cycle forever:



#streams can be very useful for handling large files or even slow resources like network resources.



#use Enum almost always and only move to Stream for the particular scenarios where laziness is required
