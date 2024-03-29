#!/bin/sh

NVIM_CONFIG_DIR="$HOME/.config/nvim"

mkdir -p "$NVIM_CONFIG_DIR"

curl -sSf 'https://raw.githubusercontent.com/golmman/vim_config/main/init.vim' > "${NVIM_CONFIG_DIR}/init.vim"

echo 'vim config updated'
