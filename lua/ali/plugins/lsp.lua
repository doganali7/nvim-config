return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "ts_ls",       -- Angular .ts
                    "angularls",   -- Angular templates
                    "html",        -- template HTML
                    "cssls",       -- component styles
                    "clangd",      -- C
                },
                automatic_enable = true,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        -- Load as the first real file is being read (BufReadPre fires before
        -- FileType), so vim.lsp.enable's FileType autocmd is registered in
        -- time to attach to that very first buffer.
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- How diagnostics (errors/warnings) are displayed.
            -- Without this, modern Neovim shows no inline text by default.
            vim.diagnostic.config({
                virtual_text = true,    -- show the message inline after the line
                signs = true,           -- gutter signs
                underline = true,       -- underline the offending code
                update_in_insert = false, -- don't redraw while typing (refresh on leaving insert)
                severity_sort = true,   -- show the most severe diagnostic first
                float = {
                    border = "rounded",
                    source = true,      -- show which server produced the message
                },
            })

            -- Keymaps: only active when an LSP server attaches
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local opts = { buffer = ev.buf }
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                    vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
                    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
                end,
            })

            -- Native Neovim 0.11 API (no deprecation warning)
            vim.lsp.config("lua_ls", {
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                    },
                },
            })

            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            vim.lsp.enable({
                "lua_ls",
                "ts_ls",       -- Angular .ts
                "angularls",   -- Angular templates
                "html",        -- template HTML
                "cssls",       -- component styles
                "clangd",      -- C
            })
        end,
    },
}
