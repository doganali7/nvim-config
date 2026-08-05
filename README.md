# nvim-config

Personal Neovim config. Neovim **0.11+** required (uses `vim.lsp.config` /
`vim.lsp.enable`); developed against 0.12.x on Windows.

Plugin management is [lazy.nvim](https://github.com/folke/lazy.nvim), which
bootstraps itself on first launch — plugin versions come from `lazy-lock.json`.
LSP servers and formatters are installed by Mason and declared in
`lua/ali/plugins/lsp.lua`, so a new machine needs almost nothing done by hand.

## Setting up on a new machine

### 1. Prerequisites

Mason downloads each package using the toolchain that package is published
for, so these must be on `PATH` before first launch:

| Needed | For |
|---|---|
| **node + npm** | typescript-language-server, angular-language-server, html-lsp, css-lsp, prettierd |
| **Python 3 + pip** | black |
| **Go toolchain** | gopls (also provides `gofmt`, which Mason does not install) |
| *nothing* | clangd, lua-language-server, stylua — prebuilt binaries |

Also useful: `git`, and a C compiler for treesitter parser builds.

Run `:checkhealth mason` after launching — it reports exactly which of these
are missing.

### 2. First launch

Start `nvim`, let lazy.nvim install the plugins, then **open any file**. That
fires `BufReadPre`, which loads the Mason chain and installs everything
declared in `lua/ali/plugins/lsp.lua`:

- `servers` — lua_ls, ts_ls, angularls, html, cssls, clangd, gopls
  (via `mason-lspconfig`'s `ensure_installed`)
- `tools` — stylua, black, prettierd
  (via `mason-tool-installer`, driven from `config()`)

Watch progress with `:Mason`. Nothing here needs `:MasonInstall` — see
[Managing servers and tools](#managing-servers-and-tools) for adding or
removing things later.

### 3. Required manual step: the ts_ls fallback TypeScript

This is the one thing no plugin sets up for you:

```powershell
# Windows (PowerShell)
npm install --prefix "$env:LOCALAPPDATA\nvim-data\ts-fallback" typescript@5
```

```sh
# Linux / macOS
npm install --prefix ~/.local/share/nvim/ts-fallback typescript@5
```

**Why it's needed.** Mason's `typescript-language-server` bundles TypeScript 7
(the native preview, which has no `tsserver.js`), so the server's own bundled
fallback is broken. Without a fallback, any `.ts` buffer *outside* a project
with its own `node_modules/typescript` gets no language server at all.
`lua/ali/plugins/lsp.lua` points `init_options.tsserver.fallbackPath` at the
pinned 5.x install above.

**Why it lives outside the Mason package directory.** Mason wipes a package's
directory on every update, so a copy kept inside it would disappear. Hence
`stdpath("data")/ts-fallback`, which Mason never touches.

Projects with their own TypeScript still win — resolution order is workspace
`node_modules` first, then this fallback.

**Failure mode if you skip it:** no error, no message. The config checks for
the file and simply doesn't apply the fallback when it's absent
(`lua/ali/plugins/lsp.lua`), so `ts_ls` just never attaches in standalone
`.ts` files. Confirm it works by running `:checkhealth vim.lsp` in a `.ts` file
outside any project, or check that this path exists:

```
<stdpath("data")>/ts-fallback/node_modules/typescript/lib/tsserver.js
```

### 4. Verify

| Command | Expect |
|---|---|
| `:checkhealth` | no missing prerequisites |
| `:Mason` | the 7 servers + 3 tools installed |
| `:checkhealth vim.lsp` (in a `.ts` file) | `ts_ls` attached (`:LspInfo` is an alias) |
| `:ConformInfo` | formatter for the current filetype found |
| `<leader>f` | "Formatted" / "No changes (already formatted)" |

## Managing servers and tools

Everything Mason installs is declared in two lists at the top of
`lua/ali/plugins/lsp.lua`. **Always edit the lists — don't use
`:MasonInstall`.** An ad-hoc install lives on one machine only and silently
goes missing on the next one.

| List | Contains | Installed by |
|---|---|---|
| `servers` | language servers, by **lspconfig** name (`lua_ls`, `ts_ls`, …) | `mason-lspconfig`'s `ensure_installed` |
| `tools` | everything else — formatters, linters (`stylua`, `black`, …) | `mason-tool-installer` |

### Why two lists (i.e. why mason-tool-installer exists)

`mason-lspconfig`'s `ensure_installed` accepts **only lspconfig server
names**. Formatters aren't language servers, so they had nowhere to be
declared and were installed by hand — meaning they existed on one machine and
nowhere else. `mason-tool-installer` is purely the equivalent list for non-LSP
packages; no other feature of it is used.

Two real bugs prompted adding it:

- `stylua` was installed but declared nowhere, so it worked here and would
  have vanished on a new machine.
- `black` and `prettierd` were referenced in `conform.lua` but never installed
  at all, so `<leader>f` silently did nothing in `json` / `yaml` / `markdown`.
  (js/ts/html/css still worked, falling back to the language servers.)

### Adding

Add the name to the appropriate list and restart. Use the **Mason package
name** in `tools` (`prettierd`, not `prettier`) and the **lspconfig name** in
`servers` (`ts_ls`, not `typescript-language-server`) — mason-lspconfig
translates the latter. Formatters also need an entry in `formatters_by_ft` in
`lua/ali/plugins/conform.lua` to actually be used.

### Removing — e.g. dropping `black`

Two steps. The lists only ever install; removing a name never uninstalls
anything:

```lua
-- lua/ali/plugins/lsp.lua — drop the line
local tools = {
	"stylua",
	"prettierd",
}
```

```vim
:MasonUninstall black
```

Then optionally drop `python = { "black" }` from `formatters_by_ft` in
`lua/ali/plugins/conform.lua`. Leaving it is harmless — `<leader>f` on Python
falls back to LSP formatting rather than erroring — just misleading to read.

> **Don't use `:MasonToolsClean` for this.** It uninstalls everything absent
> from `mason-tool-installer`'s `ensure_installed`, which includes all seven
> language servers — those live in the separate `servers` list, which it knows
> nothing about.

## Notes

- **Mason has no lockfile.** `lazy-lock.json` pins plugins, but Mason packages
  install at latest — versions will differ between machines. Pin individual
  ones with `{ "black", version = "26.5.1" }` in the `tools` list if that
  matters.
- **Legacy Angular projects.** `angularls` is gated on the project's own
  TypeScript being >= 5.0 and warns (once) when it skips; `ts_ls` is launched
  with the newest nvm-installed Node so an old project-pinned Node doesn't
  break it. See the comments in `lua/ali/plugins/lsp.lua`.
- `OPTIMIZATIONS.md` is a dated log of config reviews and their rationale —
  useful history, not setup instructions.
