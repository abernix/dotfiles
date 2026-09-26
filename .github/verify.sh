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

step "Non-login zsh finds mise"
zsh -c 'mise --version'

step "Interactive login zsh starts without errors"
errors="$(zsh -lic exit 2>&1 >/dev/null)"
if [ -n "$errors" ]; then
  echo "$errors"
  exit 1
fi

step "Git prompt handles a non-ASCII branch name"
repo="$(mktemp -d)/äö"
mkdir -p "$repo"
git -C "$repo" init -q
git -C "$repo" checkout -q -b hyvä-haara
git -C "$repo" -c user.name=ci -c user.email=ci@example.com commit -q --allow-empty -m test
output="$(cd "$repo" && env -u LANG -u LC_ALL -u LC_CTYPE zsh -lic '_omz_git_prompt_info' 2>&1)"
echo "$output"
case "$output" in
  *"not in range"*) exit 1 ;;
  *hyvä-haara*) ;;
  *) echo "branch name missing from prompt"; exit 1 ;;
esac
