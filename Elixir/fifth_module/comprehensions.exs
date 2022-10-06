# Comprehensions

## Generators and filters


# In Elixir, it is common to loop over an Enumerable, often filtering out some results and mapping values into another list. Comprehensions are syntactic sugar for such constructs: they group those common tasks into the for special form.
for n <- [1, 2, 3, 4], do: n * n

# Generator expressions also support pattern matching on their left-hand side; all non-matching patterns are ignored.
values = [good: 1, good: 2, bad: 3, good: 4]
# Only multiply the :good values
for {:good, n} <- values, do: n * n

# Alternatively to pattern matching, filters can be used to select some particular elements
for n <- 0..5, rem(n, 3) == 0, do: n * n

# Multiple generators can also be used to calculate the cartesian product of two lists:
for i <- [:a, :b, :c], j <- [1, 2], do: {i, j}


## Bitstring generators


# Bitstring generators are also supported and are very useful when you need to comprehend over bitstring streams.
pixels = <<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
for <<r::8, g::8, b::8 <- pixels>>, do: {r, g, b}


## The :into option


# he result of a comprehension can be inserted into different data structures by passing the :into option to the comprehension.
# "helloworld"
for <<c <- " hello world ">>, c != ?\s, into: "", do: <<c>>

# Sets, maps, and other dictionaries can also be given to the :into option. In general, :into accepts any structure that implements the Collectable protocol.

# A common use case of :into can be transforming values in a map:
# %{"a" => 1, "b" => 4}
for {key, val} <- %{"a" => 1, "b" => 2}, into: %{}, do: {key, val * val}
