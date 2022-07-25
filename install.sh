#!/bin/sh

NVIM_CONFIG_DIR="$HOME/.config/nvim"

mkdir -p "$NVIM_CONFIG_DIR"

curl 'https://raw.githubusercontent.com/golmman/vim_config/main/.vimrc' > "${NVIM_CONFIG_DIR}/init.vim"
