#!/bin/sh

# Seed mise's global config with a baseline set of tools, pinned to the
# versions that are current at install time. Only runs on machines that don't
# have a global mise config yet; after that, mise owns the file
# (`mise use -g --pin foo@latest`, `mise upgrade --bump`).

set -e

config="${MISE_GLOBAL_CONFIG_FILE:-${MISE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/mise}/config.toml}"

if [ -e "$config" ]; then
  echo "$config already exists, not seeding mise tools"
  exit 0
fi

if [ -n "$CI" ] || [ -n "$CODESPACES" ]; then
  echo "Skipping mise tool seeding in CI and Codespaces"
  exit 0
fi

mise="$(command -v mise || true)"
for candidate in "$HOME/.local/bin/mise" /opt/homebrew/bin/mise /usr/local/bin/mise; do
  if [ -z "$mise" ] && [ -x "$candidate" ]; then
    mise="$candidate"
  fi
done
if [ -z "$mise" ]; then
  echo "mise is not installed; can't seed tools" >&2
  exit 1
fi

"$mise" use --global --pin \
  rust@latest \
  node@lts \
  uv@latest \
  gh@latest \
  rg@latest \
  claude@latest
