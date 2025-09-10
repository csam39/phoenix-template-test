import Config

# Replace :app / App with your app’s actual name if different
config :app, App.Repo,
  username: System.get_env("PGUSER", "postgres"),
  password: System.get_env("PGPASSWORD", "postgres"),
  # <— key change (not "localhost")
  hostname: System.get_env("PGHOST", "db"),
  database: System.get_env("PGDATABASE", "app_dev"),
  port: String.to_integer(System.get_env("PGPORT", "5432")),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# And make sure Endpoint binds on 0.0.0.0 for Docker (already recommended)
config :app, AppWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ],
  live_reload: [
    patterns: [
      ~r"lib/app_web/(live|views)/.*(ex|heex)$",
      ~r"lib/app_web/templates/.*(eex|heex)$",
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$"
    ]
  ]
