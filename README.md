# Discuss

## About
This is a simple, reddit-inspired, forum application built with Elixir and Phoenix. It is a project that I am working on to learn more about Elixir and Phoenix, mainly regarding message passing and how elixir concurrency model applies to Phoenix LiveViews and LiveComponents. Other tasks is to offer Elixir newcomers a hint about how component nesting, component recursion, and message passing between parent and child components work, as well as studying Ecto query model and functional approaches to data manipulation.

## TODO
[x] Create, list, update, delete posts
[x] Make posts accessible via their own page using post slugs
[x] Create, list, update and delete post comments (with counts)
[x] Show/collapse child comments section
[x] Add post and comment validation
[x] Add User management system (authentication, authorization, settings, etc.)
[x] Post votes (up/down voting strategy)
[x] Comment votes (up/down voting strategy)
[] Attach post and comments to its authors (so we know whether one can edit/delete a comment or post)
[] Dark mode
[] Deployment?

## Contributing
This repo sure accepts PRs, but they'll need to be aligned with the project goals and roadmap. If you have any suggestions, please open an issue to discuss it.

## Development

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
