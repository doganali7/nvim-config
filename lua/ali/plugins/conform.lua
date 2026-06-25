-- Shared formatter entry point so the lazy `keys` spec and the post-config
-- keymap stay in sync. The callback fires even in synchronous mode, so we can
-- report the outcome.
local function format_buffer()
    require("conform").format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 2000,
    }, function(err, did_edit)
        if err then
            vim.notify("Format failed: " .. err, vim.log.levels.ERROR)
        elseif did_edit then
            vim.notify("Formatted", vim.log.levels.INFO)
        else
            vim.notify("No changes (already formatted)", vim.log.levels.INFO)
        end
    end)
end

return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>f",
            format_buffer,
            mode = { "n", "v" },
            desc = "Format buffer (conform)",
        },
    },
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "black" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                html = { "prettierd", "prettier", stop_after_first = true },
                htmlangular = { "prettierd", "prettier", stop_after_first = true },
                css = { "prettierd", "prettier", stop_after_first = true },
                scss = { "prettierd", "prettier", stop_after_first = true },
                json = { "prettierd", "prettier", stop_after_first = true },
                yaml = { "prettierd", "prettier", stop_after_first = true },
                markdown = { "prettierd", "prettier", stop_after_first = true },
                go = { "gofumpt" },
                c = { "clang-format" },
            },
            -- Set to true for format-on-save
            format_on_save = nil,
        })

        -- Keymap is defined in the lazy `keys` spec above so it works from the
        -- first keypress (before any save triggers BufWritePre). Kept here too
        -- as a harmless re-assertion once the plugin's config runs.
        vim.keymap.set({ "n", "v" }, "<leader>f", format_buffer, { desc = "Format buffer (conform)" })
    end,
}
