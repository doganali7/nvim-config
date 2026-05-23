return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers",                  -- show buffers, not tabs
                diagnostics = "nvim_lsp",          -- show LSP diagnostics on tabs
                diagnostics_indicator = function(count, level)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        text_align = "center",
                        separator = true,
                    },
                },
                show_buffer_close_icons = true,
                show_close_icon = false,
                separator_style = "thin",
            },
        })

        -- Navigation
        -- Commented out: <S-l> / <S-h> conflict with vim defaults (L = bottom of screen, H = top of screen)
        -- vim.keymap.set("n", "<S-l>",      "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
        -- vim.keymap.set("n", "<S-h>",      "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
        vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
        vim.keymap.set("n", "<leader>bN", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })

        -- Move buffer position
        vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineMoveNext<CR>",  { desc = "Move buffer right" })
        vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineMovePrev<CR>",  { desc = "Move buffer left" })

        -- Pin / unpin buffer (keeps it visible across cycles)
        vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Pin buffer" })

        -- Close buffers
        vim.keymap.set("n", "<leader>bc", "<cmd>bdelete<CR>",                          { desc = "Close current buffer" })
        vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>",            { desc = "Close other buffers" })

        -- Jump to buffer by ordinal position (Cmd+1..9 style)
        for i = 1, 9 do
            vim.keymap.set("n", "<leader>" .. i,
                "<cmd>BufferLineGoToBuffer " .. i .. "<CR>",
                { desc = "Go to buffer " .. i })
        end
    end,
}
