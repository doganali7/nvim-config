return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        -- Disable netrw (recommended by nvim-tree)
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        require("nvim-tree").setup({
            view = {
                side = "left",
                width = 35,
                signcolumn = "yes",
            },
            renderer = {
                group_empty = true,
                indent_markers = { enable = true },
                icons = {
                    show = {
                        file         = true,
                        folder       = true,
                        folder_arrow = true,
                        git          = true,
                    },
                },
            },
            filters = {
                dotfiles = false,   -- show hidden files like VSCode
            },
            git = {
                enable = true,
            },
            actions = {
                open_file = {
                    quit_on_open = false,   -- keep tree open after opening a file (VSCode-like)
                },
            },
            update_focused_file = {
                enable = true,        -- highlight currently open file in tree
                update_root = false,
            },
        })

        -- Toggle (VSCode's Cmd+B equivalent)
        vim.keymap.set("n", "<C-b>",     "<cmd>NvimTreeToggle<CR>",   { desc = "Toggle file tree" })
        vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>",   { desc = "Toggle file tree" })
        vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<CR>",    { desc = "Focus file tree" })
    end,
}
