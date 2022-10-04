# Basic operators

## concat strings

### If you want to concat strings you can use the <> operator, like this:


"Hello" <> " " <> "Wold"


## Booleans operators

# You can use the and, or, or, not operators; they strictly have to be on boolean values.

# They are called "short-circuit" because they only evaluate the right side if the left side is not sufficient by itself to give the result.


false or is_atom(:masmelo)



true or is_boolean("not boolean")

# in this case, for example, the or operator results in true if at least one of the elements is true, so it does not evaluate the second element.



false and raise('This message should not appear')
# raise is used to create exceptions


## And, or, not flexible operators

# Elixir provides the || && ! operators. They are the same as or, and and not but are flexible to any type of data, therefore, if you need to operate with two booleans you use the strict ones, and if you want to operate with any other type of data you use these operators.


1 || false



nil && 13
# nil is considered a false value, so it prints the value nil



!13
# 13 is considered as true, therefore denying it gives false


## Comparison operators

## Elixir has Comparison operators like:

# '==' : to compare if the left side is equal to the right side.

# '!=' : to compare if the left side is different than the right side.

# '===' : to compare if the left side is strictly equal to the right side.

# '!==' : .... is strictly diferente than the right side.

# '<=' : .... is less or equal to the right.

# '>=' : .... is greater or equal to the right.

# '<' : ....... less ......

# '>' : ...... greater .....


1 === 1.0
# is false because the first one in an integer and the other one is a float.



nil != false
# nil is considered to be a false value but is not false, therefore, it gives false



5 < :atom


# The ranking order from lowest to highest is:

# number < atom < reference < function < port < pid < tuple < map < list < bitstring


"How are you? " > ["How are you?"]
