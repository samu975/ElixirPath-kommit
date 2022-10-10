
## Introduction to Testing


# Elixir ships with a built-in testing framework called ExUnit. ExUnit strives to be clear and explicit, keeping magic to a minimum. Phoenix uses ExUnit for all of its testing, and we will use it here as well.

## Running tests
# When Phoenix generates a web application for us, it also includes tests. To run them, simply type mix test:

mix test
....

Finished in 0.09 seconds
3 tests, 0 failures

Randomized with seed 652656

## We already have three tests!

# In fact, we already have a directory structure completely set up for testing, including a test helper and support files.

# test
# ├── hello_web
# │   ├── channels
# │   ├── controllers
# │   │   └── page_controller_test.exs
# │   └── views
# │       ├── error_view_test.exs
# │       ├── layout_view_test.exs
# │       └── page_view_test.exs
# ├── support
# │   ├── channel_case.ex
# │   ├── conn_case.ex
# │   └── data_case.ex
# └── test_helper.exs
# The test cases we get for free include test/hello_web/controllers/page_controller_test.exs, test/hello_web/views/error_view_test.exs, and test/hello_web/views/page_view_test.exs. They are testing our controllers and views. If you haven't read the guides for controllers and views, now is a good time.

## Understanding test modules

# The first test file we'll look at is test/hello_web/controllers/page_controller_test.exs.

defmodule HelloWeb.PageControllerTest do
  use HelloWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
# There are a couple of interesting things happening here.

# Our test files simply define modules. At the top of each module, you will find a line such as:

use HelloWeb.ConnCase
# If you were to write an Elixir library, outside of Phoenix, instead of use HelloWeb.ConnCase you would write use ExUnit.Case. However, Phoenix already ships with a bunch of functionality for testing controllers and HelloWeb.ConnCase builds on top of ExUnit.Case to bring these functionalities in. We will explore the HelloWeb.ConnCase module soon.

# Then we define each test using the test/3 macro. The test/3 macro receives three arguments: the test name, the testing context that we are pattern matching on, and the contents of the test. In this test, we access the root page of our application by a "GET" HTTP request on the path "/" with the get/2 macro. Then we assert that the rendered page contains the string "Welcome to Phoenix!".

# When writing tests in Elixir, we use assertions to check that something is true. In our case, assert html_response(conn, 200) =~ "Welcome to Phoenix!" is doing a couple things:

# It asserts that conn has rendered a response
# It asserts that the response has the 200 status code (which means OK in HTTP parlance)
# It asserts that the type of the response is HTML
# It asserts that the result of html_response(conn, 200), which is an HTML response, has the string "Welcome to Phoenix!" in it
# However, from where does the conn we use on get and html_response come from? To answer this question, let's take a look at HelloWeb.ConnCase.

##The ConnCase
#If you open up test/support/conn_case.ex, you will find this (with comments removed):

defmodule HelloWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      alias HelloWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint HelloWeb.Endpoint
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Demo.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    %{conn: Phoenix.ConnTest.build_conn()}
  end
end
#There is a lot to unpack here.

#The second line says this is a case template. This is a ExUnit feature that allows developers to replace the built-in use ExUnit.Case by their own case. This line is pretty much what allows us to write use HelloWeb.ConnCase at the top of our controller tests.

#Now that we have made this module a case template, we can define callbacks that are invoked on certain occasions. The using callback defines code to be injected on every module that calls use HelloWeb.ConnCase. In this case, we import Plug.Conn, so all of the connection helpers available in controllers are also available in tests, and then imports Phoenix.ConnTest. You can consult these modules to learn all functionality available.

#Then it aliases the module with all path helpers, so we can easily generate URLs in our tests. Finally, it sets the @endpoint module attribute with the name of our endpoint.

#Then our case template defines a setup block. The setup block will be called before test. Most of the setup block is on setting up the SQL Sandbox, which we will talk about it later. In the last line of the setup block, we will find this:

%{conn: Phoenix.ConnTest.build_conn()}
#The last line of setup can return test metadata that will be available in each test. The metadata we are passing forward here is a newly built Plug.Conn. In our test, we extract the connection out of this metadata at the very beginning of our test:

test "GET /", %{conn: conn} do
#And that's where the connection comes from! At first, the testing structure does come with a bit of indirection, but this indirection pays off as our test suite grows, since it allows us to cut down the amount of boilerplate.

## View tests
#The other test files in our application are responsible for testing our views.

#The error view test case, test/hello_web/views/error_view_test.exs, illustrates a few interesting things of its own.

defmodule HelloWeb.ErrorViewTest do
  use HelloWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.html" do
    assert render_to_string(HelloWeb.ErrorView, "404.html", []) ==
           "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(HelloWeb.ErrorView, "500.html", []) ==
           "Internal Server Error"
  end
end
#HelloWeb.ErrorViewTest sets async: true which means that this test case will be run in parallel with other test cases. While individual tests within the case still run serially, this can greatly increase overall test speeds.

#It also imports Phoenix.View in order to use the render_to_string/3 function. With that, all the assertions can be simple string equality tests.

T#he page view case, test/hello_web/views/page_view_test.exs, does not contain any tests by default, but it is here for us when we need to add functions to our HelloWeb.PageView module.

defmodule HelloWeb.PageViewTest do
  use HelloWeb.ConnCase, async: true
end
## Running tests per directory/file
#Now that we have an idea what our tests are doing, let's look at different ways to run them.

#As we saw near the beginning of this guide, we can run our entire suite of tests with mix test.

mix test
....

Finished in 0.2 seconds
3 tests, 0 failures

Randomized with seed 540755
#If we would like to run all the tests in a given directory, test/hello_web/controllers for instance, we can pass the path to that directory to mix test.

mix test test/hello_web/controllers/
.

Finished in 0.2 seconds
1 tests, 0 failures

Randomized with seed 652376
#In order to run all the tests in a specific file, we can pass the path to that file into mix test.

mix test test/hello_web/views/error_view_test.exs
...

Finished in 0.2 seconds
2 tests, 0 failures

Randomized with seed 220535
#And we can run a single test in a file by appending a colon and a line number to the filename.

#Let's say we only wanted to run the test for the way HelloWeb.ErrorView renders 500.html. The test begins on line 11 of the file, so this is how we would do it.

mix test test/hello_web/views/error_view_test.exs:11
Including tags: [line: "11"]
Excluding tags: [:test]

.

Finished in 0.1 seconds
2 tests, 0 failures, 1 excluded

Randomized with seed 288117
#We chose to run this specifying the first line of the test, but actually, any line of that test will do. These line numbers would all work - :11, :12, or :13.

## Running tests using tags
#ExUnit allows us to tag our tests individually or for the whole module. We can then choose to run only the tests with a specific tag, or we can exclude tests with that tag and run everything else.


#First, we'll add a @moduletag to test/hello_web/views/error_view_test.exs.

defmodule HelloWeb.ErrorViewTest do
  use HelloWeb.ConnCase, async: true

  @moduletag :error_view_case
  ...
end
#If we use only an atom for our module tag, ExUnit assumes that it has a value of true. We could also specify a different value if we wanted.

defmodule HelloWeb.ErrorViewTest do
  use HelloWeb.ConnCase, async: true

  @moduletag error_view_case: "some_interesting_value"
  ...
end
#For now, let's leave it as a simple atom @moduletag :error_view_case.

#We can run only the tests from the error view case by passing --only error_view_case into mix test.

mix test --only error_view_case
Including tags: [:error_view_case]
Excluding tags: [:test]

...

Finished in 0.1 seconds
3 tests, 0 failures, 1 excluded

Randomized with seed 125659
#Note: ExUnit tells us exactly which tags it is including and excluding for each test run. If we look back to the previous section on running tests, we'll see that line numbers specified for individual tests are actually treated as tags.

mix test test/hello_web/views/error_view_test.exs:11
Including tags: [line: "11"]
Excluding tags: [:test]

.

Finished in 0.2 seconds
2 tests, 0 failures, 1 excluded

Randomized with seed 364723
Specifying a value of true for error_view_case yields the same results.

mix test --only error_view_case:true
Including tags: [error_view_case: "true"]
Excluding tags: [:test]

...

Finished in 0.1 seconds
3 tests, 0 failures, 1 excluded

Randomized with seed 833356
#Specifying false as the value for error_view_case, however, will not run any tests because no tags in our system match error_view_case: false.

mix test --only error_view_case:false
Including tags: [error_view_case: "false"]
Excluding tags: [:test]



Finished in 0.1 seconds
3 tests, 0 failures, 3 excluded

Randomized with seed 622422
#The --only option was given to "mix test" but no test executed
#We can use the --exclude flag in a similar way. This will run all of the tests except those in the error view case.

mix test --exclude error_view_case
Excluding tags: [:error_view_case]

.

Finished in 0.2 seconds
3 tests, 0 failures, 2 excluded

Randomized with seed 682868
#Specifying values for a tag works the same way for --exclude as it does for --only.

#We can tag individual tests as well as full test cases. Let's tag a few tests in the error view case to see how this works.

defmodule HelloWeb.ErrorViewTest do
  use HelloWeb.ConnCase, async: true

  @moduletag :error_view_case

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  @tag individual_test: "yup"
  test "renders 404.html" do
    assert render_to_string(HelloWeb.ErrorView, "404.html", []) ==
           "Not Found"
  end

  @tag individual_test: "nope"
  test "renders 500.html" do
    assert render_to_string(HelloWeb.ErrorView, "500.html", []) ==
           "Internal Server Error"
  end
end
#If we would like to run only tests tagged as individual_test, regardless of their value, this will work.

mix test --only individual_test
Including tags: [:individual_test]
Excluding tags: [:test]

..

Finished in 0.1 seconds
3 tests, 0 failures, 1 excluded

Randomized with seed 813729
We can also specify a value and run only tests with that.

mix test --only individual_test:yup
Including tags: [individual_test: "yup"]
Excluding tags: [:test]

.

Finished in 0.1 seconds
3 tests, 0 failures, 2 excluded

Randomized with seed 770938
Similarly, we can run all tests except for those tagged with a given value.

mix test --exclude individual_test:nope
Excluding tags: [individual_test: "nope"]

...

Finished in 0.2 seconds
3 tests, 0 failures, 1 excluded

Randomized with seed 539324
#We can be more specific and exclude all the tests from the error view case except the one tagged with individual_test that has the value "yup".

mix test --exclude error_view_case --include individual_test:yup
Including tags: [individual_test: "yup"]
Excluding tags: [:error_view_case]

..

Finished in 0.2 seconds
3 tests, 0 failures, 1 excluded

Randomized with seed 61472
#Finally, we can configure ExUnit to exclude tags by default. The default ExUnit configuration is done in the test/test_helper.exs file:

ExUnit.start(exclude: [error_view_case: true])

Ecto.Adapters.SQL.Sandbox.mode(Hello.Repo, :manual)
#Now when we run mix test, it only runs one spec from our page_controller_test.exs.

mix test
Excluding tags: [error_view_case: true]

.

Finished in 0.2 seconds
3 tests, 0 failures, 2 excluded

Randomized with seed 186055
#We can override this behavior with the --include flag, telling mix test to include tests tagged with error_view_case.

mix test --include error_view_case
Including tags: [:error_view_case]
Excluding tags: [error_view_case: true]

....

Finished in 0.2 seconds
3 tests, 0 failures

Randomized with seed 748424
#This technique can be very useful to control very long running tests, which you may only want to run in CI or in specific scenarios.

 Randomization
#Running tests in random order is a good way to ensure that our tests are truly isolated. If we notice that we get sporadic failures for a given test, it may be because a previous test changes the state of the system in ways that aren't cleaned up afterward, thereby affecting the tests which follow. Those failures might only present themselves if the tests are run in a specific order.

ExUnit will randomize the order tests run in by default, using an integer to seed the randomization. If we notice that a specific random seed triggers our intermittent failure, we can re-run the tests with that same seed to reliably recreate that test sequence in order to help us figure out what the problem is.

mix test --seed 401472
....

Finished in 0.2 seconds
3 tests, 0 failures

Randomized with seed 401472
 Concurrency and partitioning
#As we have seen, ExUnit allows developers to run tests concurrently. This allows developers to use all of the power in their machine to run their test suites as fast as possible. Couple this with Phoenix performance, most test suites compile and run in a fraction of the time compared to other frameworks.

#While developers usually have powerful machines available to them during development, this may not always be the case in your Continuous Integration servers. For this reason, ExUnit also supports out of the box test partitioning in test environments. If you open up your config/test.exs, you will find the database name set to:

database: "hello_test#{System.get_env("MIX_TEST_PARTITION")}",
#By default, the MIX_TEST_PARTITION environment variable has no value, and therefore it has no effect. But in your CI server, you can, for example, split your test suite across machines by using four distinct commands:

# MIX_TEST_PARTITION=1 mix test --partitions 4
# MIX_TEST_PARTITION=2 mix test --partitions 4
# MIX_TEST_PARTITION=3 mix test --partitions 4
# MIX_TEST_PARTITION=4 mix test --partitions 4
#That's all you need to do and ExUnit and Phoenix will take care of all rest, including setting up the database for each distinct partition with a distinct name.

## Going further
#While ExUnit is a simple test framework, it provides a really flexible and robust test runner through the mix test command. We recommend you to run mix help test or read the docs online

#We've seen what Phoenix gives us with a newly generated app. Furthermore, whenever you generate a new resource, Phoenix will generate all appropriate tests for that resource too. For example, you can create a complete scaffold with schema, context, controllers, and views by running the following command at the root of your application:

mix phx.gen.html Blog Post posts title body:text
* creating lib/demo_web/controllers/post_controller.ex
* creating lib/demo_web/templates/post/edit.html.heex
* creating lib/demo_web/templates/post/form.html.heex
* creating lib/demo_web/templates/post/index.html.heex
* creating lib/demo_web/templates/post/new.html.heex
* creating lib/demo_web/templates/post/show.html.heex
* creating lib/demo_web/views/post_view.ex
* creating test/demo_web/controllers/post_controller_test.exs
* creating lib/demo/blog/post.ex
* creating priv/repo/migrations/20200215122336_create_posts.exs
* creating lib/demo/blog.ex
* injecting lib/demo/blog.ex
* creating test/demo/blog_test.exs
* injecting test/demo/blog_test.exs

# Add the resource to your browser scope in lib/demo_web/router.ex:

    resources "/posts", PostController


#Remember to update your repository by running migrations:

    $ mix ecto.migrate

#Now let's follow the directions and add the new resources route to our lib/hello_web/router.ex file and run the migrations.

#When we run mix test again, we see that we now have nineteen tests!

mix test
................

Finished in 0.1 seconds
19 tests, 0 failures

Randomized with seed 537537
#At this point, we are at a great place to transition to the rest of the testing guides, in which we'll examine these tests in much more detail, and add some of our own.
```
