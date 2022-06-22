#!/bin/sh

set -e

if [ ! -d "$HOME/.asdf" ]; then
  git clone https://www.github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
else
  echo "asdf is already installed"
fi
