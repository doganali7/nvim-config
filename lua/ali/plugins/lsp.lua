-- One list, two consumers: mason-lspconfig installs these and
-- nvim-lspconfig's config() enables them. A single table keeps the two
-- from drifting apart (with automatic_enable = false they'd otherwise
-- have to be synced by hand).
local servers = {
	"lua_ls",
	"ts_ls", -- Angular .ts
	"angularls", -- Angular templates
	"html", -- template HTML (+ htmlangular, see below)
	"cssls", -- component styles
	"clangd", -- C
	"gopls", -- Go: go-to-definition, hover, references, diagnostics
}

-- Non-LSP tools. mason-lspconfig's ensure_installed only accepts lspconfig
-- server names, so formatters need their own installer to be reproducible on
-- a new machine. Keep in sync with formatters_by_ft in plugins/conform.lua.
-- (gofmt is absent on purpose: it ships with the Go toolchain, not Mason.)
local tools = {
	"stylua", -- lua
	"black", -- python
	"prettierd", -- js, ts, html, css, scss, json, yaml, markdown
}

return {
	{
		"mason-org/mason.nvim",
		-- Lazy: loads via the dependency chain when nvim-lspconfig loads at
		-- BufReadPre, or on any :Mason* command — no work at startup before a
		-- file opens. All commands are listed so e.g. :MasonUpdate works even
		-- before the first file is opened.
		cmd = {
			"Mason",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
			"MasonUpdate",
			"MasonLog",
		},
		config = function()
			require("mason").setup()
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		lazy = true, -- pulled in as a dependency of nvim-lspconfig
		dependencies = { "mason-org/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = servers,
				automatic_enable = false,
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = true, -- pulled in as a dependency of nvim-lspconfig
		dependencies = { "mason-org/mason.nvim" },
		config = function()
			local mti = require("mason-tool-installer")
			mti.setup({
				ensure_installed = tools,
				-- The plugin's own auto-run hangs off a VimEnter autocmd in its
				-- plugin/ file. Lazy sources that only when the plugin loads —
				-- here at BufReadPre, long after VimEnter fired — so the autocmd
				-- would never trigger and nothing would ever install. Drive it
				-- from config() instead.
				run_on_start = false,
			})
			-- Cheap in the steady state: with auto_update off and no pinned
			-- versions, an installed tool is just an is_installed() check, no
			-- network. Hence no debounce_hours — a missing tool gets fixed on
			-- the next session rather than up to N hours later.
			mti.check_install(false)
		end,
	},
	{
		"neovim/nvim-lspconfig",
		-- Load as the first real file is being read (BufReadPre fires before
		-- FileType), so vim.lsp.enable's FileType autocmd is registered in
		-- time to attach to that very first buffer.
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- How diagnostics (errors/warnings) are displayed. Only settings
			-- that differ from the defaults; float borders come from the
			-- global 'winborder' (set.lua).
			vim.diagnostic.config({
				virtual_text = true, -- inline message text (default: off)
				severity_sort = true, -- most severe diagnostic first (default: off)
				float = {
					source = true, -- show which server produced the message
				},
				-- Open the float after every diagnostic jump. This makes the
				-- builtin ]d/[d (count-aware, so 3]d works) behave like the
				-- old custom maps did — via on_jump, the replacement for the
				-- deprecated opts.float.
				jump = {
					on_jump = function(_, bufnr)
						vim.diagnostic.open_float({
							bufnr = bufnr,
							scope = "cursor",
							focus = false,
						})
					end,
				},
			})

			-- Keymaps: only active when an LSP server attaches
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
					end
					map("n", "gd", vim.lsp.buf.definition, "LSP definition")
					map("n", "<leader>vws", vim.lsp.buf.workspace_symbol, "LSP workspace symbol")
					map("n", "<leader>vd", vim.diagnostic.open_float, "Diagnostic float")
					map("n", "<leader>vca", vim.lsp.buf.code_action, "LSP code action")
					map("n", "<leader>vrr", vim.lsp.buf.references, "LSP references")
					map("n", "<leader>vrn", vim.lsp.buf.rename, "LSP rename")
				end,
			})

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-- Angular component templates get the htmlangular filetype (see
			-- plugin/angular.lua), but upstream html-ls declares only
			-- filetypes = { "html" }. Without this, templates in legacy
			-- projects — where the TS>=5 gate below skips angularls — would
			-- have no language server at all. html-ls coexists fine with
			-- angularls in modern projects.
			vim.lsp.config("html", {
				filetypes = { "html", "htmlangular" },
			})

			-- Gate angularls per-project: the modern @angular/language-server
			-- requires TypeScript >= 5.0. Old Angular apps (e.g. TS 3.7) make it
			-- crash on attach ("Failed to resolve 'typescript/lib/tsserverlibrary'
			-- with minimum version '5.0'"). We only start it when the project's
			-- TypeScript is new enough; newer projects keep template support, and
			-- .ts navigation (gd) always comes from ts_ls regardless.
			vim.lsp.config("angularls", {
				root_dir = function(bufnr, on_dir)
					local fname = vim.api.nvim_buf_get_name(bufnr)
					-- Workspace-root markers only (same as upstream). Do NOT
					-- add project.json: in Nx workspaces it exists per-app,
					-- so the nearest match would be the app dir — where the
					-- hoisted node_modules/typescript check below always
					-- fails and angularls silently never starts.
					local root = vim.fs.root(fname, { "angular.json", "nx.json" })
					if not root then
						return -- not an Angular workspace; don't start
					end

					local pkg = root .. "/node_modules/typescript/package.json"
					if vim.fn.filereadable(pkg) == 0 then
						-- No project-local TypeScript to validate against
						-- (deps not installed?). Say so instead of silently
						-- not starting.
						vim.notify_once(
							("angularls: skipped (no node_modules/typescript in %s)"):format(root),
							vim.log.levels.WARN
						)
						return
					end

					local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
					local version = ok and type(decoded) == "table" and decoded.version or nil
					local major = version and tonumber(version:match("^(%d+)")) or nil

					if not major or major < 5 then
						-- notify_once: this runs per matching buffer, and a
						-- session in a legacy project would otherwise warn on
						-- every file opened
						vim.notify_once(
							("angularls: skipped (project TypeScript %s < 5.0)"):format(version or "unknown"),
							vim.log.levels.WARN
						)
						return
					end

					on_dir(root)
				end,
			})

			-- A legacy project may pin Node to an old version for its build
			-- (e.g. WestCore needs v12 for its Angular 9 toolchain). But the
			-- bundled typescript-language-server can't even be parsed by old Node
			-- (it crashes on '??' in cli.mjs), so ts_ls dies and .ts go-to-
			-- definition stops working. Launch ts_ls with the newest installed
			-- Node (auto-detected, >= 14), leaving whatever is on PATH for builds.
			local function newest_node()
				-- nvm-windows sets NVM_HOME; the expand() is only a fallback
				-- for the default install location
				local nvm_dir = vim.env.NVM_HOME or vim.fn.expand("~/AppData/Roaming/nvm")
				if vim.fn.isdirectory(nvm_dir) == 0 then
					return nil
				end
				local best, best_key
				for name in vim.fs.dir(nvm_dir) do
					local maj, min, pat = name:match("^v(%d+)%.(%d+)%.(%d+)$")
					if maj and tonumber(maj) >= 14 then
						local key = tonumber(maj) * 1000000 + tonumber(min) * 1000 + tonumber(pat)
						local exe = nvm_dir .. "/" .. name .. "/node.exe"
						if (not best_key or key > best_key) and vim.fn.executable(exe) == 1 then
							best, best_key = exe, key
						end
					end
				end
				return best
			end

			local node_modern = newest_node()
			local ts_ls_cli = vim.fn.stdpath("data")
				.. "/mason/packages/typescript-language-server/node_modules/typescript-language-server/lib/cli.mjs"
			if node_modern then
				if vim.fn.filereadable(ts_ls_cli) == 1 then
					vim.lsp.config("ts_ls", {
						cmd = { node_modern, ts_ls_cli, "--stdio" },
					})
				else
					-- The hardcoded path into the Mason package broke (layout
					-- change / not installed yet). Say so instead of silently
					-- falling back to PATH node, which may be too old to run
					-- the server at all.
					vim.notify_once(
						"ts_ls: Mason cli.mjs not found at " .. ts_ls_cli .. " — using default cmd (PATH node)",
						vim.log.levels.WARN
					)
				end
			end

			-- Mason's typescript-language-server now bundles typescript 7
			-- (native preview, no tsserver.js), so the server's built-in
			-- fallback is broken: any buffer outside a project with a local
			-- node_modules/typescript gets no ts_ls at all. Point the
			-- fallback at a pinned TypeScript 5.x kept outside the Mason
			-- package dir (which is wiped on every package update):
			--   npm install --prefix <stdpath(data)>/ts-fallback typescript@5
			-- Projects with their own typescript still win — resolution order
			-- is workspace node_modules first, then this fallbackPath.
			-- Must be joined with the native separator: tsserver validates the
			-- path by splitting on it, so a mixed-separator path on Windows is
			-- silently treated as invalid and ignored.
			local sep = package.config:sub(1, 1)
			local ts_fallback = table.concat({
				vim.fn.stdpath("data"),
				"ts-fallback",
				"node_modules",
				"typescript",
				"lib",
				"tsserver.js",
			}, sep)
			if vim.fn.filereadable(ts_fallback) == 1 then
				vim.lsp.config("ts_ls", {
					init_options = { tsserver = { fallbackPath = ts_fallback } },
				})
			end

			vim.lsp.enable(servers)
		end,
	},
}
