return {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gwrite", "Gread" },
    keys = {
        { "<leader>gs", "<cmd>Git<CR>", desc = "Git status (fugitive)" },
    },
}
