# Directory structure

## Untitled


# When we use mix phx.new to generate a new Phoenix application, it builds a top-level directory structure like this:
# ├── _build
# ├── assets
# ├── config
# ├── deps
# ├── lib
# │   ├── hello
# │   ├── hello.ex
# │   ├── hello_web
# │   └── hello_web.ex
# ├── priv
# └── test

## _build: a directory created by the mix command line tool that ships as part of Elixir that holds all compilation artifacts. As we have seen in "Up and Running", mix is the main interface to your application. We use Mix to compile our code, create databases, run our server, and more. This directory must not be checked into version control and it can be removed at any time. Removing it will force Mix to rebuild your application from scratch.
## assets:  a directory that keeps everything related to source front-end assets, such as JavaScript and CSS, and automatically managed by the esbuild tool
## config:  a directory that holds your project configuration. The config/config.exs file is the entry point for your configuration. At the end of the config/config.exs, it imports environment specific configuration, which can be found in config/dev.exs, config/test.exs, and config/prod.exs. Finally, config/runtime.exs is executed and it is the best place to read secrets and other dynamic configuration.
## deps:  a directory with all of our Mix dependencies. You can find all dependencies listed in the mix.exs file, inside the defp deps do function definition. This directory must not be checked into version control and it can be removed at any time. Removing it will force Mix to download all deps from scratch.
## lib: a directory that holds your application source code. This directory is broken into two subdirectories, lib/hello and lib/hello_web. The lib/hello directory will be responsible to host all of your business logic and business domain. It typically interacts directly with the database - it is the "Model" in Model-View-Controller (MVC) architecture. lib/hello_web is responsible for exposing your business domain to the world, in this case, through a web application. It holds both the View and Controller from MVC. We will discuss the contents of these directories with more detail in the next sections
## ## priv: a directory that keeps all resources that are necessary in production but are not directly part of your source code. You typically keep database scripts, translation files, and more in here. Static and generated assets, sourced from the assets directory, are also served from here by default.
## test :  a directory with all of our application tests. It often mirrors the same structure found in lib.


## The lib/hello directory


# The lib/hello directory hosts all of your business domain. Since our project does not have any business logic yet, the directory is mostly empty. You will only find three files:
# lib/hello
# ├── application.ex
# ├── mailer.ex
# └── repo.ex
# The lib/hello/application.ex file defines an Elixir application named Hello.Application. That's because at the end of the day Phoenix applications are simply Elixir applications. The Hello.Application module defines which services are part of our application:
children = [
  # Start the Ecto repository
  Hello.Repo,
  # Start the Telemetry supervisor
  HelloWeb.Telemetry,
  # Start the PubSub system
  {Phoenix.PubSub, name: Hello.PubSub},
  # Start the Endpoint (http/https)
  HelloWeb.Endpoint
  # Start a worker by calling: Hello.Worker.start_link(arg)
  # {Hello.Worker, arg}
]

# our application starts a database repository, a PubSub system for sharing messages across processes and nodes, and the application endpoint, which effectively serves HTTP requests. These services are started in the order they are defined and, whenever shutting down your application, they are stopped in the reverse order.
# The lib/hello/mailer.ex file holds the Hello.Mailer module, which defines the main interface to deliver e-mails:
defmodule Hello.Mailer do
  use Swoosh.Mailer, otp_app: :hello
end

# In the same lib/hello directory, we will find a lib/hello/repo.ex. It defines a Hello.Repo module which is our main interface to the database. If you are using Postgres (the default database), you will see something like this:
defmodule Hello.Repo do
  use Ecto.Repo,
    otp_app: :hello,
    adapter: Ecto.Adapters.Postgres
end


## The lib/hello_web directory


# The lib/hello_web directory holds the web-related parts of our application. It looks like this when expanded:
# lib/hello_web
# ├── controllers
# │   └── page_controller.ex
# ├── templates
# │   ├── layout
# │   │   ├── app.html.heex
# │   │   ├── live.html.heex
# │   │   └── root.html.heex
# │   └── page
# │       └── index.html.heex
# ├── views
# │   ├── error_helpers.ex
# │   ├── error_view.ex
# │   ├── layout_view.ex
# │   └── page_view.ex
# ├── endpoint.ex
# ├── gettext.ex
# ├── router.ex
# └── telemetry.ex

# All of the files which are currently in the controllers, templates, and views directories are there to create the "Welcome to Phoenix!"
# By looking at templates and views directories, we can see Phoenix provides features for handling layouts and error pages out of the box.
# Besides the directories mentioned, lib/hello_web has four files at its root. lib/hello_web/endpoint.ex is the entry-point for HTTP requests. Once the browser accesses http://localhost:4000, the endpoint starts processing the data, eventually leading to the router, which is defined in lib/hello_web/router.ex. The router defines the rules to dispatch requests to "controllers", which then uses "views" and "templates" to render HTML pages back to clients.
# Through Telemetry, Phoenix is able to collect metrics and send monitoring events of your application. The lib/hello_web/telemetry.ex file defines the supervisor responsible for managing the telemetry processes.
# Finally, there is a lib/hello_web/gettext.ex file which provides internationalization through Gettext.


## The assets directory


# The assets directory contains source files related to front-end assets, such as JavaScript and CSS. Since Phoenix v1.6, we use esbuild to compile assets, which is managed by the esbuild Elixir package. The integration with esbuild is baked into your app. The relevant config can be found in your config/config.exs file.

# Your other static assets are placed in the priv/static folder, where priv/static/assets is kept for generated assets. Everything in priv/static is served by the Plug.Static plug configured in lib/hello_web/endpoint.ex. When running in dev mode (MIX_ENV=dev), Phoenix watches for any changes you make in the assets directory, and then takes care of updating your front end application in your browser as you work.

# Note that when you first create your Phoenix app using mix phx.new it is possible to specify options that will affect the presence and layout of the assets directory. In fact, Phoenix apps can bring their own front end tools or not have a front-end at all (handy if you're writing an API for example). For more information you can run mix help phx.new or see the documentation in Mix tasks.

# If the default esbuild integration does not cover your needs, for example because you want to use another build tool, you can switch to a custom assets build.

# As for CSS, Phoenix ships with a handful of custom styles as well as the Milligram CSS Framework, providing a minimal setup for projects. You may move to any CSS framework of your choice. Additional references can be found in the asset management guide.
