# Sigils

## Regular expressions


# are one of the mechanisms provided by the language for working with textual representations. Sigils start with the tilde (~) character which is followed by a letter (which identifies the sigil) and then a delimiter; optionally, modifiers can be added after the final delimiter.
# The most common sigil in Elixir is ~r, which is used to create regular expressions:
regex = ~r/foo|bar/
# true
"foo" =~ regex

# Elixir provides Perl-compatible regular expressions (regexes), as implemented by the PCRE library. Regexes also support modifiers. For example, the i modifier makes a regular expression case insensitive:
# true
"HELLO" =~ ~r/hello/i


## Strings, char lists, and word lists sigils


# Besides regular expressions, Elixir ships with three other sigils.

## Strings
# The ~s sigil is used to generate strings, like double quotes are. The ~s sigil is useful when a string contains double quotes:

# "this is a string with \"double\" quotes, not 'single' ones"
~s(this is a string with "double" quotes, not 'single' ones)

## Char lists
# The ~c sigil is useful for generating char lists that contain single quotes:

~c(this is a char list containing 'single quotes')

## Word lists
# The ~w sigil is used to generate lists of words (words are just regular strings). Inside the ~w sigil, words are separated by whitespace.
# ["foo", "bar", "bat"]
~w(foo bar bat)

# The ~w sigil also accepts the c, s and a modifiers (for char lists, strings, and atoms, respectively), which specify the data type of the elements of the resulting list:
# [:foo, :bar, :bat]
~w(foo bar bat)a


## Interpolation and escaping in string sigils


# Elixir supports some sigil variants to deal with escaping characters and interpolation.

# The following escape codes can be used in strings and char lists:

# \\ – single backslash
# \a – bell/alert
# \b – backspace
# \d - delete
# \e - escape
# \f - form feed
# \n – newline
# \r – carriage return
# \s – space
# \t – tab
# \v – vertical tab
# \0 - null byte
# \xDD - represents a single byte in hexadecimal (such as \x13)
# \uDDDD and \u{D...} - represents a Unicode codepoint in hexadecimal (such as \u{1F600})

# Sigils also support heredocs, that is, three double-quotes or single-quotes as separators:
~s"""
this is
a heredoc string
"""

# "this is \na heredoc string\n"

# The most common use case for heredoc sigils is when writing documentation.

@doc """
Converts double-quotes to single-quotes.

## Examples

    iex> convert("\\\"foo\\\"")
    "'foo'"

"""


## Calendar sigils


## Date
# A %Date{} struct contains the fields year, month, day, and calendar. You can create one using the ~D sigil:
d = ~D[2019-10-31]
# 31
d.day

## Time
# The %Time{} struct contains the fields hour, minute, second, microsecond, and calendar. You can create one using the ~T sigil:

t = ~T[23:00:07.0]
# 7
t.second

## NaiveDateTime
# The %NaiveDateTime{} struct contains fields from both Date and Time. You can create one using the ~N sigil:

# [2019-10-31 23:00:07]
ndt = ~N[2019-10-31 23:00:07]

## UTC DateTime
dt = ~U[2019-10-31 19:59:03Z]
%DateTime{minute: minute, time_zone: time_zone} = dt
# 59
minute
