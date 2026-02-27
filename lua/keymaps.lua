-- Enhanced keymaps with modern conventions

-- Leader key
vim.g.mapleader = ","

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
vim.keymap.set("n", "<leader>=", ":resize +5<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<leader>-", ":resize -5<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<leader>>", ":vertical resize +5<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<leader><", ":vertical resize -5<CR>", { desc = "Decrease window width" })

-- Split windows
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>xc", ":close<CR>", { desc = "Close window" })

-- Terminal management
vim.keymap.set("n", "<leader>t", ":vsplit term://bash<CR>", { desc = "Split terminal" })
vim.keymap.set("n", "<leader>T", ":split term://bash<CR>", { desc = "Horizontal terminal" })

-- Terminal navigation
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Move to left window" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Move to top window" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Move to right window" })
vim.keymap.set("t", "<C-[>", "<C-\\><C-N>", { desc = "Exit terminal" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-N>", { desc = "Exit terminal" })

-- File operations
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>QQ", "<cmd>qa<CR>", { desc = "Quit all" })

-- Editor basics
vim.keymap.set("n", "x", '"_x', { desc = "Delete (no register)" })
vim.keymap.set("v", "x", '"_x', { desc = "Delete (no register)" })
vim.keymap.set("n", "c", '"_c', { desc = "Change (no register)" })
vim.keymap.set("v", "c", '"_c', { desc = "Change (no register)" })
vim.keymap.set("n", "C", '"_C', { desc = "Change line (no register)" })
vim.keymap.set("v", "C", '"_C', { desc = "Change line (no register)" })
vim.keymap.set("n", "D", '"_D', { desc = "Delete line (no register)" })
vim.keymap.set("v", "D", '"_D', { desc = "Delete line (no register)" })
vim.keymap.set("n", "d", '"_d', { desc = "Delete (no register)" })
vim.keymap.set("v", "d", '"_d', { desc = "Delete (no register)" })
vim.keymap.set("v", "p", "pgvy", { desc = "Paste (re-select)" })

-- System clipboard
vim.keymap.set("n", "<leader>x", '"+x', { desc = "Cut to clipboard" })
vim.keymap.set("v", "<leader>x", '"+x', { desc = "Cut to clipboard" })
vim.keymap.set("n", "<leader>c", '"+c', { desc = "Copy to clipboard" })
vim.keymap.set("v", "<leader>c", '"+c', { desc = "Copy to clipboard" })
vim.keymap.set("n", "<leader>C", '"+C', { desc = "Copy line to clipboard" })
vim.keymap.set("v", "<leader>C", '"+C', { desc = "Copy line to clipboard" })
vim.keymap.set("n", "<leader>d", '"+d', { desc = "Delete to clipboard" })
vim.keymap.set("v", "<leader>d", '"+d', { desc = "Delete to clipboard" })
vim.keymap.set("n", "<leader>D", '"+D', { desc = "Delete line to clipboard" })
vim.keymap.set("v", "<leader>D", '"+D', { desc = "Delete line to clipboard" })

-- Editor improvements
vim.keymap.set("n", "<leader>tn", ":set nu!<CR>", { desc = "Toggle line numbers" })
vim.keymap.set("n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle word wrap" })
vim.keymap.set("n", "<leader>ts", ":set spell!<CR>", { desc = "Toggle spell check" })
vim.keymap.set("n", "<leader>tl", ":set list!<CR>", { desc = "Toggle list characters" })
vim.keymap.set("n", "<leader>tc", ":set cursorline!<CR>", { desc = "Toggle cursor line" })

-- IDE mode toggle
vim.keymap.set("n", "<F4>", ":lua ToggleIde()<CR>", { desc = "Toggle IDE mode" })

-- Toggle modifiable
vim.keymap.set("n", "<A-space>", ":lua ToggleModifiable()<CR>", { desc = "Toggle modifiable" })

-- Buffer management
vim.keymap.set("n", "<A-h>", ":bprev<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<A-l>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<A-p>", ":lua DeleteCurrentBuffer()<CR>", { noremap = true, silent = true, desc = "Delete current buffer" })
vim.keymap.set("n", "<A-o>", ":lua CloseHiddenBuffers()<CR>", { noremap = true, silent = true, desc = "Close hidden buffers" })

-- Buffer list and switch
vim.keymap.set("n", "<leader>l", ":ls<CR>:b ", { desc = "List and switch buffer" })

-- Refresh syntax
vim.keymap.set("n", "m", ":syntax sync fromstart<CR>", { desc = "Refresh syntax" })

-- Fold/unfold
vim.keymap.set("n", "zz", "za", { desc = "Toggle fold" })

-- Clear search highlights
vim.keymap.set("n", "<backspace>", ":noh<CR>", { silent = true, desc = "Clear search highlights" })

-- Insert blank line in normal mode
vim.keymap.set("n", "<enter>", "o<esc>", { desc = "Insert blank line" })

-- Terminal history navigation
vim.keymap.set("t", "<A-k>", "<up>", { desc = "History up" })
vim.keymap.set("t", "<A-j>", "<down>", { desc = "History down" })

-- LSP keymaps (Alt-based from original)
vim.keymap.set("i", "<A-w>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", { desc = "Signature help" })
vim.keymap.set("n", "<A-w>", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover" })
vim.keymap.set("n", "<A-e>", "<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code action" })
vim.keymap.set("n", "<A-r>", "<cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })
vim.keymap.set("n", "<A-i>", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "Go to implementation" })
vim.keymap.set("n", "<A-d>", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })
vim.keymap.set("n", "<A-a>", "<cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Show diagnostic" })

-- Formatter keymaps by filetype (Alt-f)
vim.keymap.set("n", "<A-f>", function()
    local ft = vim.bo.filetype
    if ft == "rust" then
        vim.lsp.buf.format()
    elseif ft == "scala" then
        vim.lsp.buf.format()
    else
        -- Use conform.nvim for other filetypes
        require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 500 })
    end
end, { desc = "Format file" })

-- Linter keymaps by filetype (Alt-c)
vim.keymap.set("n", "<A-c>", function()
    local ft = vim.bo.filetype
    local cmd = nil
    
    if ft == "python" then
        cmd = "cd %:h; python3 -m flake8 %:t"
    elseif ft == "sh" then
        cmd = "shellcheck %"
    elseif ft == "rust" then
        cmd = "cargo clippy -- -W clippy::all"
    elseif ft == "javascript" then
        cmd = "cd %:h; npx eslint %:t"
    elseif ft == "terraform" then
        cmd = "cd %:h; terraform validate -no-color"
    end
    
    if cmd then
        vim.cmd("!" .. cmd)
    end
end, { desc = "Run linter" })

-- Navigation
vim.keymap.set("n", "j", "v:count ? 'j' : 'gj'", { expr = true, desc = "Move down" })
vim.keymap.set("n", "k", "v:count ? 'k' : 'gk'", { expr = true, desc = "Move up" })
vim.keymap.set("n", "0", "^", { desc = "Move to first non-blank" })
vim.keymap.set("n", "$", "g_", { desc = "Move to last non-blank" })

-- Quickfix navigation
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })

-- Static cursor movement (screen scrolls, cursor stays)
vim.keymap.set("n", "<M-j>", "Mj<C-e>", { desc = "Scroll down (cursor static)" })
vim.keymap.set("n", "<M-k>", "Mk<C-y>", { desc = "Scroll up (cursor static)" })

-- Command mode navigation
vim.keymap.set("c", "<C-p>", "<Up>", { desc = "History up" })
vim.keymap.set("c", "<C-n>", "<Down>", { desc = "History down" })

-- Insert mode improvements
vim.keymap.set("i", "<C-a>", "<Home>", { desc = "Move to start of line" })
vim.keymap.set("i", "<C-e>", "<End>", { desc = "Move to end of line" })

-- Expand region (text objects)
vim.keymap.set({ "n", "v" }, "<M-,>", "<Plug>(expand_region_shrink)", { desc = "Shrink selection" })
vim.keymap.set({ "n", "v" }, "<M-.>", "<Plug>(expand_region_expand)", { desc = "Expand selection" })
