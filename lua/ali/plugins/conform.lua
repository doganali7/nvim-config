-- Formatter entry point for the lazy `keys` spec. The callback fires even in
-- synchronous mode, so we can report the outcome.
local function format_buffer()
	require("conform").format({
		lsp_format = "fallback",
		timeout_ms = 2000,
	}, function(err, did_edit)
		if err then
			return
		elseif did_edit then
			vim.notify("Formatted", vim.log.levels.INFO)
		else
			vim.notify("No changes (already formatted)", vim.log.levels.INFO)
		end
	end)
end

local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
	"stevearc/conform.nvim",
	-- No BufWritePre event: format_on_save is disabled, so there's nothing
	-- for the plugin to do on save. keys/cmd below lazy-load it on demand.
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			format_buffer,
			mode = { "n", "v" },
			desc = "Format buffer (conform)",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "gofmt" }, -- ships with the Go toolchain (on PATH)
			python = { "black" },
			javascript = prettier,
			typescript = prettier,
			html = prettier,
			htmlangular = prettier,
			css = prettier,
			scss = prettier,
			json = prettier,
			yaml = prettier,
			markdown = prettier,
		},
		-- To enable format-on-save, set e.g.
		--   format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
		-- AND restore `event = { "BufWritePre" }` in the spec above —
		-- the autocmd is only created inside setup(), which never runs
		-- on save under the current cmd/keys-only lazy loading.
	},
}
