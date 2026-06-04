return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")

        -- Shorten a path just enough to fit the harpoon window:
        --   * if the full path fits, show it untouched
        --   * otherwise keep the file name (and as many trailing folders as
        --     fit) intact, collapsing parent folders to a single letter
        -- Safe to do here: display() runs while the harpoon float is the
        -- current window, so nvim_win_get_width(0) is the float's real width,
        -- and harpoon matches list lines on their *displayed* form, so the
        -- real path is always preserved on save/select.
        local function fit_path(path)
            local width = vim.api.nvim_win_get_width(0) - 5 -- number gutter + padding
            if width < 10 then width = 10 end

            if vim.api.nvim_strwidth(path) <= width then
                return path
            end

            local parts = vim.split(path, "/", { plain = true })
            local n = #parts
            -- `full` = how many trailing parts (filename first) stay intact
            for full = n - 1, 1, -1 do
                local out = {}
                for i = 1, n do
                    if i > n - full then
                        out[i] = parts[i]
                    else
                        out[i] = parts[i]:sub(1, 1)
                    end
                end
                local s = table.concat(out, "/")
                if vim.api.nvim_strwidth(s) <= width or full == 1 then
                    return s
                end
            end
            return path
        end

        -- REQUIRED: must call setup() before anything else
        harpoon:setup({
            default = {
                display = function(list_item)
                    return fit_path(list_item.value)
                end,
            },
        })

        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end,
            { desc = "Harpoon add file" })
        vim.keymap.set("n", "<C-e>", function()
            harpoon.ui:toggle_quick_menu(harpoon:list(), {
                title = " Harpoon ",
                border = "rounded",
                ui_width_ratio = 0.95, -- 95% of editor width
                -- ui_max_width = 120,    -- but never wider than 120 columns
            })
        end, { desc = "Harpoon menu" })

        vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end,
            { desc = "Harpoon file 1" })
        vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end,
            { desc = "Harpoon file 2" })
        vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end,
            { desc = "Harpoon file 3" })
        vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end,
            { desc = "Harpoon file 4" })

        -- Cycle through the harpoon list
        vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end,
            { desc = "Harpoon prev" })
        vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end,
            { desc = "Harpoon next" })
    end,
}
