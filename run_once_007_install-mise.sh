#!/bin/sh

# Install mise with its official installer (https://mise.run): a single,
# checksum-verified binary in ~/.local/bin, the same on macOS and Linux, with
# no package manager or sudo. Update it later with `mise self-update`.

set -e

if command -v mise >/dev/null 2>&1 || [ -x "$HOME/.local/bin/mise" ]; then
  echo "mise is already installed"
  exit 0
fi

installer="$(mktemp)"
trap 'rm -f "$installer"' EXIT

if command -v curl >/dev/null 2>&1; then
  curl -fsSL --proto '=https' --tlsv1.2 https://mise.run -o "$installer"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$installer" https://mise.run
else
  echo "Installing mise needs curl or wget." >&2
  exit 1
fi

sh "$installer"
