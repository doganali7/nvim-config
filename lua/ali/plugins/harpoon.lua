return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	-- Trigger-only lazy-load: entries with no rhs make lazy.nvim load the
	-- plugin on first press and re-feed the key; the real mappings are the
	-- ones defined in config() below.
	keys = {
		{ "<leader>a", desc = "Harpoon add file" },
		{ "<C-e>", desc = "Harpoon menu" },
		{ "<C-h>", desc = "Harpoon file 1" },
		{ "<C-t>", desc = "Harpoon file 2" },
		{ "<C-n>", desc = "Harpoon file 3" },
		{ "<C-s>", desc = "Harpoon file 4" },
		{ "<C-S-P>", desc = "Harpoon prev" },
		{ "<C-S-N>", desc = "Harpoon next" },
		{ "<F13>", desc = "Harpoon next" },
		{ "<F14>", desc = "Harpoon prev" },
	},
	config = function()
		local harpoon = require("harpoon")

		-- Show the full path, right-aligned to the harpoon window: if it does
		-- not fit, drop leading directories (never abbreviate them) so the
		-- file name and as many of its parent folders as fit stay readable.
		-- Safe to do here: display() runs while the harpoon float is the
		-- current window, so nvim_win_get_width(0) is the float's real width,
		-- and harpoon matches list lines on their *displayed* form, so the
		-- real path is always preserved on save/select.
		local path_sep = package.config:sub(1, 1)

		local function fit_path(path)
			local width = vim.api.nvim_win_get_width(0) - 5 -- number gutter + padding
			if width < 10 then
				width = 10
			end

			if vim.api.nvim_strwidth(path) <= width then
				return path
			end

			local parts = vim.split(path, path_sep, { plain = true })
			-- keep as many trailing parts (file name first) as fit behind "…/"
			for first = 2, #parts do
				local s = "…" .. path_sep .. table.concat(parts, path_sep, first)
				if vim.api.nvim_strwidth(s) <= width then
					return s
				end
			end

			-- not even the bare file name fits: cut it from the left too
			local name = parts[#parts]
			while vim.fn.strchars(name) > 1 and vim.api.nvim_strwidth("…" .. name) > width do
				name = vim.fn.strcharpart(name, 1)
			end
			return "…" .. name
		end

		-- REQUIRED: must call setup() before anything else
		harpoon:setup({
			default = {
				display = function(list_item)
					return fit_path(list_item.value)
				end,
			},
		})

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Harpoon add file" })
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list(), {
				title = " Harpoon ",
				border = "rounded",
				ui_width_ratio = 0.95, -- 95% of editor width
				-- ui_max_width = 120,    -- not wider than 120 columns
			})
		end, { desc = "Harpoon menu" })

		vim.keymap.set("n", "<C-h>", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon file 1" })
		vim.keymap.set("n", "<C-t>", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon file 2" })
		vim.keymap.set("n", "<C-n>", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon file 3" })
		vim.keymap.set("n", "<C-s>", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon file 4" })

		-- Cycle through the harpoon list.
		-- WezTerm translates Ctrl+Shift+N -> <F13> and Ctrl+Shift+P -> <F14>
		-- (see ~/.wezterm.lua) because terminals can't unambiguously encode
		-- Ctrl+Shift+<letter>. The <C-S-*> maps are kept as well so this still
		-- works under terminals that do support the kitty keyboard protocol.
		local function harpoon_prev()
			harpoon:list():prev()
		end
		local function harpoon_next()
			harpoon:list():next()
		end

		vim.keymap.set("n", "<C-S-P>", harpoon_prev, { desc = "Harpoon prev" })
		vim.keymap.set("n", "<C-S-N>", harpoon_next, { desc = "Harpoon next" })
		vim.keymap.set("n", "<F14>", harpoon_prev, { desc = "Harpoon prev" })
		vim.keymap.set("n", "<F13>", harpoon_next, { desc = "Harpoon next" })
	end,
}
