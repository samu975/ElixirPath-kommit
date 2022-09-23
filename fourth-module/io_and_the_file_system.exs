# IO and the file system

## IO module

#The IO module is the main mechanism in elixir for reading and writing to standard input/output, sntandard error, files, etc.


# print hello world
IO.puts("hello world")
# ask to the user yes or not and print the answer
IO.gets("yes or no? ")


#By default, functions in the IO module read from the standard input and write to the standard output


# we chang the order and now IO write to the standard error device
IO.puts(:stderr, "hello world")


## File module

#The File module contains functions that allow us to open files as IO devices. By default, files are opened in binary mode, which requires developers to use the specific IO.binread/2 and IO.binwrite/2 functions from the IO module:


{:ok, file} = File.open("path/to/file/hello", [:write])
{:ok, #PID<0.47.0>}
IO.binwrite(file, "world")
:ok
File.close(file)
:ok
File.read("path/to/file/hello")
{:ok, "world"}

#this expression doesn't work because the file doesn't exist but, the expression write hello to the file.
#A file can also be opened with :utf8 encoding, which tells the File module to interpret the bytes read from the file as UTF-8-encoded bytes.


#Besides functions for opening, reading and writing files, the File module has many functions to work with the file system. Those functions are named after their UNIX equivalents. For example, File.rm/1 can be used to remove files, File.mkdir/1 to create directories, File.mkdir_p/1 to create directories and all their parent chain. There are even File.cp_r/2 and File.rm_rf/1 to respectively copy and remove files and directories recursively



#The file module have two variants: one regular and another variant with a ! at the end. for example File.read/ and File.read!/
#the version with ! returns the contents of the file instead of a tuple, and if anything goes wrong the function raises an error
#The version without ! is preferred when you want to handle different outcomes using pattern matching:


case File.read("path/to/file/hello") do
  {:ok, body} -> # do something with the `body`
  {:error, reason} -> # handle the error caused by `reason`
end
# if you expect the file to be there, the bang variation is more useful as it raises a meaningful error message. Avoid writing:
{:ok, body} = File.read("path/to/file/unknown")

#Therefore, if you don’t want to handle the error outcomes, prefer use the functions ending with an exclamation mark, such as File.read!/1.


## Path module

#The majority of the functions in the File module expect paths as arguments. Most commonly, those paths will be regular binaries. The Path module provides facilities for working with such paths


# foo/bar
Path.join("foo", "bar")
# c:/users/safer/hello
Path.expand("~/hello")


#Using functions from the Path module as opposed to directly manipulating strings is preferred since the Path module takes care of different operating systems transparently. Finally, keep in mind that Elixir will automatically convert slashes (/) into backslashes (\) on Windows when performing file operations.

## Processes

#IO module actually works with processes.

#Given a file is a process, when you write to a file that has been closed, you are actually sending a message to a process which has been terminated:


# close the file and the console return :ok
File.close(file)
# return {:error, :terminated} because the proceses finish
IO.write(file, "is anybody out there")


## iodata and chardata

#most of the IO functions in Elixir also accept either “iodata” or “chardata”. One of the main reasons for using “iodata” and “chardata” is for performance.


name = "Mary"
IO.puts(["Hello ", name, "!"])

# There is no copying. Instead we create a list that contains the original name. We call such lists either “iodata” or “chardata”


#Those lists are very useful because it can actually simplify the processing strings in several scenarios. For example


# using enum
Enum.intersperse(["apple", "banana", "lemon"], ",")



IO.puts(["apple", [",", "banana", [",", "lemon"]]])

# “iodata” and “chardata” do not only contain strings, but they may contain arbitrary nested lists of strings too


#The difference between “iodata” and “chardata” is precisely what said integer represents. For iodata, the integers represent bytes. For chardata, the integers represent Unicode codepoints. For ASCII characters, the byte representation is the same as the codepoint representation, so it fits both classifications. However, the default IO device works with chardata



#there is one last construct called charlist, which is a special case of chardata where we have a list in which all of its values are integers representing Unicode codepoints. They can be created with the ~c sigil:


# hello
~c"hello"
# any list containing printable ASCII codepoints will be printed as a charlist
[?a, ?b, ?c]


## Resume

#iodata and chardata are lists of binaries and integers. Those binaries and integers can be arbitrarily nested inside lists. Their goal is to give flexibility and performance when working with IO devices and files



#the choice between iodata and chardata depends on the encoding of the IO device. If the file is opened without encoding, the file expects iodata, and the functions in the IO module starting with bin* must be used. The default IO device (:stdio) and files opened with :utf8 encoding work expect chardata and work with the remaining functions in the IO module



#charlists are a special case of chardata, where it exclusively uses a list of integers Unicode codepoints. They can be created with the ~c sigil. Lists of integers are automatically printed using the ~c sigil if all integers in a list represent printable ASCII codepoints.
