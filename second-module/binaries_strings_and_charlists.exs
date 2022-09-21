# Binaries, strings, and charlists

## Unicode and Code Points

#The Unicode Standard acts as an official registry of virtually all the characters we know: this includes characters from classical and historical texts, emoji, and formatting and control characters as well.


#Unicode organizes all of the characters in its repertoire into code charts, and each character is given a unique numerical index. This numerical index is known as a Code Point.


# In Elixir you can use a ? in front of a character literal to reveal its code point:
?^ #94


#We can use hexadecimal code with this format \uhexadecimal


"\u0061" == "a" #true


## UTF-8 and Encodings

#Encoding is an implementation. In other words, we need a mechanism to convert the code point numbers into bytes so they can be stored in memory, written to disk, etc.

#Elixir uses UTF-8 to encode its strings, which means that code points are encoded as a series of 8-bit bytes


string = "héllo"
byte_size(string) #7


## Bitstrings

#Bitstring is a fundamental data type in Elixir, denoted with the <<>> syntax. A bitstring is a contiguous sequence of bits in memory.


#With bitstring you can store a number and tell it how much space it should have.


# first we put the number we want stored, then, separated with :: put the number of bits for storage
<<14::4>>



# Multiple values can be used in this way:
<<14::4, 19::4, 8::4>>


## Binaries

#A binary is a bitstring where the number of bits is divisible by 8. That means that every binary is a bitstring, but not every bitstring is a binary.


# True
is_bitstring(<<3::4>>)
# False
is_binary(<<3::4>>)


#The string concatenation operator <> is actually a binary concatenation operator:


# aha
"a" <> "ha"
# <<0,1,2,3>>
<<0, 1>> <> <<2, 3>>



# we can also pattern match on strings:
<<head, rest::binary>> = "banana"
# true
head == ?b
# anana
rest






## Charlists

#A charlist is a list of integers where all the integers are valid code points. In practice, you will not come across them often, only in specific scenarios such as interfacing with older Erlang libraries that do not accept binaries as arguments.


# hello
[?h, ?e, ?l, ?l, ?o]



# hello
[104, 101, 108, 108, 111]


#A common mistake in elixir is when we want to use a list of numbers and we end up using a charlist.
