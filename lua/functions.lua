-- Custom functions

vim.g.ide_mode = vim.g.ide_mode or "none"

function SetTerminalSize()
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

function SetupIdeTraditional()
    vim.opt.titlestring = "nvim | " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "/"

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            return
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

    vim.cmd("below 15sp")
    vim.cmd("term bash")
    vim.bo.filetype = "terminal"
    vim.b.my_term = 1

    vim.cmd("wincmd k")
end

function DestroyIdeTraditional()
    vim.opt.titlestring = "nvim | %f"
    vim.cmd("NvimTreeClose")
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            vim.cmd("silent! bdelete! " .. buf)
        end
    end
end

function ToggleIdeTraditional()
    if vim.g.ide_mode == "traditional" then
        DestroyIdeTraditional()
        vim.g.ide_mode = "none"
    else
        if vim.g.ide_mode == "vertical" then
            DestroyIdeVertical()
        end
        SetupIdeTraditional()
        vim.g.ide_mode = "traditional"
    end
end

function SetupIdeVertical()
    vim.opt.titlestring = "nvim | " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "/"

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            return
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

    vim.cmd("vsplit")
    vim.cmd("wincmd l")
    vim.cmd("term bash")
    vim.bo.filetype = "terminal"
    vim.b.my_term = 1

    vim.cmd("wincmd h")
end

function DestroyIdeVertical()
    vim.opt.titlestring = "nvim | %f"
    vim.cmd("NvimTreeClose")
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            vim.cmd("silent! bdelete! " .. buf)
        end
    end
end

function ToggleIdeVertical()
    if vim.g.ide_mode == "vertical" then
        DestroyIdeVertical()
        vim.g.ide_mode = "none"
    else
        if vim.g.ide_mode == "traditional" then
            DestroyIdeTraditional()
        end
        SetupIdeVertical()
        vim.g.ide_mode = "vertical"
    end
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
