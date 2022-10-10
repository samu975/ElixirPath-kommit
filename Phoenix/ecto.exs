# Ecto

## Section


# Most web applications today need some form of data validation and persistence. In the Elixir ecosystem, we have Ecto to enable this.
# Phoenix uses Ecto to provide builtin support to the following databases:
# # PostgreSQL (via postgrex)
# # MySQL (via myxql)
# # MSSQL (via tds)
# # ETS (via etso)
# # SQLite3 (via ecto_sqlite3)


## Using the schema and migration generator


#Once we have Ecto and PostgreSQL installed and configured, the easiest way to use Ecto is to generate an Ecto schema through the phx.gen.schema task. Ecto schemas are a way for us to specify how Elixir data types map to and from external sources, such as database tables. Let's generate a User schema with name, email, bio, and number_of_pets fields.
# return :
# mix phx.gen.schema User users name:string email:string \
# bio:string number_of_pets:integer

# * creating ./lib/hello/user.ex
# * creating priv/repo/migrations/20170523151118_create_users.exs

# Remember to update your repository by running migrations:

#    $ mix ecto.migrate


#A couple of files were generated with this task. First, we have a user.ex file, containing our Ecto schema with our schema definition of the fields we passed to the task. Next, a migration file was generated inside priv/repo/migrations/ which will create our database table that our schema maps to.
#With our files in place, let's follow the instructions and run our migration:

mix ecto.migrate
#return
# Compiling 1 file (.ex)
# Generated hello app

# [info]  == Running Hello.Repo.Migrations.CreateUsers.change/0 forward

# [info]  create table users

# [info]  == Migrated in 0.0s


#Mix assumes that we are in the development environment unless we tell it otherwise with MIX_ENV=prod mix ecto.migrate.
#If we log in to our database server, and connect to our hello_dev database, we should see our users table. Ecto assumes that we want an integer column called id as our primary key, so we should see a sequence generated for that as well.

psql -U postgres

# Type "help" for help.

postgres=# \connect hello_dev
# You are now connected to database "hello_dev" as user "postgres".
hello_dev=# \d
#                 List of relations
#  Schema |       Name        |   Type   |  Owner
# --------+-------------------+----------+----------
#  public | schema_migrations | table    | postgres
#  public | users             | table    | postgres
#  public | users_id_seq      | sequence | postgres
# (3 rows)
hello_dev=# \q  ## quit

##And here's what that translates to in the actual users table.
psql
hello_dev=# \d users
# Table "public.users"
# Column         |            Type             | Modifiers
# ---------------+-----------------------------+----------------------------------------------------
# id             | bigint                      | not null default nextval('users_id_seq'::regclass)
# name           | character varying(255)      |
# email          | character varying(255)      |
# bio            | character varying(255)      |
# number_of_pets | integer                     |
# inserted_at    | timestamp without time zone | not null
# updated_at     | timestamp without time zone | not null
# Indexes:
# "users_pkey" PRIMARY KEY, btree (id)



## Repo configuration


# Our Hello.Repo module is the foundation we need to work with databases in a Phoenix application. Phoenix generated it for us in lib/hello/repo.ex, and this is what it looks like.
defmodule Hello.Repo do
  use Ecto.Repo,
    otp_app: :hello,
    adapter: Ecto.Adapters.Postgres
end

# It begins by defining the repository module. Then it configures our otp_app name, and the adapter – Postgres, in our case.
# Our repo has three main tasks - to bring in all the common query functions from [Ecto.Repo], to set the otp_app name equal to our application name, and to configure our database adapter. We'll talk more about how to use Hello.Repo in a bit.
# When phx.new generated our application, it included some basic repository configuration as well. Let's look at config/dev.exs.
# Configure your database
config :hello, Hello.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "hello_dev",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# We also have similar configuration in config/test.exs and config/runtime.exs (formerly config/prod.secret.exs) which can also be changed to match your actual credentials.


## The schema


# Ecto schemas are responsible for mapping Elixir values to external data sources, as well as mapping external data back into Elixir data structures. We can also define relationships to other schemas in our applications. For example, our User schema might have many posts, and each post would belong to a user. Ecto also handles data validation and type casting with changesets, which we'll discuss in a moment.
# Here's the User schema that Phoenix generated for us.

defmodule Hello.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hello.User

  schema "users" do
    field(:bio, :string)
    field(:email, :string)
    field(:name, :string)
    field(:number_of_pets, :integer)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :bio, :number_of_pets])
    |> validate_required([:name, :email, :bio, :number_of_pets])
  end
end

# Ecto schemas at their core are simply Elixir structs. Our schema block is what tells Ecto how to cast our %User{} struct fields to and from the external users table. Often, the ability to simply cast data to and from the database isn't enough and extra data validation is required. This is where Ecto changesets come in. Let's dive in!


## Changesets and validations


#Changesets define a pipeline of transformations our data needs to undergo before it will be ready for our application to use. These transformations might include type-casting, user input validation, and filtering out any extraneous parameters. Often we'll use changesets to validate user input before writing it to the database. Ecto repositories are also changeset-aware, which allows them not only to refuse invalid data, but also perform the minimal database updates possible by inspecting the changeset to know which fields have changed.
#Let's take a closer look at our default changeset function.

def changeset(user, attrs) do
  user
  |> cast(attrs, [:name, :email, :bio, :number_of_pets])
  |> validate_required([:name, :email, :bio, :number_of_pets])
end

#Right now, we have two transformations in our pipeline. In the first call, we invoke Ecto.Changeset.cast/3, passing in our external parameters and marking which fields are required for validation.
#cast/3 first takes a struct, then the parameters (the proposed updates), and then the final field is the list of columns to be updated. cast/3 also will only take fields that exist in the schema.
#Next, Ecto.Changeset.validate_required/3 checks that this list of fields is present in the changeset that cast/3 returns. By default with the generator, all fields are required.
#We can verify this functionality in IEx. Let's fire up our application inside IEx by running iex -S mix. In order to minimize typing and make this easier to read, let's alias our Hello.User struct.

iex -S mix
iex> alias Hello.User
#Hello.User

#Next, let's build a changeset from our schema with an empty User struct, and an empty map of parameters.
changeset = User.changeset(%User{}, %{})
##return:
# #Ecto.Changeset<
#   action: nil,
#   changes: %{},
#   errors: [
#     name: {"can't be blank", [validation: :required]},
#     email: {"can't be blank", [validation: :required]},
#     bio: {"can't be blank", [validation: :required]},
#     number_of_pets: {"can't be blank", [validation: :required]}
#   ],
#   data: #Hello.User<>,
#   valid?: false
# >


##Once we have a changeset, we can check if it is valid.
changeset.valid?
# return: false

changeset.errors
#return: [
#   name: {"can't be blank", [validation: :required]},
#   email: {"can't be blank", [validation: :required]},
#   bio: {"can't be blank", [validation: :required]},
#   number_of_pets: {"can't be blank", [validation: :required]}
# ]

#Now, let's make number_of_pets optional. In order to do this, we simply remove it from the list in the changeset/2 function, in Hello.User.
    |> validate_required([:name, :email, :bio])

#Now casting the changeset should tell us that only name, email, and bio can't be blank. We can test that by running recompile() inside IEx and then rebuilding our changeset.

recompile()
#Compiling 1 file (.ex)
#:ok

changeset = User.changeset(%User{}, %{})
#return:
#Ecto.Changeset<
#   action: nil,
#   changes: %{},
#   errors: [
#     name: {"can't be blank", [validation: :required]},
#     email: {"can't be blank", [validation: :required]},
#     bio: {"can't be blank", [validation: :required]}
#   ],
#   data: #Hello.User<>,
#   valid?: false
# >

changeset.errors
# [
#   name: {"can't be blank", [validation: :required]},
#   email: {"can't be blank", [validation: :required]},
#   bio: {"can't be blank", [validation: :required]}
# ]

#Inside our existing IEx shell, let's create a params map with valid values plus an extra random_key: "random value".
#params = %{name: "Joe Example", email: "joe@example.com", bio: "An example to all", number_of_pets: 5, random_key: "random value"}

#return :
# %{
#   bio: "An example to all",
#   email: "joe@example.com",
#   name: "Joe Example",
#   number_of_pets: 5,
#   random_key: "random value"
#}

#Next, let's use our new params map to create another changeset.
changeset = User.changeset(%User{}, params)
#return:
# #Ecto.Changeset<
#   action: nil,
#   changes: %{
#     bio: "An example to all",
#     email: "joe@example.com",
#     name: "Joe Example",
#     number_of_pets: 5
#   },
#   errors: [],
#   data: #Hello.User<>,
#   valid?: true
#>

changeset.valid?
true

#We can also check the changeset's changes - the map we get after all of the transformations are complete.
changeset.changes
#%{bio: "An example to all", email: "joe@example.com", name: "Joe Example", number_of_pets: 5}


#Notice that our random_key key and "random_value" value have been removed from the final changeset. Changesets allow us to cast external data, such as user input on a web form or data from a CSV file into valid data into our system. Invalid parameters will be stripped and bad data that is unable to be cast according to our schema will be highlighted in the changeset errors.
# We can validate more than just whether a field is required or not. Let's take a look at some finer-grained validations.
#What if we had a requirement that all biographies in our system must be at least two characters long? We can do this easily by adding another transformation to the pipeline in our changeset which validates the length of the bio field.

def changeset(user, attrs) do
  user
  |> cast(attrs, [:name, :email, :bio, :number_of_pets])
  |> validate_required([:name, :email, :bio, :number_of_pets])
  |> validate_length(:bio, min: 2)
end

#Now, if we try to cast data containing a value of "A" for our user's bio, we should see the failed validation in the changeset's errors.
recompile()
changeset = User.changeset(%User{}, %{bio: "A"})
changeset.errors[:bio]
#return: "should be at least %{count} character(s)",




## Data persistence


#We've explored migrations and schemas, but we haven't yet persisted any of our schemas or changesets.
#Ecto repositories are the interface into a storage system, be it a database like PostgreSQL or an external service like a RESTful API. The Repo module's purpose is to take care of the finer details of persistence and data querying for us. As the caller, we only care about fetching and persisting data. The Repo module takes care of the underlying database adapter communication, connection pooling, and error translation for database constraint violations.
#Let's head back over to IEx with iex -S mix, and insert a couple of users into the database.
alias Hello.{Repo, User}
#R:[Hello.Repo, Hello.User]

Repo.insert(%User{email: "user1@example.com"})
# R: [debug] QUERY OK db=6.5ms queue=0.5ms idle=1358.3ms
# INSERT INTO "users" ("email","inserted_at","updated_at") VALUES ($1,$2,$3) RETURNING "id" ["user1@example.com", ~N[2021-02-25 01:58:55], ~N[2021-02-25 01:58:55]]
# {:ok,
#  %Hello.User{
#    __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
#    bio: nil,
#    email: "user1@example.com",
#    id: 1,
#    inserted_at: ~N[2021-02-25 01:58:55],
#    name: nil,
#    number_of_pets: nil,
#    updated_at: ~N[2021-02-25 01:58:55]
#  }}

Repo.insert(%User{email: "user2@example.com"})
# R [debug] QUERY OK db=1.3ms idle=1402.7ms
# INSERT INTO "users" ("email","inserted_at","updated_at") VALUES ($1,$2,$3) RETURNING "id" ["user2@example.com", ~N[2021-02-25 02:03:28], ~N[2021-02-25 02:03:28]]
# {:ok,
#  %Hello.User{
#    __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
#    bio: nil,
#    email: "user2@example.com",
#    id: 2,
#    inserted_at: ~N[2021-02-25 02:03:28],
#    name: nil,
#    number_of_pets: nil,
#    updated_at: ~N[2021-02-25 02:03:28]
#  }}


#We started by aliasing our User and Repo modules for easy access. Next, we called Repo.insert/2 with a User struct. Since we are in the dev environment, we can see the debug logs for the query our repository performed when inserting the underlying %User{} data. We received a two-element tuple back with {:ok, %User{}}, which lets us know the insertion was successful.
#We could also insert a user by passing a changeset to Repo.insert/2. If the changeset is valid, the repository will use an optimized database query to insert the record, and return a two-element tuple back, as above. If the changeset is not valid, we receive a two-element tuple consisting of :error plus the invalid changeset.
#With a couple of users inserted, let's fetch them back out of the repo.

Repo.all(User)
# R: [debug] QUERY OK source="users" db=5.8ms queue=1.4ms idle=1672.0ms
# SELECT u0."id", u0."bio", u0."email", u0."name", u0."number_of_pets", u0."inserted_at", u0."updated_at" FROM "users" AS u0 []
# [
#   %Hello.User{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
#     bio: nil,
#     email: "user1@example.com",
#     id: 1,
#     inserted_at: ~N[2021-02-25 01:58:55],
#     name: nil,
#     number_of_pets: nil,
#     updated_at: ~N[2021-02-25 01:58:55]
#   },
#   %Hello.User{
#     __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
#     bio: nil,
#     email: "user2@example.com",
#     id: 2,
#     inserted_at: ~N[2021-02-25 02:03:28],
#     name: nil,
#     number_of_pets: nil,
#     updated_at: ~N[2021-02-25 02:03:28]
#   }
# ]
#Repo.all/1 takes a data source, our User schema in this case, and translates that to an underlying SQL query against our database. After it fetches the data, the Repo then uses our Ecto schema to map the database values back into Elixir data structures according to our User schema. We're not just limited to basic querying – Ecto includes a full-fledged query DSL for advanced SQL generation. In addition to a natural Elixir DSL, Ecto's query engine gives us multiple great features, such as SQL injection protection and compile-time optimization of queries. Let's try it out
#First, we imported [Ecto.Query], which imports the from/2 macro of Ecto's Query DSL. Next, we built a query which selects all the email addresses in our users table. Let's try another example.
import Ecto.Query
iex)> Repo.one(from u in User, where: ilike(u.email, "%1%"),
                               select: count(u.id))
#return :[debug] QUERY OK source="users" db=1.6ms SELECT count(u0."id") FROM "users" AS u0 WHERE (u0."email" ILIKE '%1%') []
#1

#We used Repo.one/2 to fetch the count of all users with an email address containing 1, and received the expected count in return. This just scratches the surface of Ecto's query interface, and much more is supported such as sub-querying, interval queries, and advanced select statements
