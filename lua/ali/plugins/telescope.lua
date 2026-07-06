return {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Lazy-loaded on first keypress; require("telescope.builtin") inside the
    -- callbacks resolves after the plugin loads.
    keys = {
        {
            "<leader>pf",
            function() require("telescope.builtin").find_files() end,
            desc = "Find files",
        },
        {
            "<C-p>",
            function() require("telescope.builtin").git_files() end,
            desc = "Git files",
        },
        {
            "<leader>ps",
            function() require("telescope.builtin").live_grep() end,
            desc = "Live grep",
        },
        {
            "<leader>vh",
            function() require("telescope.builtin").help_tags() end,
            desc = "Help tags",
        },
    },
}
