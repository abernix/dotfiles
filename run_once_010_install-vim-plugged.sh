#!/bin/sh

set -e

echo "Installing vim-plugged to ~/.vim/autoload/plug.vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
