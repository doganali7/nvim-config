return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local gitsigns = require("gitsigns")

        gitsigns.setup({
            on_attach = function(bufnr)
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end

                -- Navigation between hunks (changes)
                map("n", "]c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        gitsigns.nav_hunk("next")
                    end
                end, "Next git hunk")

                map("n", "[c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        gitsigns.nav_hunk("prev")
                    end
                end, "Prev git hunk")

                -- Actions
                map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk (before/after)")
                map("n", "<leader>hr", gitsigns.reset_hunk, "Reset (revert) hunk")
                map("n", "<leader>hs", gitsigns.stage_hunk, "Stage / unstage hunk (toggle)")
                map("n", "<leader>hR", gitsigns.reset_buffer, "Reset whole buffer")
                map("n", "<leader>hb", function()
                    gitsigns.blame_line({ full = true })
                end, "Blame current line")
                map("n", "<leader>hd", gitsigns.diffthis, "Diff this file")

                -- Visual mode: reset/stage just the selected lines
                map("v", "<leader>hr", function()
                    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Reset selected lines")
                map("v", "<leader>hs", function()
                    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Stage selected lines")

                -- Toggle inline blame as virtual text
                map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle line blame")
            end,
        })
    end,
}
