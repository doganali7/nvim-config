return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                variant = "main", -- auto, main, moon, or dawn
                dark_variant = "main",
                styles = {
                    italic = false,
                },
                palette = {
                    main = {
                        base = "#121212",
                        surface = "#1a1a1a",
                        overlay = "#222222",
                    },
                },
            })
            vim.cmd.colorscheme("rose-pine")
        end,
    },
}
