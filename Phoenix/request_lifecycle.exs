# Request life-cycle

## Adding a new page


# When your browser accesses http://localhost:4000/, it sends a HTTP request to whatever service is running on that address, in this case our Phoenix application. The HTTP request is made of a verb and a path. For example, the following browser requests translate into:
# BROWSER ADDRESS BAR	VERB	PATH
# http://localhost:4000/	GET	/
# http://localhost:4000/hello	GET	/hello
# http://localhost:4000/hello/world	GET	/hello/world

# There are other HTTP verbs. For example, submitting a form typically uses the POST verb
# Web applications typically handle requests by mapping each verb/path pair into a specific part of your application. This matching in Phoenix is done by the router. For example, we may map "/articles" to a portion of our application that shows all articles. Therefore, to add a new page, our first task is to add a new route.


## A new route


# The router maps unique HTTP verb/path pairs to controller/action pairs which will handle them. Controllers in Phoenix are simply Elixir modules. Actions are functions that are defined within these controllers.
# Phoenix generates a router file for us in new applications at lib/hello_web/router.ex. This is where we will be working for this section.
# Let's digest what this route is telling us. Visiting http://localhost:4000/ issues an HTTP GET request to the root path. All requests like this will be handled by the index/2 function in the HelloWeb.PageController module defined in lib/hello_web/controllers/page_controller.ex.
# The page we are going to build will say "Hello World, from Phoenix!" when we point our browser to http://localhost:4000/hello.

# The first thing we need to do is to create the page route for a new page. Let's open up lib/hello_web/router.ex in a text editor. For a brand new application, it looks like this:
defmodule HelloWeb.Router do
  use HelloWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {HelloWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", HelloWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", HelloWeb do
  #   pipe_through :api
  # end

  # ...
end

# For now, we'll ignore the pipelines and the use of scope here and just focus on adding a route.
# Let's add a new route to the router that maps a GET request for /hello to the index action of a soon-to-be-created HelloWeb.HelloController inside the scope "/" do block of the router:
scope "/", HelloWeb do
  pipe_through(:browser)

  get("/", PageController, :index)
  get("/hello", HelloController, :index)
end


## A new controller


# Controllers are Elixir modules, and actions are Elixir functions defined in them. The purpose of actions is to gather the data and perform the tasks needed for rendering. Our route specifies that we need a HelloWeb.HelloController module with an index/2 function.
# To make the index action happen, let's create a new lib/hello_web/controllers/hello_controller.ex file, and make it look like the following:
defmodule HelloWeb.HelloController do
  use HelloWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

# All controller actions take two arguments. The first is conn, a struct which holds a ton of data about the request. The second is params, which are the request parameters. Here, we are not using params, and we avoid compiler warnings by prefixing it with _.
# The core of this action is render(conn, "index.html"). It tells Phoenix to render "index.html". The modules responsible for rendering are called views. By default, Phoenix views are named after the controller, so Phoenix is expecting a HelloWeb.HelloView to exist and handle "index.html" for us.


## A new view


#Phoenix views act as the presentation layer. For example, we expect the output of rendering "index.html" to be a complete HTML page. To make our lives easier, we often use templates for creating those HTML pages.
# Let's create a new view. Create lib/hello_web/views/hello_view.ex and make it look like this:
defmodule HelloWeb.HelloView do
  use HelloWeb, :view
end
#Now in order to add templates to this view, we need to add files to the lib/hello_web/templates/hello directory. Note the controller name (HelloController), the view name (HelloView), and the template directory (hello) all follow the same naming convention and are named after each other.
#A template file has the following structure: NAME.FORMAT.TEMPLATING_LANGUAGE. In our case, we will create an index.html.heex file at lib/hello_web/templates/hello/index.html.heex. ".heex" stands for "HTML+EEx". EEx is a library for embedding Elixir that ships as part of Elixir itself. "HTML+EEx" is a Phoenix extension of EEx that is HTML aware, with support for HTML validation, components, and automatic escaping of values. The latter protects you from security vulnerabilities like Cross-Site-Scripting with no extra work on your part.
#Create lib/hello_web/templates/hello/index.html.heex and make it look like this:

<section class="phx-hero">
  <h2>Hello World, from Phoenix!</h2>
</section>

#Now that we've got the route, controller, view, and template, we should be able to point our browsers at http://localhost:4000/hello and see our greeting from Phoenix! (In case you stopped the server along the way, the task to restart it is mix phx.server.)
#We didn't need to stop and restart the server while we made these changes. Yes, Phoenix has hot code reloading! Also, even though our index.html.heex file consists of only a single section tag, the page we get is a full HTML document. Our index template is rendered into the application layout: lib/hello_web/templates/layout/app.html.heex. If you open it, you'll see a line that looks like this:
<%= @inner_content %>
#Which injects our template into the layout before the HTML is sent off to the browser.



## From endpoint to views


# As we built our first page, we could start to understand how the request life-cycle is put together. Now let's take a more holistic look at it.
# All HTTP requests start in our application endpoint. You can find it as a module named HelloWeb.Endpoint in lib/hello_web/endpoint.ex. Once you open up the endpoint file, you will see that, similar to the router, the endpoint has many calls to plug. Plug is a library and a specification for stitching web applications together. It is an essential part of how Phoenix handles requests
# each plug defines a slice of request processing. In the endpoint you will find a skeleton roughly like this:
defmodule HelloWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :hello

  plug(Plug.Static, ...)
  plug(Plug.RequestId)
  plug(Plug.Telemetry, ...)
  plug(Plug.Parsers, ...)
  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, ...)
  plug(HelloWeb.Router)
end

# The last plug is precisely the HelloWeb.Router module. This allows the endpoint to delegate all further request processing to the router. As we now know, its main responsibility is to map verb/path pairs to controllers. The controller then tells a view to render a template.
# At this moment, you may be thinking this can be a lot of steps to simply render a page. However, as our application grows in complexity, we will see that each layer serves a distinct purpose:

# endpoint (Phoenix.Endpoint) - the endpoint contains the common and initial path that all requests go through. If you want something to happen on all requests, it goes to the endpoint.

# router (Phoenix.Router) - the router is responsible for dispatching verb/path to controllers. The router also allows us to scope functionality. For example, some pages in your application may require user authentication, others may not.

# controller (Phoenix.Controller) - the job of the controller is to retrieve request information, talk to your business domain, and prepare data for the presentation layer.

# view (Phoenix.View) - the view handles the structured data from the controller and converts it to a presentation to be shown to users.


## Another new page


#Let's add just a little complexity to our application. We're going to add a new page that will recognize a piece of the URL, label it as a "messenger" and pass it through the controller into the template so our messenger can say hello.

## Another new route
#For this exercise, we're going to reuse HelloController created at the previous step and add a new show action. We'll add a line just below our last route, like this:
scope "/", HelloWeb do
  pipe_through :browser

  get "/", PageController, :index
  get "/hello", HelloController, :index
  get "/hello/:messenger", HelloController, :show
end
#Notice that we use the :messenger syntax in the path. Phoenix will take whatever value that appears in that position in the URL and convert it into a parameter. For example, if we point the browser at: http://localhost:4000/hello/Frank, the value of "messenger" will be "Frank".
## Another new Action
#Requests to our new route will be handled by the HelloWeb.HelloController show action. We already have the controller at lib/hello_web/controllers/hello_controller.ex, so all we need to do is edit that controller and add a show action to it. This time, we'll need to extract the messenger from the parameters so that we can pass it (the messenger) to the template. To do that, we add this show function to the controller:
def show(conn, %{"messenger" => messenger}) do
  render(conn, "show.html", messenger: messenger)
end
#Within the body of the show action, we also pass a third argument to the render function, a key-value pair where :messenger is the key, and the messenger variable is passed as the value.
#If the body of the action needs access to the full map of parameters bound to the params variable, in addition to the bound messenger variable, we could define show/2 like this:
def show(conn, %{"messenger" => messenger} = params) do
  ...
end
#It's good to remember that the keys of the params map will always be strings, and that the equals sign does not represent assignment, but is instead a pattern match assertion.

## Another new template
#For the last piece of this puzzle, we'll need a new template. Since it is for the show action of HelloController, it will go into the lib/hello_web/templates/hello directory and be called show.html.heex. It will look surprisingly like our index.html.heex template, except that we will need to display the name of our messenger.
#To do that, we'll use the special EEx tags for executing Elixir expressions: <%= %>. Notice that the initial tag has an equals sign like this: <%= . That means that any Elixir code that goes between those tags will be executed, and the resulting value will replace the tag in the HTML output. If the equals sign were missing, the code would still be executed, but the value would not appear on the page.
#And this is what the template should look like:

<section class="phx-hero">
  <h2>Hello World, from <%= @messenger %>!</h2>
</section>

#Our messenger appears as @messenger. We call "assigns" the values passed from the controller to views. It is a special bit of metaprogrammed syntax which stands in for assigns.messenger. The result is much nicer on the eyes and much easier to work with in a template.
#We're done.
