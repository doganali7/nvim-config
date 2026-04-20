return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")

            ts.install({
                "javascript", "typescript", "c", "lua",
                "rust", "go", "python", "vim", "vimdoc",
                "bash", "html", "css", "json", "yaml", "markdown",
                "angular",
            })

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(ev)
                    pcall(vim.treesitter.start, ev.buf)
                end,
            })
        end,
    },
}
