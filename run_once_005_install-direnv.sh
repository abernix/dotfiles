#!/bin/sh

set -e

binary_name="direnv"

if [ ! "$(command -v $binary_name)" ]; then
  install_path="$HOME/.local/bin"
  if [ ! -d "$install_path" ]; then
    mkdir -p "$install_path"
  fi

  if [ ! -f "$install_path/$binary_name" ]; then
    curl -sfL https://direnv.net/install.sh | bin_path="$install_path" bash
  fi
else
  echo "$binary_name is already installed"
fi
