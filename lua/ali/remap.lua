vim.g.mapleader = " "
-- Set explicitly rather than relying on the default: lazy.nvim resolves
-- <localleader> in plugin `keys` specs at setup() time, so it has to be
-- defined before lazy_init runs (see lua/ali/init.lua for the order).
vim.g.maplocalleader = "\\"

-- File explorer (netrw)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "File explorer (netrw)" })

-- Reload current file from disk (aborts if the buffer has unsaved changes;
-- use :e! to discard them and force-reload)
vim.keymap.set("n", "<leader>e", "<cmd>edit<CR>", { desc = "Reload file from disk" })

-- Move selected lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor in place when joining lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line below (cursor stays)" })

-- Half-page jumps, stay centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Scroll screen down one line (pairs with <C-y> scroll up).
-- <C-e> is the builtin for this but it's taken by the harpoon menu.
vim.keymap.set("n", "<C-g>", "<C-e>", { desc = "Scroll screen down" })

-- Keep search term centered
vim.keymap.set("n", "n", "nzzzv", { desc = "Next match (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev match (centered)" })

-- Paste without losing register
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over selection (keep register)" })

-- Copy to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Delete to void register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void register" })

-- Disable Q (ex mode — never useful)
vim.keymap.set("n", "Q", "<nop>", { desc = "Disabled (ex mode)" })

-- New tmux window (requires tmux-sessionizer script)
-- Unix-only: tmux doesn't exist on Windows — re-enable if this config is
-- ever used on Linux/macOS.
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Format current buffer: handled by conform.nvim (see plugins/conform.lua),
-- which lazy-loads on this keypress and falls back to LSP when no formatter.

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Prev quickfix item" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next loclist item" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Prev loclist item" })

-- Search and replace word under cursor
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Substitute word under cursor" }
)

-- Make file executable
-- Unix-only: chmod doesn't exist on Windows (:! runs via cmd.exe) —
-- re-enable if this config is ever used on Linux/macOS.
-- vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Copy file paths to system clipboard
vim.keymap.set("n", "<leader>cf", function()
	vim.fn.setreg("+", vim.fn.expand("%"))
	vim.notify("Copied: " .. vim.fn.expand("%"))
end, { desc = "Copy relative path" })

vim.keymap.set("n", "<leader>cF", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
	vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { desc = "Copy absolute path" })

-- Toggle whitespace visibility
vim.keymap.set("n", "<leader>tw", function()
	vim.opt.list = not vim.opt.list:get()
end, { desc = "Toggle whitespace" })

-- Toggle line wrap. Lives in the <leader>t toggle namespace (next to
-- <leader>tw whitespace and <leader>tb blame) — LazyVim's <leader>uw
-- would shadow undotree's <leader>u and delay it by timeoutlen.
vim.keymap.set("n", "<leader>tW", function()
	vim.opt.wrap = not vim.opt.wrap:get()
end, { desc = "Toggle wrap" })
