local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
		}, true, {})
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
		{ import = "ali.plugins" }, -- auto-loads every lua/ali/plugins/*.lua
	},
	-- Use the real colorscheme in the install window on a fresh bootstrap,
	-- instead of the default one, while plugins are still being cloned
	install = { colorscheme = { "vscode" } },
	-- This config changes rarely; skip the spec-file watchers entirely
	change_detection = { enabled = false, notify = false },
	-- No plugin needs luarocks — disabling removes the permanent
	-- luarocks/hererocks ERROR from :checkhealth lazy
	rocks = { enabled = false },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"zipPlugin",
				"tohtml",
				"tutor",
			},
		},
	},
})
