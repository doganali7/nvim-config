return {
	-- {
	-- 	"rose-pine/neovim",
	-- 	name = "rose-pine",
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("rose-pine").setup({
	-- 			variant = "main", -- auto, main, moon, or dawn
	-- 			dark_variant = "main",
	-- 			styles = {
	-- 				italic = false,
	-- 			},
	-- 			palette = {
	-- 				main = {
	-- 					base = "#121212",
	-- 					surface = "#1a1a1a",
	-- 					overlay = "#222222",
	-- 				},
	-- 			},
	-- 		})
	-- 		vim.cmd.colorscheme("rose-pine")
	-- 	end,
	-- },
	{
		"Mofiqul/vscode.nvim",
		-- A colorscheme has to be a start plugin, and `priority` only has an
		-- effect on start plugins — spell both out so adding an event/keys
		-- trigger later can't silently make the priority a no-op.
		lazy = false,
		priority = 1000,
		config = function()
			require("vscode").setup({
				style = "dark",
				transparent = false,
				italic_comments = false,
				underline_links = true,
				color_overrides = {
					vscBack = "#121212", -- base: main editor background
					vscTabCurrent = "#121212", -- active tab matches the editor
					vscLeftDark = "#1a1a1a", -- surface: sidebar/statusline
					vscTabOutside = "#1a1a1a", -- tab bar area
					vscPopupBack = "#222222", -- overlay: popups and floats
					vscCursorDarkDark = "#222222", -- cursorline
				},
			})
			vim.cmd.colorscheme("vscode")
		end,
	},
}
