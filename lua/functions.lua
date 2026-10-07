-- Custom functions

vim.g.ide_mode = vim.g.ide_mode or "none"

function SetTraditionalIdeLayout()
    if vim.g.ide_mode ~= "traditional" then
        return
    end
    local termids = {}
    for i = 1, vim.fn.bufnr("$") do
        if vim.fn.bufexists(i) == 1 and vim.fn.getbufvar(i, "my_term", 0) == 1 then
            table.insert(termids, i)
        end
    end
    if #termids > 0 then
        local termid = termids[1]
        local winids = vim.fn.win_findbuf(termid)
        if #winids > 0 then
            local winid = winids[1]
            vim.fn.win_execute(winid, "res 15")
            vim.cmd("redraw!")
        end
    end
end

local function fix_tree_layout(equalize_cmd)
    local tree_win
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
            tree_win = win
            break
        end
    end
    if not tree_win then
        return
    end

    vim.fn.win_execute(
        tree_win,
        "setlocal winfixwidth | vertical resize " .. vim.g.nvim_tree_width .. " | " .. equalize_cmd
    )
end

function SetVerticalIdeLayout()
    if vim.g.ide_mode ~= "vertical" then
        return
    end
    fix_tree_layout("horizontal wincmd =")
end

function SetAgentIdeLayout()
    if vim.g.ide_mode ~= "agent" then
        return
    end
    fix_tree_layout("wincmd =")
end

function SetIdeLayout()
    if vim.g.ide_mode == "traditional" then
        SetTraditionalIdeLayout()
    elseif vim.g.ide_mode == "vertical" then
        SetVerticalIdeLayout()
    elseif vim.g.ide_mode == "agent" then
        SetAgentIdeLayout()
    end
end

-- Shared prelude for the Setup* functions. Aborts (returns false) when a
-- terminal buffer already exists, matching the previous per-function guard.
local function setup_ide_base()
    vim.opt.titlestring = "nvim | " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "/"

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            return false
        end
    end

    local current_buf = vim.api.nvim_get_current_buf()
    local is_empty = vim.fn.bufname(current_buf) == "" and vim.bo[current_buf].modified == false

    vim.cmd("NvimTreeOpen")
    vim.cmd("wincmd l")

    local new_buf = vim.api.nvim_win_get_buf(0)
    if vim.bo[new_buf].filetype == "NvimTree" then
        vim.cmd("vsplit")
        vim.cmd("wincmd l")
    end

    if not is_empty and vim.api.nvim_buf_is_valid(current_buf) then
        vim.api.nvim_win_set_buf(0, current_buf)
    end
    return true
end

function SetupIdeTraditional()
    if not setup_ide_base() then
        return
    end

    vim.cmd("below 15sp")
    vim.cmd("term bash")
    vim.bo.filetype = "terminal"
    vim.b.my_term = 1

    vim.cmd("wincmd k")
end

function SetupIdeVertical()
    if not setup_ide_base() then
        return
    end

    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("term bash")
    vim.bo.filetype = "terminal"
    vim.b.my_term = 1

    vim.cmd("wincmd h")
end

function SetupIdeAgent()
    if not setup_ide_base() then
        return
    end

    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("term bash")
    vim.bo.filetype = "terminal"
    vim.b.my_term = 1

    vim.cmd("split")
    vim.cmd("term bash")
    vim.bo.filetype = "terminal"
    vim.b.my_term = 1

    vim.cmd("wincmd h")
end

function DestroyIde()
    vim.opt.titlestring = "nvim | %f"
    vim.cmd("NvimTreeClose")
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            vim.cmd("silent! bdelete! " .. buf)
        end
    end
end

local function toggle_ide(mode, setup)
    if vim.g.ide_mode ~= "none" then
        DestroyIde()
    end
    if vim.g.ide_mode == mode then
        vim.g.ide_mode = "none"
    else
        setup()
        vim.g.ide_mode = mode
    end
end

function ToggleIdeTraditional()
    toggle_ide("traditional", SetupIdeTraditional)
end

function ToggleIdeVertical()
    toggle_ide("vertical", SetupIdeVertical)
end

function ToggleIdeAgent()
    toggle_ide("agent", SetupIdeAgent)
end

function ToggleModifiable()
    vim.bo.modifiable = not vim.bo.modifiable
end

function DeleteCurrentBuffer()
    local current_buffer = vim.fn.bufnr("")
    vim.cmd("bnext")
    vim.cmd("bd " .. current_buffer)
end

function CloseHiddenBuffers()
    local buffers = vim.api.nvim_list_bufs()
    for _, buffer in ipairs(buffers) do
        local buf_info = vim.fn.getbufinfo(buffer)[1]
        if buf_info and buf_info.hidden == 1 then
            vim.cmd("silent bw " .. buffer)
        end
    end
    vim.cmd("silent redrawtabline")
end

function TermUp()
    vim.cmd("leftabove horizontal split term://bash")
end

function TermDown()
    vim.cmd("rightbelow horizontal split term://bash")
end

function TermRight()
    vim.cmd("rightbelow vertical split term://bash")
end

function TermLeft()
    vim.cmd("leftabove vertical split term://bash")
end
