return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- Trigger-only lazy-load: lhs strings with no rhs make lazy.nvim load the
    -- plugin on first press and re-feed the key; the real mappings are the
    -- ones defined in config() below.
    keys = {
        "<leader>a",
        "<C-e>",
        "<C-h>",
        "<C-t>",
        "<C-n>",
        "<C-s>",
        "<C-S-P>",
        "<C-S-N>",
        "<F13>",
        "<F14>",
    },
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
        local path_sep = package.config:sub(1, 1)

        local function fit_path(path)
            local width = vim.api.nvim_win_get_width(0) - 5 -- number gutter + padding
            if width < 10 then width = 10 end

            if vim.api.nvim_strwidth(path) <= width then
                return path
            end

            local parts = vim.split(path, path_sep, { plain = true })
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
                local s = table.concat(out, path_sep)
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

        -- Cycle through the harpoon list.
        -- WezTerm translates Ctrl+Shift+N -> <F13> and Ctrl+Shift+P -> <F14>
        -- (see ~/.wezterm.lua) because terminals can't unambiguously encode
        -- Ctrl+Shift+<letter>. The <C-S-*> maps are kept as well so this still
        -- works under terminals that do support the kitty keyboard protocol.
        local function harpoon_prev() harpoon:list():prev() end
        local function harpoon_next() harpoon:list():next() end

        vim.keymap.set("n", "<C-S-P>", harpoon_prev, { desc = "Harpoon prev" })
        vim.keymap.set("n", "<C-S-N>", harpoon_next, { desc = "Harpoon next" })
        vim.keymap.set("n", "<F14>", harpoon_prev, { desc = "Harpoon prev" })
        vim.keymap.set("n", "<F13>", harpoon_next, { desc = "Harpoon next" })
    end,
}
