return {
    {
        "williamboman/mason.nvim",
        -- Lazy: loads via the dependency chain when nvim-lspconfig loads at
        -- BufReadPre, or on :Mason — no work at startup before a file opens.
        cmd = "Mason",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = true, -- pulled in as a dependency of nvim-lspconfig
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
                -- We call vim.lsp.enable() ourselves at the bottom of the
                -- nvim-lspconfig config, *after* registering per-server tweaks
                -- (ts_ls cmd, angularls root_dir gate). Letting mason-lspconfig
                -- auto-enable too would be a second, earlier source of truth.
                automatic_enable = false,
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
                    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
                    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
                    vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                    vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
                end,
            })

            -- lua_ls needs no manual settings: lazydev.nvim (plugins/lazydev.lua)
            -- feeds it the vim runtime types and the plugin modules actually
            -- require()d, instead of indexing every runtime path up front.
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
