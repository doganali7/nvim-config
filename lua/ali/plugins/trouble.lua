return {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        focus = true,   -- jump cursor into trouble window when opened
    },
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",                            desc = "Diagnostics (workspace)" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",               desc = "Diagnostics (buffer)" },
        { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>",                    desc = "Symbols (LSP)" },
        { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",     desc = "LSP defs/refs/impls" },
        { "<leader>xL", "<cmd>Trouble loclist toggle<CR>",                                desc = "Location list" },
        { "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                                 desc = "Quickfix list" },
    },
}
