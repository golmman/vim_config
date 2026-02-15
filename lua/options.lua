-- General Neovim options

-- Disable netrw (using NERDTree instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Encoding
vim.opt.encoding = "utf-8"

-- Colors
vim.opt.termguicolors = true
vim.cmd("syntax on")

-- Colorscheme is set in plugins.lua after onedark.vim is loaded
-- Window highlight groups will be set in autocmds.lua after colorscheme loads

-- List characters
vim.opt.listchars = {
    trail = "·",
    extends = ">",
    precedes = "<",
    tab = "▸ ",
}
vim.opt.list = true

-- UI settings
vim.opt.signcolumn = "yes"
vim.opt.wildmenu = true
vim.opt.showcmd = true
vim.opt.scrolloff = 2
vim.opt.laststatus = 2
vim.opt.number = true
vim.opt.colorcolumn = "80"
vim.opt.hidden = true
vim.opt.title = true
vim.opt.titlestring = "nvim | %f"

-- Markdown folding
vim.g.markdown_folding = 1

-- Wrap and linebreak
vim.opt.wrap = true
vim.opt.linebreak = true

-- Disable mouse
vim.opt.mouse = ""

-- Code completion
vim.opt.completeopt = { "menuone", "noselect" }

-- Search settings
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Autosave
vim.opt.updatetime = 200

-- Folding / code collapse
-- open/close fold: zo/zc
vim.opt.foldmethod = "indent"
vim.opt.foldlevelstart = 20

-- Matching brackets
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.api.nvim_set_hl(0, "MatchParen", { bold = true, underline = true, bg = "none", fg = "none" })

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Indentation
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 0
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.smarttab = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Filetype settings (to be handled in autocmds)
