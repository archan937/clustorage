# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :appy, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:appy, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

config :clustorage, name: "app1",
  cookie: "yd4saoktddpzy0uds72k60i7mj237jn5k7wqdsl2dpiahswd0b4gja78qq3w"

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
