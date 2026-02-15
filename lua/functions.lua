-- Custom functions

function SetTerminalSize()
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

function SetupIde()
    -- Show directory name as title
    vim.opt.titlestring = "nvim | " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. "/"

    -- Check if there's already a terminal - don't recreate
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            return
        end
    end

    -- Get current buffer and check if it's empty
    local current_buf = vim.api.nvim_get_current_buf()
    local is_empty = vim.fn.bufname(current_buf) == "" and vim.bo[current_buf].modified == false
    
    -- Open tree - this will create the left sidebar
    vim.cmd("NvimTreeOpen")
    
    -- Go to the window to the right of tree
    vim.cmd("wincmd l")
    
    -- If we're still showing the tree (wincmd l didn't work), create a split
    local new_buf = vim.api.nvim_win_get_buf(0)
    if vim.bo[new_buf].filetype == "NvimTree" then
        vim.cmd("vsplit")
        vim.cmd("wincmd l")
    end
    
    -- If original buffer was empty, use a new one, otherwise restore it
    if is_empty then
        vim.cmd("enew")
    elseif vim.api.nvim_buf_is_valid(current_buf) then
        vim.api.nvim_win_set_buf(0, current_buf)
    end
    
    -- Now split this window for terminal
    vim.cmd("below 15sp")
    vim.cmd("term bash")
    vim.bo.filetype = "terminal"
    vim.b.my_term = 1
    
    -- Go back to code window
    vim.cmd("wincmd k")
end

function DestroyIde()
    vim.opt.titlestring = "nvim | %f"
    vim.cmd("NvimTreeClose")
    -- Close all terminal buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == "terminal" then
            vim.cmd("silent! bdelete! " .. buf)
        end
    end
end

function ToggleIde()
    vim.g.is_ide_active = vim.g.is_ide_active or false
    if vim.g.is_ide_active then
        DestroyIde()
    else
        SetupIde()
    end
    vim.g.is_ide_active = not vim.g.is_ide_active
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
