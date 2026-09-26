#!/bin/sh

# Checks that a machine set up by ./install.sh actually works, not just that
# the install didn't fail.

set -eu

export PATH="$HOME/.local/bin:$PATH"

step() { printf '\n==> %s\n' "$*"; }

step "Every managed file is in its intended state"
chezmoi verify

step "A second apply has nothing left to do"
pending="$(chezmoi status)"
if [ -n "$pending" ]; then
  echo "$pending"
  exit 1
fi

step "Non-login zsh finds mise from a bare PATH"
env -i HOME="$HOME" PATH=/usr/bin:/bin zsh -c 'mise --version'

step "mise config loads without a secrets file"
mise env > /dev/null

step "mise loads and redacts ~/.config/mise/secrets.env"
secrets="$HOME/.config/mise/secrets.env"
if [ ! -e "$secrets" ]; then
  printf "CI_FAKE_SECRET='not-a-real-secret'\n" > "$secrets"
  chmod 600 "$secrets"
  loaded="$(cd "$HOME" && mise exec -- sh -c 'echo "$CI_FAKE_SECRET"')"
  listed="$(cd "$HOME" && mise set | awk '$1 == "CI_FAKE_SECRET" { print $2 }')"
  rm "$secrets"
  [ "$loaded" = "not-a-real-secret" ] || { echo "secret not loaded"; exit 1; }
  [ "$listed" = "[redacted]" ] || { echo "secret not redacted: $listed"; exit 1; }
fi

step "No broken mise shims"
shims="$HOME/.local/share/mise/shims"
if [ -d "$shims" ]; then
  broken="$(find "$shims" -type l ! -exec test -e {} \; -print)"
  if [ -n "$broken" ]; then
    echo "$broken"
    exit 1
  fi
fi

step "Interactive login zsh starts without errors"
output="$(zsh -lic exit 2>&1)"
errors="$(zsh -lic exit 2>&1 >/dev/null)"
if [ -n "$errors" ] || echo "$output" | grep -qi 'not found'; then
  echo "$output"
  exit 1
fi

step "Git prompt handles a non-ASCII branch name"
repo="$(mktemp -d)/äö"
mkdir -p "$repo"
git -C "$repo" init -q
git -C "$repo" checkout -q -b hyvä-haara
git -C "$repo" -c user.name=ci -c user.email=ci@example.com commit -q --allow-empty -m test
output="$(cd "$repo" && env -u LANG -u LC_ALL -u LC_CTYPE zsh -lic 'git_prompt_info' 2>&1)"
echo "$output"
case "$output" in
  *"not in range"*) exit 1 ;;
  *hyvä-haara*) ;;
  *) echo "branch name missing from prompt"; exit 1 ;;
esac
