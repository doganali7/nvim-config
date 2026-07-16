vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false

-- Case-insensitive search unless the pattern has a capital letter.
-- Deliberately off: search stays exact-case. (<leader>s substitute is
-- unaffected either way — it forces case-sensitivity with the I flag.)
-- vim.opt.ignorecase = true
-- vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

vim.opt.list = false
vim.opt.listchars = {
	space = "·",
	tab = "→ ",
	trail = "•",
	extends = "»",
	precedes = "«",
	nbsp = "␣",
}

vim.opt.completeopt = "menu,menuone,noselect"

-- One border style for every floating window: LSP hover, signature help,
-- diagnostic floats, and plugins that follow the option (blink.cmp does).
-- Replaces the per-float border in vim.diagnostic.config.
vim.opt.winborder = "rounded"
