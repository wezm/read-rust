# This file loads your app and all your tasks when running 'lucky'
#
# Run 'lucky --help' to see all available tasks.
#
# Learn to create your own tasks:
# https://luckyframework.org/guides/command-line-tasks/custom-tasks
ENV["LUCKY_TASK"] = "true"

# Load Lucky and the app (actions, models, etc.)
require "./src/app"

# You can add your own tasks here in the ./tasks folder
require "./tasks/**"

# Load migrations
require "./db/migrations/**"

# Load Lucky tasks (dev, routes, etc.)
require "lucky/tasks/**"

LuckyCli::Runner.run