-- "\" on Windows, "/" elsewhere; same derivation plenary uses for path.sep.
local path_sep = package.config:sub(1, 1)
local is_windows = path_sep == "\\"

-- Usable width of the results window. Reimplements telescope's own
-- calc_result_length() (a local in lua/telescope/utils.lua). The nil-status
-- guard is ours: path_display can be called when the prompt buffer isn't
-- current, where upstream would error on status.layout.
local function results_width()
	local status = require("telescope.state").get_status(vim.api.nvim_get_current_buf())
	if not status or not status.layout or not status.layout.results then
		return vim.o.columns
	end
	return vim.api.nvim_win_get_width(status.layout.results.winid) - #status.picker.selection_caret - 2
end

-- Harpoon-style path display: keep the file name and as many parent folders as
-- fit, dropping whole leading directories (never abbreviating them).
--
-- `share` = fraction of the results window the path may occupy, leaving the
-- rest for whatever the entry maker appends (":lnum:col: <matched text>").
-- nil = the path owns the whole line. A fraction rather than a column count,
-- so a narrow results pane can't drive the budget to the floor.
--
-- `right_align` = pad to exactly `share` of the line, so file names form a
-- right-aligned column and the appended coordinates all start at the same
-- column. Only meaningful together with `share`.
local function fit_path(share, right_align)
	return function(opts, path)
		-- git ls-files emits "/" even on Windows while fd/rg emit "\", and
		-- make_entry passes entry.value through untouched. Unnormalized, the
		-- vim.split() below sees one element and drops no directories. Must
		-- run before make_relative — plenary's prefix compare doesn't
		-- normalize either. Windows-only: "\" is legal in POSIX file names.
		if is_windows then
			path = path:gsub("/", "\\")
		end

		-- transform_path() returns early for a function path_display, so its
		-- absolute -> cwd-relative step never runs. Do it ourselves.
		local cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.uv.cwd()
		path = require("plenary.path"):new(path):make_relative(cwd)

		-- gen_from_buffer sets __prefix for the bufnr/mode/icon columns.
		local avail = results_width() - (opts.__prefix or 0)
		local width = share and math.floor(avail * share) or avail
		width = math.max(12, math.min(avail, width))

		local strings = require("plenary.strings")
		local out

		if vim.api.nvim_strwidth(path) <= width then
			out = path
		else
			local parts = vim.split(path, path_sep, { plain = true })
			for first = 2, #parts do
				local s = "…" .. path_sep .. table.concat(parts, path_sep, first)
				if vim.api.nvim_strwidth(s) <= width then
					out = s
					break
				end
			end
			-- not even the bare file name fits: cut it from the left too
			out = out or strings.truncate(parts[#parts], width, nil, -1)
		end

		-- Pad every branch, not just the ones that fit: truncate() can return
		-- narrower than width (it stops once the next char plus the ellipsis
		-- would overflow). Safe because the sorter's match highlighter gets
		-- the display string, so its offsets already account for the padding.
		return right_align and strings.align_str(out, width, true) or out
	end
end

-- Pickers whose entry maker appends ":lnum:col: <text>" after the path.
local grep_like = { path_display = fit_path(0.6, true) }
-- Pickers that append a shorter location/symbol column.
local location_like = { path_display = fit_path(0.5, true) }

return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = "Telescope", -- so :Telescope <picker> works before any key was pressed
	opts = {
		defaults = {
			-- No share and no alignment: the path owns the line, and right-
			-- aligning here would leave the devicon stranded at column 0.
			path_display = fit_path(),

			-- Full-screen: {padding = 0} resolves to max_columns/max_lines.
			-- width/height stay top-level so they apply to every strategy
			-- (smarter_depth_2_extend pushes them down into each one), while
			-- preview_width must stay nested — validate_layout_config()
			-- hard-errors on keys the active strategy doesn't declare, and
			-- only horizontal, cursor and bottom_pane declare it.
			layout_config = {
				-- width = 0.95,
				width = { padding = 0 },
				height = { padding = 0 },
				horizontal = { preview_width = 0.35 },
			},

			-- Upstream's list plus `--trim`, which drops the matched line's
			-- leading indentation: deeply nested Angular templates otherwise
			-- waste ~20 columns on whitespace. The other flags can't be
			-- dropped — telescope parses rg's output positionally.
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--trim",
			},
		},
		pickers = {
			live_grep = grep_like,
			grep_string = grep_like,
			quickfix = location_like,
			loclist = location_like,
			lsp_references = location_like,
			lsp_document_symbols = location_like,
			diagnostics = location_like,
		},
	},
	-- Lazy-loaded on first keypress; require("telescope.builtin") inside the
	-- callbacks resolves after the plugin loads.
	keys = {
		{
			"<leader>pf",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "Find files",
		},
		{
			"<C-p>",
			function()
				require("telescope.builtin").git_files()
			end,
			desc = "Git files",
		},
		{
			"<leader>ps",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Live grep",
		},
		{
			"<leader>vh",
			function()
				require("telescope.builtin").help_tags()
			end,
			desc = "Help tags",
		},
	},
}
