#!/bin/sh

set -e

ZSH="$HOME/.oh-my-zsh/"
REMOTE="https://github.com/ohmyzsh/ohmyzsh.git"
BRANCH="master"

setup_ohmyzsh() {
  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  echo "Cloning Oh My Zsh..."

  ostype=$(uname)
  if [ -z "${ostype%CYGWIN*}" ] && git --version | grep -q msysgit; then
    echo "Windows/MSYS Git is not supported on Cygwin"
    echo "Make sure the Cygwin git package is installed and is first on the \$PATH"
    exit 1
  fi

  # Manual clone with git config options to support git < v1.7.2
  git init --quiet "$ZSH" && cd "$ZSH" \
  && git config core.eol lf \
  && git config core.autocrlf false \
  && git config fsck.zeroPaddedFilemode ignore \
  && git config fetch.fsck.zeroPaddedFilemode ignore \
  && git config receive.fsck.zeroPaddedFilemode ignore \
  && git config oh-my-zsh.remote origin \
  && git config oh-my-zsh.branch "$BRANCH" \
  && git remote add origin "$REMOTE" \
  && git fetch --depth=1 origin \
  && git checkout -b "$BRANCH" "origin/$BRANCH" || {
    [ ! -d "$ZSH" ] || {
      cd -
      rm -rf "$ZSH" 2>/dev/null
    }
    echo "git clone of oh-my-zsh repo failed"
    exit 1
  }
  # Exit installation directory
  cd -

  echo
}

if [ ! -d "$ZSH" ]; then
  echo "Couldn't find $ZSH, so we're installing it..."
  setup_ohmyzsh
fi

