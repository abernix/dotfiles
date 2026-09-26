#!/bin/sh

set -e

url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
target="$HOME/.vim/autoload/plug.vim"

echo "Installing vim-plugged to ~/.vim/autoload/plug.vim"
mkdir -p "$(dirname "$target")"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$url" -o "$target"
else
  wget -qO "$target" "$url"
fi
