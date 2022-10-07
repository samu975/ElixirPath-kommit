# Routing

## Section


# Routers are the main hubs of Phoenix applications. They match HTTP requests to controller actions, wire up real-time channel handlers, and define a series of pipeline transformations scoped to a set of routes.

# The router file that Phoenix generates, lib/hello_web/router.ex, will look something like this one:

efmodule HelloWeb.Router do
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

# Both the router and controller module names will be prefixed with the name you gave your application suffixed with Web.
# The first line of this module, use HelloWeb, :router, simply makes Phoenix router functions available in our particular router.

# Scopes have their own section in this guide, so we won't spend time on the scope "/", HelloWeb do block here. The pipe_through :browser line will get a full treatment in the "Pipelines" section of this guide. For now, you only need to know that pipelines allow a set of plugs to be applied to different sets of routes.

# Inside the scope block, however, we have our first actual route:

get("/", PageController, :index)

# get is a Phoenix macro that corresponds to the HTTP verb GET. Similar macros exist for other HTTP verbs, including POST, PUT, PATCH, DELETE, OPTIONS, CONNECT, TRACE, and HEAD.


## Examining routes


#Phoenix provides an excellent tool for investigating routes in an application: mix phx.routes.

# Let's see how this works. Go to the root of a newly-generated Phoenix application and run mix phx.routes. You should see something like the following, generated with all routes you currently have:
mix phx.routes
page_path  GET  /  HelloWeb.PageController :index
...

#The route above tells us that any HTTP GET request for the root of the application will be handled by the index action of the HelloWeb.PageController.




## Resources


#The router supports other macros besides those for HTTP verbs like get, post, and put. The most important among them is resources. Let's add a resource to our lib/hello_web/router.ex file like this:
scope "/", HelloWeb do
  pipe_through :browser

  get "/", PageController, :index
  resources "/users", UserController
  ...
end
#For now it doesn't matter that we don't actually have a HelloWeb.UserController.
#Run mix phx.routes once again at the root of your project. You should see something like the following:

...
user_path  GET     /users           HelloWeb.UserController :index
user_path  GET     /users/:id/edit  HelloWeb.UserController :edit
user_path  GET     /users/new       HelloWeb.UserController :new
user_path  GET     /users/:id       HelloWeb.UserController :show
user_path  POST    /users           HelloWeb.UserController :create
user_path  PATCH   /users/:id       HelloWeb.UserController :update
           PUT     /users/:id       HelloWeb.UserController :update
user_path  DELETE  /users/:id       HelloWeb.UserController :delete
...

# This is the standard matrix of HTTP verbs, paths, and controller actions. For a while, this was known as RESTful routes, but most consider this a misnomer nowadays.

# A GET request to /users will invoke the index action to show all the users.
# A GET request to /users/:id/edit will invoke the edit action with an ID to retrieve an individual user from the data store and present the information in a form for editing.
# A GET request to /users/new will invoke the new action to present a form for creating a new user.
# A GET request to /users/:id will invoke the show action with an id to show an individual user identified by that ID.
# A POST request to /users will invoke the create action to save a new user to the data store.
# A PATCH request to /users/:id will invoke the update action with an ID to save the updated user to the data store.
# A PUT request to /users/:id will also invoke the update action with an ID to save the updated user to the data store.
# A DELETE request to /users/:id will invoke the delete action with an ID to remove the individual user from the data store.

# If we don't need all these routes, we can be selective using the :only and :except options to filter specific actions.

# Let's say we have a read-only posts resource. We could define it like this:
resources "/posts", PostController, only: [:index, :show]

#Running mix phx.routes shows that we now only have the routes to the index and show actions defined.

post_path  GET     /posts      HelloWeb.PostController :index
post_path  GET     /posts/:id  HelloWeb.PostController :show

#Similarly, if we have a comments resource, and we don't want to provide a route to delete one, we could define a route like this.
resources "/comments", CommentController, except: [:delete]

# Running mix phx.routes now shows that we have all the routes except the DELETE request to the delete action.
comment_path  GET    /comments           HelloWeb.CommentController :index
comment_path  GET    /comments/:id/edit  HelloWeb.CommentController :edit
comment_path  GET    /comments/new       HelloWeb.CommentController :new
comment_path  GET    /comments/:id       HelloWeb.CommentController :show
comment_path  POST   /comments           HelloWeb.CommentController :create
comment_path  PATCH  /comments/:id       HelloWeb.CommentController :update
              PUT    /comments/:id       HelloWeb.CommentController :update

# The Phoenix.Router.resources/4 macro describes additional options for customizing resource routes.

## Path helpers

#Path helpers are dynamically defined functions. They allow us to retrieve the path corresponding to a given controller-action pair. The name of each path helper is derived from the name of the controller used in the route definition. For our controller HelloWeb.PageController, page_path is the function that will return the path, which in this case is the root of our application.
#This is significant because we can use the page_path function in a template to link to the root of our application. We can then use this helper in our templates:

<%= link "Welcome Page!", to: Routes.page_path(@conn, :index) %>

#Note that path helpers are dynamically defined on the Router.Helpers module for an individual application. For us, that is HelloWeb.Router.Helpers.

# The reason we can use Routes.page_path instead of the full HelloWeb.Router.Helpers.page_path name is because HelloWeb.Router.Helpers is aliased as Routes by default in the view_helpers/0 block defined inside lib/hello_web.ex. This definition is made available to our templates through use HelloWeb, :view.
#We can, of course, use HelloWeb.Router.Helpers.page_path(@conn, :index) instead, but the convention is to use the aliased version for conciseness. Note that the alias is only set automatically for use in views, controllers and templates - outside these, you need either the full name, or to alias it yourself inside the module definition with alias HelloWeb.Router.Helpers, as: Routes.

#Using path helpers makes it easy to ensure our controllers, views, and templates link to pages our router can actually handle.





## More on path helpers


# When we ran mix phx.routes for our user resource, it listed the user_path as the path helper function for each output line. Here is what that translates to for each action:

alias HelloWeb.Router.Helpers, as: Routes
alias HelloWeb.Endpoint

Routes.user_path(Endpoint, :index)
"/users"

Routes.user_path(Endpoint, :show, 17)
"/users/17"

Routes.user_path(Endpoint, :new)
"/users/new"

Routes.user_path(Endpoint, :create)
"/users"

Routes.user_path(Endpoint, :edit, 37)
"/users/37/edit"

Routes.user_path(Endpoint, :update, 37)
"/users/37"

Routes.user_path(Endpoint, :delete, 17)
"/users/17"


## Nested resources


#It is also possible to nest resources in a Phoenix router. Let's say we also have a posts resource that has a many-to-one relationship with users. That is to say, a user can create many posts, and an individual post belongs to only one user. We can represent that by adding a nested route in lib/hello_web/router.ex like this:

resources "/users", UserController do
  resources "/posts", PostController
end

#When we run mix phx.routes now, in addition to the routes we saw for users above, we get the following set of routes:
...
user_post_path  GET     /users/:user_id/posts           HelloWeb.PostController :index
user_post_path  GET     /users/:user_id/posts/:id/edit  HelloWeb.PostController :edit
user_post_path  GET     /users/:user_id/posts/new       HelloWeb.PostController :new
user_post_path  GET     /users/:user_id/posts/:id       HelloWeb.PostController :show
user_post_path  POST    /users/:user_id/posts           HelloWeb.PostController :create
user_post_path  PATCH   /users/:user_id/posts/:id       HelloWeb.PostController :update
                PUT     /users/:user_id/posts/:id       HelloWeb.PostController :update
user_post_path  DELETE  /users/:user_id/posts/:id       HelloWeb.PostController :delete
...

# We see that each of these routes scopes the posts to a user ID. For the first one, we will invoke PostController's index action, but we will pass in a user_id. This implies that we would display all the posts for that individual user only. The same scoping applies for all these routes.

# When calling path helper functions for nested routes, we will need to pass the IDs in the order they came in the route definition. For the following show route, 42 is the user_id, and 17 is the post_id.

#Again, if we add a key-value pair to the end of the function call, it is added to the query string.
HelloWeb.Router.Helpers.user_post_path(Endpoint, :index, 42, active: true)
"/users/42/posts?active=true"

#If we hadn't aliased the Helpers module as we did before (remember it is only automatically aliased for views, templates and controllers), and since we are inside iex, we'll have to do it ourselves:
alias HelloWeb.Router.Helpers, as: Routes
alias HelloWeb.Endpoint
Routes.user_post_path(Endpoint, :index, 42, active: true)
"/users/42/posts?active=true"





## Scoped routes


#Scopes are a way to group routes under a common path prefix and scoped set of plugs. We might want to do this for admin functionality, APIs, and especially for versioned APIs. Let's say we have user-generated reviews on a site, and that those reviews first need to be approved by an administrator. The semantics of these resources are quite different, and they might not share the same controller. Scopes enable us to segregate these routes.

# The paths to the user-facing reviews would look like a standard resource.
/reviews
/reviews/1234
/reviews/1234/edit
...

#The administration review paths can be prefixed with /admin.
/admin/reviews
/admin/reviews/1234
/admin/reviews/1234/edit
...
# We accomplish this with a scoped route that sets a path option to /admin like this one. We can nest this scope inside another scope, but instead, let's set it by itself at the root, by adding to lib/hello_web/router.ex the following:
scope "/admin", HelloWeb.Admin do
  pipe_through :browser

  resources "/reviews", ReviewController
end

#We define a new scope where all routes are prefixed with /admin and all controllers are under the HelloWeb.Admin namespace.
#Running mix phx.routes again, in addition to the previous set of routes we get the following:

...
review_path  GET     /admin/reviews           HelloWeb.Admin.ReviewController :index
review_path  GET     /admin/reviews/:id/edit  HelloWeb.Admin.ReviewController :edit
review_path  GET     /admin/reviews/new       HelloWeb.Admin.ReviewController :new
review_path  GET     /admin/reviews/:id       HelloWeb.Admin.ReviewController :show
review_path  POST    /admin/reviews           HelloWeb.Admin.ReviewController :create
review_path  PATCH   /admin/reviews/:id       HelloWeb.Admin.ReviewController :update
             PUT     /admin/reviews/:id       HelloWeb.Admin.ReviewController :update
review_path  DELETE  /admin/reviews/:id       HelloWeb.Admin.ReviewController :delete
...

#This looks good, but there is a problem here. Remember that we wanted both user-facing review routes /reviews and the admin ones /admin/reviews. If we now include the user-facing reviews in our router under the root scope like this:
scope "/", HelloWeb do
  pipe_through :browser

  ...
  resources "/reviews", ReviewController
end

scope "/admin", HelloWeb.Admin do
  pipe_through :browser

  resources "/reviews", ReviewController
end
#and we run mix phx.routes, we get this output:
...
review_path  GET     /reviews                 HelloWeb.ReviewController :index
review_path  GET     /reviews/:id/edit        HelloWeb.ReviewController :edit
review_path  GET     /reviews/new             HelloWeb.ReviewController :new
review_path  GET     /reviews/:id             HelloWeb.ReviewController :show
review_path  POST    /reviews                 HelloWeb.ReviewController :create
review_path  PATCH   /reviews/:id             HelloWeb.ReviewController :update
             PUT     /reviews/:id             HelloWeb.ReviewController :update
review_path  DELETE  /reviews/:id             HelloWeb.ReviewController :delete
...
review_path  GET     /admin/reviews           HelloWeb.Admin.ReviewController :index
review_path  GET     /admin/reviews/:id/edit  HelloWeb.Admin.ReviewController :edit
review_path  GET     /admin/reviews/new       HelloWeb.Admin.ReviewController :new
review_path  GET     /admin/reviews/:id       HelloWeb.Admin.ReviewController :show
review_path  POST    /admin/reviews           HelloWeb.Admin.ReviewController :create
review_path  PATCH   /admin/reviews/:id       HelloWeb.Admin.ReviewController :update
             PUT     /admin/reviews/:id       HelloWeb.Admin.ReviewController :update
review_path  DELETE  /admin/reviews/:id       HelloWeb.Admin.ReviewController :delete

#The actual routes we get all look right, except for the path helper review_path at the beginning of each line. We are getting the same helper for both the user facing review routes and the admin ones, which is not correct.

# We can fix this problem by adding an as: :admin option to our admin scope:
scope "/admin", HelloWeb.Admin, as: :admin do
  pipe_through :browser

  resources "/reviews", ReviewController
end

HelloWeb.Router.Helpers.review_path(HelloWeb.Endpoint, :index) # "/reviews"
HelloWeb.Router.Helpers.admin_review_path(HelloWeb.Endpoint, :show, 1234) #"/admin/reviews/1234"

#Scopes can also be arbitrarily nested, but you should do it carefully as nesting can sometimes make our code confusing and less clear. With that said, suppose that we had a versioned API with resources defined for images, reviews, and users. Then technically, we could set up routes for the versioned API like this:
scope "/api", HelloWeb.Api, as: :api do
  pipe_through :api

  scope "/v1", V1, as: :v1 do
    resources "/images",  ImageController
    resources "/reviews", ReviewController
    resources "/users",   UserController
  end
end

#You can run mix phx.routes to see how these definitions will look like.
#Interestingly, we can use multiple scopes with the same path as long as we are careful not to duplicate routes. The following router is perfectly fine with two scopes defined for the same path:

defmodule HelloWeb.Router do
  use Phoenix.Router
  ...
  scope "/", HelloWeb do
    pipe_through :browser

    resources "/users", UserController
  end

  scope "/", AnotherAppWeb do
    pipe_through :browser

    resources "/posts", PostController
  end
  ...
end





## Pipelines


# Routes are defined inside scopes and scopes may pipe through multiple pipelines. Once a route matches, Phoenix invokes all plugs defined in all pipelines associated to that route. For example, accessing / will pipe through the :browser pipeline, consequently invoking all of its plugs.

# Phoenix defines two pipelines by default, :browser and :api, which can be used for a number of common tasks. In turn we can customize them as well as create new pipelines to meet our needs.
## The :browser and :api pipelines
# As their names suggest, the :browser pipeline prepares for routes which render requests for a browser, and the :api pipeline prepares for routes which produce data for an API.

# The :browser pipeline has six plugs: The plug :accepts, ["html"] defines the accepted request format or formats. :fetch_session, which, naturally, fetches the session data and makes it available in the connection. :fetch_live_flash, which fetches any flash messages from LiveView and merges them with the controller flash messages. Then, the plug :put_root_layout will store the root layout for rendering purposes. Later :protect_from_forgery and :put_secure_browser_headers, protects form posts from cross-site forgery.
# Currently, the :api pipeline only defines plug :accepts, ["json"].

# The router invokes a pipeline on a route defined within a scope. Routes outside of a scope have no pipelines. Although the use of nested scopes is discouraged (see above the versioned API example), if we call pipe_through within a nested scope, the router will invoke all pipe_through's from parent scopes, followed by the nested one.

# Those are a lot of words bunched up together. Let's take a look at some examples to untangle their meaning.

# Here's another look at the router from a newly generated Phoenix application, this time with the /api scope uncommented back in and a route added.
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
  scope "/api", HelloWeb do
    pipe_through(:api)

    resources("/reviews", ReviewController)
  end

  # ...
end

# When the server accepts a request, the request will always first pass through the plugs in our endpoint, after which it will attempt to match on the path and HTTP verb.

# Let's say that the request matches our first route: a GET to /. The router will first pipe that request through the :browser pipeline - which will fetch the session data, fetch the flash, and execute forgery protection - before it dispatches the request to PageController's index action.
# Conversely, suppose the request matches any of the routes defined by the resources/2 macro. In that case, the router will pipe it through the :api pipeline — which currently only performs content negotiation — before it dispatches further to the correct action of the HelloWeb.ReviewController.
# If no route matches, no pipeline is invoked and a 404 error is raised.
# Let's stretch these ideas out a little bit more. What if we need to pipe requests through both :browser and one or more custom pipelines? We simply pipe_through a list of pipelines, and Phoenix will invoke them in order.
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

  ...

  scope "/reviews" do
    pipe_through([:browser, :review_checks, :other_great_stuff])

    resources("/", HelloWeb.ReviewController)
  end
end

# Here's another example with two scopes that have different pipelines:

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

  ...

  scope "/", HelloWeb do
    pipe_through(:browser)

    resources("/posts", PostController)
  end

  scope "/reviews", HelloWeb do
    pipe_through([:browser, :review_checks])

    resources("/", ReviewController)
  end
end

# In general, the scoping rules for pipelines behave as you might expect. In this example, all routes will pipe through the :browser pipeline. However, only the reviews resources routes will pipe through the :review_checks pipeline. Since we declared both pipes pipe_through [:browser, :review_checks] in a list of pipelines, Phoenix will pipe_through each of them as it invokes them in order.
## Creating new pipelines

# Phoenix allows us to create our own custom pipelines anywhere in the router. To do so, we call the pipeline/2 macro with these arguments: an atom for the name of our new pipeline and a block with all the plugs we want in it.
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

  pipeline :review_checks do
    plug(:ensure_authenticated_user)
    plug(:ensure_user_owns_review)
  end

  scope "/reviews", HelloWeb do
    pipe_through([:browser, :review_checks])

    resources("/", ReviewController)
  end
end

# Note that pipelines themselves are plugs, so we can plug a pipeline inside another pipeline. For example, we could rewrite the review_checks pipeline above to automatically invoke browser, simplifying the downstream pipeline call:
pipeline :review_checks do
  plug(:browser)
  plug(:ensure_authenticated_user)
  plug(:ensure_user_owns_review)
end

scope "/reviews", HelloWeb do
  pipe_through(:review_checks)

  resources("/", ReviewController)
end


## Forward


# The Phoenix.Router.forward/4 macro can be used to send all requests that start with a particular path to a particular plug. Let's say we have a part of our system that is responsible (it could even be a separate application or library) for running jobs in the background, it could have its own web interface for checking the status of the jobs. We can forward to this admin interface using:
defmodule HelloWeb.Router do
  use HelloWeb, :router

  ...

  scope "/", HelloWeb do
    ...
  end

  forward("/jobs", BackgroundJob.Plug)
end

# This means that all routes starting with /jobs will be sent to the HelloWeb.BackgroundJob.Plug module. Inside the plug, you can match on subroutes, such as /pending and /active that shows the status of certain jobs.

# We can even mix the forward/4 macro with pipelines. If we wanted to ensure that the user was authenticated and was an administrator in order to see the jobs page, we could use the following in our router.
defmodule HelloWeb.Router do
  use HelloWeb, :router

  ...

  scope "/" do
    pipe_through([:authenticate_user, :ensure_admin])
    forward("/jobs", BackgroundJob.Plug)
  end
end

# This means the plugs in the authenticate_user and ensure_admin pipelines will be called before the BackgroundJob.Plug allowing them to send an appropriate response and halt the request accordingly.

# The opts that are received in the init/1 callback of the Module Plug can be passed as a third argument. For example, maybe the background job lets you set the name of your application to be displayed on the page. This could be passed with:
forward("/jobs", BackgroundJob.Plug, name: "Hello Phoenix")

## Summary

# Routing is a big topic, and we have covered a lot of ground here. The important points to take away from this guide are:

# Routes which begin with an HTTP verb name expand to a single clause of the match function.
# Routes declared with resources expand to 8 clauses of the match function.
# Resources may restrict the number of match function clauses by using the only: or except: options.
# Any of these routes may be nested.
# Any of these routes may be scoped to a given path.
# Using the as: option in a scope can reduce duplication.
# Using the helper option for scoped routes eliminates unreachable paths.
