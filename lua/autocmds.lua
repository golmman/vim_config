-- Enhanced autocmds for better development experience

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- File type specific indentation
autocmd("FileType", {
    pattern = { "javascript", "json", "markdown", "typescript", "typescriptreact", "typescript.tsx", "vim", "lua", "bash", "zsh", "yaml", "yml", "terraform", "hcl", "sql" },
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.expandtab = true
    end,
})

autocmd("FileType", {
    pattern = { "python", "rust", "go" },
    callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.expandtab = true
    end,
})

-- File type detection
autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "" then
            vim.bo.filetype = "unknown"
        end
    end,
})

autocmd("TermOpen", {
    pattern = "*",
    callback = function()
        vim.bo.filetype = "terminal"
    end,
})

autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.vue",
    callback = function()
        vim.bo.filetype = "html"
    end,
})

autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.",
    callback = function()
        vim.bo.filetype = "sh"
    end,
})

autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.tf",
    callback = function()
        vim.bo.filetype = "hcl"
    end,
})

autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "*.graphql",
    callback = function()
        vim.bo.filetype = "graphql"
    end,
})

-- Prevent automatic comments
autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "o" })
    end,
})

-- Hide terminal and NvimTree buffers from tabline
autocmd({ "TermOpen", "BufEnter" }, {
    pattern = "*",
    callback = function()
        local buftype = vim.bo.buftype
        local filetype = vim.bo.filetype
        if buftype == "terminal" or filetype == "NvimTree" then
            vim.bo.buflisted = false
        end
    end,
})

-- Filetype autocommands
autocmd("FileType", {
    pattern = "help",
    callback = function()
        vim.opt_local.number = false
    end,
})

autocmd("FileType", {
    pattern = "man",
    callback = function()
        vim.opt_local.number = false
    end,
})

autocmd("FileType", {
    pattern = { "gitcommit", "gitrebase" },
    callback = function()
        vim.opt_local.colorcolumn = { 80 }
    end,
})

-- Resize terminal after window resize
autocmd("VimResized", {
    pattern = "*",
    callback = SetTerminalSize,
})

-- NvimTree settings
autocmd("FileType", {
    pattern = "NvimTree",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.spell = false
    end,
})


-- Auto-reload modified files
vim.opt.autoread = true
autocmd({ "FocusGained", "BufEnter" }, {
    pattern = "*",
    command = "checktime",
})

-- Auto create missing directories
autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        local file = vim.fn.expand("%:p")
        local dir = vim.fn.fnamemodify(file, ":h")
        if dir ~= "" and not vim.fn.isdir(dir) then
            vim.fn.mkdir(dir, "p")
        end
    end,
})

-- Autocommand groups
local auto_highlight_group = augroup("AutoHighlight", { clear = true })
autocmd("CursorMoved", {
    group = auto_highlight_group,
    pattern = "*",
    callback = function()
        vim.opt.concealcursor = "n"
    end,
})
autocmd("CursorMovedI", {
    group = auto_highlight_group,
    pattern = "*",
    callback = function()
        vim.opt.concealcursor = ""
    end,
})

local highlight_group = augroup("HighlightSearch", { clear = true })
autocmd("CmdlineEnter", {
    group = highlight_group,
    pattern = { "/", "?" },
    callback = function()
        vim.opt.hlsearch = true
    end,
})
autocmd("CmdlineLeave", {
    group = highlight_group,
    pattern = { "/", "?" },
    callback = function()
        vim.opt.hlsearch = false
    end,
})

-- Set cursorline and window highlighting
local bg_highlight_group = augroup("BgHighlight", { clear = true })

-- Apply highlights when entering/leaving windows
autocmd("WinEnter", {
    group = bg_highlight_group,
    pattern = "*",
    callback = function()
        vim.opt.cursorline = true
        -- Set active window highlight (darker background)
        vim.opt_local.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"
    end,
})
autocmd("WinLeave", {
    group = bg_highlight_group,
    pattern = "*",
    callback = function()
        vim.opt.cursorline = false
        -- Set inactive window highlight
        vim.opt_local.winhighlight = "Normal:InactiveWindow,NormalNC:InactiveWindow"
    end,
})

-- Initialize highlighting for existing windows on startup
autocmd("VimEnter", {
    group = bg_highlight_group,
    pattern = "*",
    callback = function()
        -- Define highlight groups for active/inactive windows
        -- Active window: darker background
        vim.api.nvim_set_hl(0, "ActiveWindow", { bg = "#1e222a" })
        -- Inactive window: same as normal background
        vim.api.nvim_set_hl(0, "InactiveWindow", {})
        -- Apply to current window
        vim.opt_local.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"
    end,
})

-- Apply highlighting when buffer enters a window
autocmd("BufWinEnter", {
    group = bg_highlight_group,
    pattern = "*",
    callback = function()
        vim.schedule(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local current_win = vim.api.nvim_get_current_win()
                if win == current_win then
                    vim.wo[win].winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"
                else
                    vim.wo[win].winhighlight = "Normal:InactiveWindow,NormalNC:InactiveWindow"
                end
            end
        end)
    end,
})

-- Jump to last edit location
autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})


-- Save folds for next session (optional, disabled by default)
-- autocmd("BufWritePost", {
--     pattern = "*",
--     callback = function()
--         vim.cmd("mkview")
--     end,
-- })
-- autocmd("BufReadPre", {
--     pattern = "*",
--     callback = function()
--         vim.cmd("silent! loadview")
--     end,
-- })

-- Handle swap files
autocmd("BufRead", {
    pattern = "*",
    callback = function()
        vim.opt.swapfile = false
    end,
})

-- Syntax settings
autocmd("FileType", {
    pattern = { "gitconfig", "gitattributes", "gitignore" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.expandtab = true
    end,
})

-- Syntax sync on BufEnter
autocmd("BufEnter", {
    pattern = "*",
    command = "syntax sync fromstart",
})

-- Auto-save on cursor hold
autocmd("CursorHold", {
    pattern = "*",
    command = "silent! wa",
})

-- When entering a buffer whose file has been deleted on disk, wipe it and
-- switch to the next existing file buffer. This prevents auto-save errors
-- on stale buffers.
autocmd({ "BufReadPost", "BufWritePost" }, {
    pattern = "*",
    callback = function(args)
        vim.b[args.buf].file_on_disk = true
    end,
})

autocmd("BufEnter", {
    pattern = "*",
    callback = function(args)
        local bufnr = args.buf

        -- Only regular file buffers (skip terminal, NvimTree, etc.)
        if vim.bo[bufnr].buftype ~= "" then return end
        -- Only buffers that were previously backed by a real file on disk
        if not vim.b[bufnr].file_on_disk then return end

        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" or vim.fn.filereadable(name) == 1 then return end

        -- File has been deleted externally. Forward to the next valid file
        -- buffer, then wipe this one. Deferred to avoid running during the
        -- BufEnter dispatch itself.
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(bufnr) then return end
            if vim.api.nvim_get_current_buf() ~= bufnr then
                vim.cmd("silent! bwipeout! " .. bufnr)
                return
            end

            local next_buf
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if buf ~= bufnr
                    and vim.api.nvim_buf_is_valid(buf)
                    and vim.bo[buf].buflisted
                    and vim.bo[buf].buftype == ""
                then
                    local bufname = vim.api.nvim_buf_get_name(buf)
                    if bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
                        next_buf = buf
                        break
                    end
                end
            end

            if next_buf then
                vim.api.nvim_set_current_buf(next_buf)
            end
            vim.cmd("silent! bwipeout! " .. bufnr)
        end)
    end,
})


