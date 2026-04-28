# AGENTS.md

## Project Overview

This repository is a personal **Neovim configuration** written in Lua. It is not
an application or library — the artifacts are config files that get copied to
`~/.config/nvim/` on the user's machine and loaded by Neovim at startup.

- **Entry point:** `init.lua` (just a chain of `require(...)` calls)
- **Plugin manager:** [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-bootstraps on first launch into `vim.fn.stdpath("data") .. "/lazy/lazy.nvim"`)
- **Required Neovim version:** **>= 0.11** (uses the new `vim.lsp.config` / `vim.lsp.enable` API)
- **Colorscheme:** `onedark.vim`
- **Status:** Mid-migration from the old vimscript config (`main` branch) to a Lua rewrite (`lua-rewrite` branch). Active work happens on `lua-rewrite`.

The user's stated goals for this rewrite are:

1. **Concise** — cut extra features that have slipped in over the years.
2. **Idiomatic** — prefer simple solutions over highly optimized workarounds.
3. **Readable / extendable / maintainable** — the user wants to be able to make small changes themselves.
4. **Feature-complete** — Neovim should behave the same as (or better than) the old vimscript config.

Keep these goals in mind when proposing changes. Prefer removing complexity over adding it.

## Repository Layout

```
.
├── init.lua              # Entry point: `require`s the modules below in order
├── install.sh            # Installs the config to ~/.config/nvim/ via curl
├── lua/
│   ├── options.lua       # vim.opt.* settings (indent, ui, search, clipboard…)
│   ├── functions.lua     # Global helper functions (ToggleIde, DeleteCurrentBuffer…)
│   ├── keymaps.lua       # All `vim.keymap.set(...)` calls; exports a small M
│   ├── plugins.lua       # lazy.nvim spec list; reads keymaps via `require("keymaps")`
│   ├── lsp.lua           # `vim.lsp.config` / `vim.lsp.enable` for ts_ls, svelte,
│   │                     #   metals, rust_analyzer, pyright, gopls
│   ├── autocmds.lua      # Filetype indent, tabline filtering, window highlight…
│   └── todo_sync.lua     # Auto git pull/commit/push for the user's todo repo
│                         #   (currently disabled — see VimEnter autocmd at the bottom)
├── prompts/              # Historical prompts the user gave previous AI agents.
│                         #   Useful context but NOT requirements.
├── README.md             # Human-facing docs (installation, requirements)
└── LICENSE               # MIT
```

The load order in `init.lua` matters: `options` → `functions` → `keymaps` →
`plugins` → `lsp` → `autocmds` → `todo_sync`. `plugins.lua` depends on
`keymaps.lua` exporting `M.cmp_mapping`, `M.expand_region`, and
`M.nvim_tree_on_attach`, so don't reorder these without thought.

## Setup Commands

There is no package manager and no build step. To work on the config locally:

- **Clone:** `git clone <repo> && cd vim_config`
- **Test against a live Neovim:** copy or symlink the files into `~/.config/nvim/`. Two options:
  - One-shot copy (matches what `install.sh` does, but local):
    ```bash
    mkdir -p ~/.config/nvim
    cp -r init.lua lua ~/.config/nvim/
    ```
  - Symlink for fast iteration (recommended while developing):
    ```bash
    mv ~/.config/nvim ~/.config/nvim.backup   # only if you have an existing config
    ln -s "$PWD" ~/.config/nvim
    ```
- **First launch:** start `nvim` once. lazy.nvim will clone itself, then install
  every plugin in `lua/plugins.lua`. Wait for it to finish before judging behavior.

`install.sh` is the **end-user** installer — it downloads files from
`raw.githubusercontent.com/.../main/...`. **Do not run it to test local
changes**: it pulls the `main` branch from GitHub and overwrites whatever you
have in `~/.config/nvim/`.

## Development Workflow

- **Iteration loop:** edit a `.lua` file in this repo → restart `nvim` (or
  `:source %` for cheap reloads of the file you just edited) → observe.
- **Inspect plugin state:** `:Lazy` (status), `:Lazy sync` (update/install).
- **Run a sanity check:** `:checkhealth` inside Neovim. Do this after touching
  `plugins.lua` or `lsp.lua`.
- **External requirements** the config assumes are on `$PATH`:
  - `git`, `node`, `ripgrep` (`rg`) — required
  - `fd` — optional, speeds up Telescope file finding
  - `prettier`, `black`, `rustfmt`, `scalafmt`, `terraform fmt` — only needed when
    the matching filetype is opened (used by `conform.nvim`)
  - LSP servers: `typescript-language-server` (ts_ls), `svelte-language-server`,
    `metals`, `rust-analyzer`, `pyright`, `gopls` — install per project as needed
- **Leader key is `,`** (set at the top of `lua/keymaps.lua`). Don't change it
  without an explicit request — many keymaps would silently break.
- **F4** toggles "IDE mode" (nvim-tree on the left + bash terminal at the bottom).
  See `SetupIde` / `DestroyIde` / `ToggleIde` in `lua/functions.lua`.

## Testing Instructions

There is **no test suite**. Verification is manual. After any change:

1. Launch `nvim` from a project directory and confirm it starts with no errors
   (check `:messages` if anything looks off).
2. Run `:checkhealth` and skim the report for new failures.
3. If you touched a plugin, exercise it (`<leader>ff` for Telescope,
   `<leader>e` to toggle nvim-tree, `K` for hover, etc.).
4. If you touched `lsp.lua`, open a file of the relevant filetype in a real
   project and confirm the LSP attaches: `:LspInfo` should list the server.
5. For automated startup smoke-checking you can run:
   ```bash
   nvim --headless "+lua print('ok')" +qa
   ```
   It should exit 0 with no Lua errors printed to stderr.

When changing keymaps, grep the whole repo (`keymaps.lua` is not the only
source — `plugins.lua` defines `<Plug>(expand_region_*)` mappings, and
`lsp.lua` does not currently set keymaps but `keymaps.lua` does at the bottom).

## Code Style

- **Lua, 4-space indent, double-quoted strings.** Match the surrounding file.
- **Per-filetype overrides** live in `autocmds.lua` (e.g. JS/TS/JSON/Lua/YAML
  use 2 spaces; Python/Rust/Go use 4). If you add new filetypes, add them
  there, don't sprinkle modeline-style hacks elsewhere.
- **Plugin specs** go in `lua/plugins.lua` inside the single `require("lazy").setup({...})`
  call. Use lazy-loading triggers (`event`, `cmd`, `ft`, `keys`) when reasonable —
  the existing entries are good templates.
- **Keymaps** belong in `lua/keymaps.lua`. Use `vim.keymap.set` (not the
  legacy `vim.api.nvim_set_keymap`) and always pass a `desc = "..."` for
  discoverability. Buffer-local plugin keymaps (e.g. nvim-tree's
  `on_attach`) are returned from `M` in `keymaps.lua` and consumed in
  `plugins.lua`.
- **LSP servers**: declare each server with `vim.lsp.config[name] = { ... }`
  followed by `vim.lsp.enable(name)`. Don't reintroduce
  `require("lspconfig").<server>.setup{}` — that style was deliberately removed.
- **Comments:** keep them sparse and only where intent is non-obvious (e.g. the
  block at the bottom of `autocmds.lua` explaining the deleted-file buffer
  cleanup). Don't add comments that just restate the code.
- **Globals:** functions defined in `functions.lua` are intentionally global
  (`function ToggleIde()` not `local M.toggle_ide`) because they're invoked
  from `:lua ToggleIde()<CR>` in keymaps. Keep this pattern when adding
  similar utilities.

## Branches

- **`main`** — legacy vimscript config. Treat as archive. **Do not commit Lua
  changes here** unless explicitly asked.
- **`lua-rewrite`** — current default working branch for all new work.
- Feature branches off `lua-rewrite` are fine; merges back into `lua-rewrite`
  should be reviewed by the user.

## Commit & PR Guidelines

Match the existing log style:

- **Imperative, lowercase, short.** Examples from history:
  - `optimize autocmds`
  - `move keymaps to keymaps file`
  - `add buffer clean up autocmd`
  - `prevent terminal and nvim-tree to appear in the tabline`
- One focused change per commit when practical.
- No conventional-commits prefixes (`feat:`, `fix:`, etc.) — they're not used here.
- **Do not push** unless the user asks.
- When opening a PR, target `lua-rewrite`, not `main`.

## Gotchas

- **`todo_sync.lua` is dormant.** The `VimEnter` autocmd that activates it is
  commented out at the bottom of the file. If a change to that file is
  requested, also re-enable that autocmd; otherwise leave it alone.
- **Auto-save is on.** A `CursorHold` autocmd in `autocmds.lua` runs `silent! wa`
  every `updatetime` (200ms). Code that performs side-effects on save (e.g.
  `BufWritePre` formatters) will fire frequently — be mindful when adding
  more `BufWritePre` autocmds.
- **Tabline filtering:** the lualine `tabline` config in `plugins.lua` and the
  `TermOpen`/`BufEnter` autocmd in `autocmds.lua` jointly hide terminals and
  NvimTree from the tabline. Both pieces are needed; changing only one will
  reintroduce ghost tabs (this was a real bug in the project's history — see
  `prompts/2025-02-27.md`).
- **Clipboard is unified with the system clipboard** via
  `vim.opt.clipboard = "unnamedplus"`. The `<leader>c` / `<leader>x` /
  `<leader>d` family explicitly targets `"+` for cases where the user wants
  to bypass the default register's behavior — keep them.
- **`init.vim` no longer exists.** The README's "Migration from init.vim"
  section refers to user migration, not files in this repo. Don't recreate it.
