-- Enhanced LSP configuration with nvim-cmp integration

-- Enable snippet completion in capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Global LSP setup
vim.lsp.set_log_level("warn")

-- Diagnostic signs
local signs = {
    Error = "✖",
    Warn = "⚠",
    Hint = "💡",
    Info = "ℹ",
}
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Configure LSP servers using vim.lsp.config (Neovim 0.11+)
-- TypeScript/JavaScript (ts_ls handles both)
vim.lsp.config["ts_ls"] = {
    capabilities = capabilities,
    init_options = {
        preferences = {
            importModuleSpecifierPreference = "non-relative",
            disableSuggestions = false,
            includeInlayParameterNameHints = "all",
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberNameHints = true,
        },
    },
}
vim.lsp.enable("ts_ls")

-- Svelte
vim.lsp.config["svelte"] = {
    capabilities = capabilities,
}
vim.lsp.enable("svelte")

-- Scala Metals
vim.lsp.config["metals"] = {
    capabilities = capabilities,
    cmd = { "metals" },
    filetypes = { "scala", "sbt" },
}
vim.lsp.enable("metals")

-- Rust
vim.lsp.config["rust_analyzer"] = {
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            diagnostics = {
                enable = true,
            },
            checkOnSave = {
                command = "clippy",
            },
            inlayHints = {
                enable = true,
                parameterHints = {
                    enable = true,
                },
                typeHints = {
                    enable = true,
                },
            },
        },
    },
}
vim.lsp.enable("rust_analyzer")

-- Python
vim.lsp.config["pyright"] = {
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "off",
                autoImportCompletions = true,
            },
        },
    },
}
vim.lsp.enable("pyright")

-- Go
vim.lsp.config["gopls"] = {
    capabilities = capabilities,
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
            usePlaceholders = true,
        },
    },
}
vim.lsp.enable("gopls")

-- General LSP keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
vim.keymap.set("n", "<leader>cf", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>ql", vim.diagnostic.setloclist, { desc = "Set diagnostic location list" })

-- Signature help
vim.keymap.set("i", "<A-s>", function()
    vim.lsp.buf.signature_help()
end, { desc = "Signature help" })
