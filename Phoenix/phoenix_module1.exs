# Phoenix

## Overview

# Phoenix is a web development framework written in Elixir which implements the server-side Model View Controller (MVC) pattern.
# It´s similar to ruby on rails or django
# Phoenix provides the best of both worlds - high developer productivity and high application performance.


## Installation

# Phoenix is written in Elixir, and our application code will also be written in Elixir.
# we will need to install the Hex package manager. Hex is necessary to get a Phoenix app running (by installing dependencies) and to install any extra dependencies we might need along the way.
mix(local.hex)

# To check that we are on Elixir 1.12 and Erlang 22 or later, run:
elixir(-v)

# Once we have Elixir and Erlang, we are ready to install the Phoenix application generator:
mix(archive.install(hex(phx_new)))

# The phx.new generator is now available to generate new applications The flags mentioned below are command line options to the generator; see all available options by calling mix help phx.new.

## PostgreSQL
# PostgreSQL is a relational database server. Phoenix configures applications to use it by default, but we can switch to MySQL, MSSQL, or SQLite3 by passing the --database flag when creating a new application.

# In order to talk to databases, Phoenix applications use another Elixir package, called Ecto.


## Up and Running

# We can run mix phx.new from any directory in order to bootstrap our Phoenix application. Phoenix will accept either an absolute or relative path for the directory of our new project. Assuming that the name of our application is hello, let's run the following command:
mix(phx.new(hello))
# Phoenix generates the directory structure and all the files we will need for our application.

# When it's done, it will ask us if we want it to install our dependencies for us. Let's say yes to that.
# Once our dependencies are installed, the task will prompt us to change into our project directory and start our application.

# Phoenix assumes that our PostgreSQL database will have a postgres user account with the correct permissions and a password of "postgres".
# Ok, let's give it a try. First, we'll cd into the hello/ directory we've just created:
cd(hello)

# Now we'll create our database:
mix(ecto.create)

# And finally, we'll start the Phoenix server:
mix(phx.server)

# By default, Phoenix accepts requests on port 4000. If we point our favorite web browser at http://localhost:4000, we should see the Phoenix Framework welcome page.
# To stop it, we hit ctrl-c twice.
