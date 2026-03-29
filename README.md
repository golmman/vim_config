# vim_config

A modern Neovim configuration written in Lua.

## Features

- **Plugin Management**: Uses `lazy.nvim` for fast and efficient plugin loading
- **LSP Support**: Built-in Language Server Protocol configuration for TypeScript, Svelte, Scala, Rust, Python, and Go
- **Syntax Highlighting**: Tree-sitter powered syntax highlighting
- **Fuzzy Finding**: Telescope with fzf-native for file and text search
- **File Explorer**: nvim-tree for file navigation
- **Auto-formatting**: Prettier, Black, and LSP formatting support
- **Custom IDE Mode**: Toggle terminal and file explorer with F4

## Installation

### Automatic Installation

```bash
curl -sSf 'https://raw.githubusercontent.com/golmman/vim_config/main/install.sh' | sh
```

### Manual Installation

1. Clone or download this repository
2. Copy all files to `$HOME/.config/nvim/`:
   ```bash
   cp -r init.lua lua ~/.config/nvim/
   ```
3. Start Neovim - lazy.nvim will automatically install all plugins on first launch

## Requirements

- Neovim >= 0.11.0
- Git (for cloning plugins)
- Node.js (for LSP servers and formatters)
- [ripgrep](https://github.com/BurntSushi/ripgrep#installation) (required for Telescope live grep)
- [prettier](https://prettier.io/) (formatting for JS, TS, CSS, HTML, JSON, Markdown, YAML, Svelte)
- Optional: [fd](https://github.com/sharkdp/fd#installation) (faster file finding for Telescope)

On macOS:
```bash
brew install ripgrep fd
```

## Structure

```
~/.config/nvim/
├── init.lua              # Entry point
└── lua/
    ├── options.lua       # General Neovim settings
    ├── keymaps.lua       # Custom keybindings
    ├── plugins.lua       # Plugin definitions and configuration
    ├── lsp.lua           # LSP server configuration
    ├── autocmds.lua      # Autocommands
    ├── functions.lua     # Custom utility functions
    └── todo_sync.lua     # Todo repository synchronization
```

## Migration from init.vim

If you were using the old `init.vim` configuration:

1. Backup your current config: `mv ~/.config/nvim ~/.config/nvim.backup`
2. Run the installation command above
3. Start Neovim and wait for lazy.nvim to install plugins
4. Run `:checkhealth` to verify everything is working

The old `init.vim` has been removed in favor of the new Lua-based configuration.
