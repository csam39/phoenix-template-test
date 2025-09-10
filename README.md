App (Phoenix + LiveView + Tailwind)

Container-native dev environment using Docker Compose + Dev Containers (Cursor/VS Code).
All code, deps, and builds live on a Linux Docker volume—no macOS/APFS quirks.

Prerequisites
- Docker Desktop
- Cursor (or VS Code) with the Dev Containers extension

Quick start

git clone https://github.com/csam39/<repo>.git
cd <repo>
cp .env.dev.example .env.dev
# Put a real secret in .env.dev (inside the dev container you can run: mix phx.gen.secret)

Open the folder in Cursor → Dev Containers: Reopen in Container.

Then inside the Dev Container terminal:

## Rename this template

Run inside the Dev Container at `/app`:

mix phx.gen.secret  # copy output into .env.dev as SECRET_KEY_BASE (See Environment section below for full file example)
./scripts/rename_app.sh MyStore my_store (You can rename the generated app (default: :app / App) to anything with this script. This updates module names (App → MyStore), OTP app (:app → :my_store), folder names, and DB names (app_dev → my_store_dev).)
rm -rf _build deps priv/static/assets
mix deps.get && mix compile
mix ecto.create
mix phx.server

Visit http://localhost:4000

Not using Dev Containers?

docker compose up -d --build
docker compose exec web bash -lc 'mix ecto.create'
docker compose exec web bash -lc 'mix phx.server'

Environment

.env.dev (not committed) is read by the web service:

PGUSER=postgres
PGPASSWORD=postgres
PGDATABASE=my_app_dev
PGHOST=db
PGPORT=5432
SECRET_KEY_BASE=REPLACE_ME   # run `mix phx.gen.secret` to generate
PHX_SERVER=true
MIX_ENV=dev

### Optional: Stable container/volume names

By default, Docker Compose uses the **folder name** as the project name (prefix for containers/volumes/networks).
If you want a fixed prefix (helpful for docs or multiple clones), set `COMPOSE_PROJECT_NAME`:

cp .env.example .env
# edit .env and set COMPOSE_PROJECT_NAME=my_app

Recreate to apply the new name:

docker compose down
docker compose up -d --build
docker compose ps

One-off override (no .env file needed):

COMPOSE_PROJECT_NAME=my_app docker compose up -d

Changing it later? Old volumes/networks will stick around under the old name. Clean them if you like:

docker compose down -v            # removes current project's containers/network/volumes
docker volume ls | grep my_app    # list stragglers
docker volume rm <vol>            # remove if desired

What’s in this repo

- Dockerfile.dev – dev image (Elixir + tools)
- docker-compose.yml – web (Phoenix) + db (Postgres). Source is stored in code_data:/app
- .devcontainer/devcontainer.json – opens /app in the web container and forwards ports
- config/dev.exs – DB host db, esbuild/tailwind watchers, LiveView live_reload
- config/config.exs
    x tailwind → ../priv/static/assets/app.css
    x esbuild → ../priv/static/assets/app.js

Everyday commands (inside Dev Container)

# start server
mix phx.server

# assets
mix assets.setup    # installs tailwind/esbuild binaries
mix assets.build    # builds CSS/JS once

# DB
mix ecto.create
mix ecto.migrate

# generators & tests
mix phx.gen.live Accounts User users name:string
mix test

Notes on JS/CSS
- This base uses Phoenix’s Tailwind/esbuild wrappers (no Node required).
- The phoenix-colocated npm package is not used by default. If you want co-located hooks later:
    1. install Node in the image + add a node_modules volume,
    2. cd assets && npm init -y && npm i phoenix-colocated,
    3. restore import "phoenix-colocated/app" in assets/js/app.js.

Troubleshooting

- Cookie error (secret_key_base): set SECRET_KEY_BASE in .env.dev, then recreate the web container:
    docker compose up -d --force-recreate web
- DB connect refused / tries localhost: ensure hostname: "db" in config/dev.exs.
- Unstyled page / huge icons: run:
    mix assets.setup && mix assets.build
and confirm priv/static/assets/app.css exists.
- Dev reload not reacting: watchers must be present in config/dev.exs. Restart 
    mix phx.server.

Using this as a template

- Click Use this template on GitHub (or fork).
- Update app/module names as needed, or regenerate fresh code in a new repo but keep the Docker + Dev Container files.

Production
Use a multi-stage Dockerfile and mix assets.deploy + mix release. See Phoenix deployment guides.

License

MIT