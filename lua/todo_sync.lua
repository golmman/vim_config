-- Todo repo synchronization functions

vim.g.todo_repo_url = "github.com/golmman/todo"
vim.g.todo_repo_bg_color = "#13011e"
vim.g.todo_repo_sync_timer_interval = 30000
vim.g.todo_repo_init = "" -- 'lua SetupIde()'

vim.g.todo_repo_insert_mode = false
vim.g.todo_timer_pause = false

function SyncTodoRepo(timer_id)
    if vim.g.todo_repo_insert_mode then
        return
    end

    vim.fn.system("git pull")
    vim.fn.system("git add .")
    vim.fn.system('git commit -m "auto update via vim"')
    vim.fn.system("git push")

    -- Refresh all buffers which have a file name
    local old_confirm = vim.opt.confirm:get()
    vim.opt.confirm = false
    local current_buffer = vim.fn.bufnr("%")
    vim.cmd("bufdo! if expand('%:p') != '' | edit | endif")
    vim.cmd("buffer " .. current_buffer)
    vim.cmd("redraw")
    vim.opt.confirm = old_confirm

    print("synced at " .. os.date("%H:%M:%S"))
end

function PauseTodoTimer()
    vim.g.todo_timer_pause = true
    StopTodoTimer()
    SyncTodoRepo(0)
    print("sync paused at " .. os.date("%H:%M:%S"))
end

function UnpauseTodoTimer()
    vim.g.todo_timer_pause = false
    SyncTodoRepo(0)
    RestartTodoTimer()
end

function StopTodoTimer()
    if vim.g.todo_timer then
        vim.fn.timer_stop(vim.g.todo_timer)
    end
end

function RestartTodoTimer()
    if vim.g.todo_timer_pause and vim.g.todo_timer_pause then
        return
    end

    StopTodoTimer()

    vim.g.todo_timer = vim.fn.timer_start(vim.g.todo_repo_sync_timer_interval, "SyncTodoRepo", { repeat_count = -1 })
end

function SetTodoRepoIntegration()
    local is_git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):match(vim.fn.system("pwd"))
    if is_git_root then
        local is_todo_repo = vim.fn.system("git config --get remote.origin.url"):match(vim.g.todo_repo_url)
        if is_todo_repo then
            vim.api.nvim_set_hl(0, "Normal", { bg = vim.g.todo_repo_bg_color })

            vim.api.nvim_create_autocmd("InsertEnter", {
                pattern = "*",
                callback = function()
                    vim.g.todo_repo_insert_mode = true
                end,
            })

            vim.api.nvim_create_autocmd("InsertLeave", {
                pattern = "*",
                callback = function()
                    vim.g.todo_repo_insert_mode = false
                end,
            })

            vim.api.nvim_create_autocmd("CursorHold", {
                pattern = "*",
                callback = RestartTodoTimer,
            })

            vim.api.nvim_create_autocmd("CursorHoldI", {
                pattern = "*",
                callback = RestartTodoTimer,
            })

            vim.api.nvim_create_autocmd("FocusLost", {
                pattern = "*",
                callback = PauseTodoTimer,
            })

            vim.api.nvim_create_autocmd("FocusGained", {
                pattern = "*",
                callback = UnpauseTodoTimer,
            })

            vim.api.nvim_create_autocmd("VimLeavePre", {
                pattern = "*",
                callback = function()
                    SyncTodoRepo(0)
                end,
            })

            SyncTodoRepo(0)

            if vim.g.todo_repo_init ~= "" then
                vim.cmd(vim.g.todo_repo_init)
            end
        end
    end
end

-- Disable for now (as in original config)
-- vim.api.nvim_create_autocmd("VimEnter", {
--     pattern = "*",
--     callback = SetTodoRepoIntegration,
-- })
