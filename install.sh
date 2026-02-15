#!/bin/sh

NVIM_CONFIG_DIR="$HOME/.config/nvim"

mkdir -p "$NVIM_CONFIG_DIR"

# Download main init.lua
curl -sSf 'https://raw.githubusercontent.com/golmman/vim_config/main/init.lua' > "${NVIM_CONFIG_DIR}/init.lua"

# Create lua directory and download lua modules
mkdir -p "${NVIM_CONFIG_DIR}/lua"

for file in options.lua keymaps.lua plugins.lua lsp.lua autocmds.lua functions.lua todo_sync.lua; do
    curl -sSf "https://raw.githubusercontent.com/golmman/vim_config/main/lua/${file}" > "${NVIM_CONFIG_DIR}/lua/${file}"
done

echo 'vim config updated'
