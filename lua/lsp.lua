-- LSP configuration

-- LSP capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Global LSP setup
vim.lsp.log.set_level(vim.lsp.log.levels.WARN)

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
