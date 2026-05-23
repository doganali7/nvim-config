return {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Find files" })
        vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Git files" })
        vim.keymap.set("n", "<leader>ps", builtin.live_grep, { desc = "Live grep" })
        vim.keymap.set("n", "<leader>vh", builtin.help_tags, { desc = "Help tags" })
    end,
}
