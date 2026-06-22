vim.g.mapleader = " "

-- File explorer (netrw)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move selected lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor in place when joining lines
vim.keymap.set("n", "J", "mzJ`z")

-- Half-page jumps, stay centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep search term centered
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste without losing register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Copy to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete to void register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Disable Q (ex mode — never useful)
vim.keymap.set("n", "Q", "<nop>")

-- New tmux window (requires tmux-sessionizer script)
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Format current buffer (uses LSP or conform)
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Search and replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

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
