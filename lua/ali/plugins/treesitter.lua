return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		-- The main branch does not support lazy-loading (stated explicitly
		-- in the README) — the entry
		-- point is ~30 lines of deferred requires.
		lazy = false,
		-- :TSUpdate exists on main (defined in plugin/nvim-treesitter.lua)
		-- and internally runs update(args.fargs, { summary = true }).
		build = ":TSUpdate",
		config = function()
			-- Async; no-op for parsers that are already installed.
			require("nvim-treesitter").install({
				"javascript",
				"typescript",
				"c",
				"lua",
				"rust",
				"go",
				"gomod", -- go.mod
				"gowork", -- go.work
				"gotmpl", -- html/template + text/template ({{ ... }})
				"python",
				"vim",
				"vimdoc",
				"bash",
				"html",
				"css",
				"scss",
				"json",
				"yaml",
				"markdown",
				"markdown_inline", -- inline styling is injected
				"angular",
			})

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					-- Skip silently when no parser exists for the filetype,
					-- but let real parser/query errors surface.
					local lang = vim.treesitter.language.get_lang(ev.match)
					if lang and vim.treesitter.language.add(lang) then
						vim.treesitter.start(ev.buf, lang)
					end
				end,
			})
		end,
	},
}
