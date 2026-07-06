-- Fast, accurate lua_ls setup for editing this config: instead of making
-- lua_ls index the entire runtime + every plugin (the old workspace.library
-- approach), lazydev lazily adds only the modules actually require()d.
return {
    "folke/lazydev.nvim",
    ft = "lua", -- only when editing lua
    opts = {
        library = {
            -- load luvit types when vim.uv is referenced
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
    },
}
