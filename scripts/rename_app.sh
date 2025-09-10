#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 NewModuleName new_otp_name"
  echo "Example: $0 MyStore my_store"
  exit 1
fi

NEW_MOD="$1"       # e.g., MyStore
NEW_OTP="$2"       # e.g., my_store
OLD_MOD="App"
OLD_OTP="app"

echo "Renaming $OLD_MOD / :$OLD_OTP -> $NEW_MOD / :$NEW_OTP ..."

# 1) Move folders/files to the new OTP name
git mv "lib/${OLD_OTP}"        "lib/${NEW_OTP}"
git mv "lib/${OLD_OTP}_web"    "lib/${NEW_OTP}_web"
git mv "test/${OLD_OTP}_web"   "test/${NEW_OTP}_web" 2>/dev/null || true
[ -f "lib/${OLD_OTP}.ex" ]         && git mv "lib/${OLD_OTP}.ex" "lib/${NEW_OTP}.ex"
[ -f "lib/${OLD_OTP}/application.ex" ] && git mv "lib/${OLD_OTP}/application.ex" "lib/${NEW_OTP}/application.ex"

# 2) Replace tokens in source files
FILES=$(git ls-files | grep -E '\.(ex|exs|heex|eex|md|json|yml|yaml|toml|sh|config|lock|Dockerfile|dockerignore|gitignore)$')
for f in $FILES; do
  # Replace AppWeb first, then App
  sed -i -E "s/\b${OLD_MOD}Web\b/${NEW_MOD}Web/g" "$f"
  sed -i -E "s/\b${OLD_MOD}\b/${NEW_MOD}/g" "$f"
  # Replace OTP atoms and env/db names
  sed -i -E "s/:${OLD_OTP}\b/:${NEW_OTP}/g" "$f"
  sed -i -E "s/\b${OLD_OTP}_dev\b/${NEW_OTP}_dev/g" "$f"
  sed -i -E "s/\b${OLD_OTP}_test\b/${NEW_OTP}_test/g" "$f"
  sed -i -E "s/\b${OLD_OTP}_prod\b/${NEW_OTP}_prod/g" "$f"
done

# 3) Update env example DB name
if [ -f .env.dev.example ]; then
  sed -i -E "s/\b${OLD_OTP}_dev\b/${NEW_OTP}_dev/g" .env.dev.example
fi

echo "Done. Next steps:"
echo "  rm -rf _build deps priv/static/assets"
echo "  mix deps.get && mix compile"
echo "  mix ecto.drop || true && MIX_ENV=dev PGDATABASE=${NEW_OTP}_dev mix ecto.create"
