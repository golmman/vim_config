-- Modern Neovim configuration with lazy.nvim

local keys = require("keymaps")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Essential plugins
    {
        "nvim-lua/plenary.nvim",
        lazy = true,
    },

    -- LSP Configuration (kept for server definitions, but using vim.lsp.config API)
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- vim.lsp.config and vim.lsp.enable are used instead of lspconfig
            -- This plugin is kept for server definitions only
        end,
    },

    -- Fuzzy finder with better UI
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        cmd = "Telescope",
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    sorting_strategy = "ascending",
                    path_display = { shorten = { len = 1 } },
                },
            })
            telescope.load_extension("fzf")
        end,
    },

    -- Completion engine
    {
        "hrsh7th/nvim-cmp",
        version = "v2.x",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                mapping = keys.cmp_mapping(cmp),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                },
            })

            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "buffer" },
                },
            })

            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = "path" },
                    { name = "cmdline" },
                },
            })
        end,
    },

    -- Syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        main = "nvim-treesitter",
        opts = {
            ensure_installed = {
                "c",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "markdown",
                "markdown_inline",
                "html",
                "css",
                "javascript",
                "typescript",
                "rust",
                "svelte",
                "bash",
                "dockerfile",
                "graphql",
                "hurl",
                "json",
            },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                disable = function(lang, buf)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true,
            },
        },
    },

    -- File explorer (nvim-tree - modern NERDTree replacement)
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            local api = require("nvim-tree.api")

            require("nvim-tree").setup({
                on_attach = function(bufnr)
                    keys.nvim_tree_on_attach(api, bufnr)
                end,
                sort_by = "case_sensitive",
                view = {
                    width = 30,
                },
                renderer = {
                    group_empty = true,
                    add_trailing = true,
                    icons = {
                        show = {
                            file = false,
                            folder = false,
                            folder_arrow = false,
                            git = false,
                        },
                    },
                },
                filters = {
                    dotfiles = false,
                },
                actions = {
                    open_file = {
                        quit_on_open = false,
                        resize_window = false,
                        window_picker = {
                            enable = false,
                        },
                    },
                },
                hijack_directories = {
                    enable = false,
                },
                git = {
                    enable = true,
                    ignore = false,
                },
            })
        end,
    },

    -- Expand region (text objects)
    {
        "terryma/vim-expand-region",
        keys = keys.expand_region,
        init = function()
            vim.g.expand_region_text_objects = {
                iw = 0,
                ["i'"] = 1,
                ['i"'] = 1,
                ["i`"] = 1,
                ["i>"] = 1,
                ["i]"] = 1,
                ["i}"] = 1,
                ["i)"] = 1,
                it = 1,
                ["a'"] = 1,
                ['a"'] = 1,
                ["a`"] = 1,
                ["a>"] = 1,
                ["a]"] = 1,
                ["a}"] = 1,
                ["a)"] = 1,
                at = 1,
            }
        end,
    },

    -- Formatter
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        config = function()
            local conform = require("conform")

            conform.setup({
                format_on_save = {
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 500,
                },
                formatters_by_ft = {
                    css = { "prettier" },
                    html = { "prettier" },
                    javascript = { "prettier" },
                    json = { "prettier" },
                    markdown = { "prettier" },
                    python = { "black" },
                    rust = { "rustfmt" },
                    scala = { "scalafmt" },
                    svelte = { "prettier" },
                    terraform = { "terraform_fmt" },
                    typescript = { "prettier" },
                    yaml = { "prettier" },
                },
            })
        end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local lualine = require("lualine")

            lualine.setup({
                options = {
                    icons_enabled = false,
                    theme = "onedark",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                    disabled_filetypes = {
                        statusline = { "NvimTree" },
                        tabline = { "NvimTree", "terminal" },
                    },
                    always_divide_middle = true,
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                tabline = {
                    lualine_a = { {
                        "buffers",
                        show_filename_only = true,
                        hide_filename_extension = false,
                        show_modified_status = true,
                        mode = 2,
                        max_length = vim.o.columns,
                        filetype_names = {
                            NvimTree = "",
                            terminal = "",
                        },
                        buffers_color = {
                            active = "lualine_b_normal",
                            inactive = "lualine_b_inactive",
                        },
                        symbols = {
                            modified = " +",
                            alternate_file = "",
                            directory = "",
                        },
                        filter = function(buffer)
                            local buftype = vim.bo[buffer].buftype
                            local filetype = vim.bo[buffer].filetype
                            return buftype ~= "terminal" and filetype ~= "NvimTree"
                        end,
                    } },
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = { "tabs" },
                },
                extensions = { "nvim-tree" },
            })
        end,
    },

    -- Colors
    {
        "joshdick/onedark.vim",
        priority = 1000,
        config = function()
            vim.cmd("colorscheme onedark")
        end,
    },

    -- Hurl
    {
        "golmman/hurl_vim",
        ft = "hurl",
    },
}, {
    change_detection = {
        notify = false,
    },
    install = {
        colorscheme = { "onedark" },
    },
})
