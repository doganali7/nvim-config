return {
	{
		"saghen/blink.cmp",
		-- Pin to a release so lazy.nvim downloads the prebuilt fuzzy-matcher
		-- binary; building it locally would require nightly Rust.
		version = "1.*",
		-- Without a trigger this spec would be a start plugin (it has its own
		-- top-level entry, so being a dependency of nvim-lspconfig doesn't make
		-- it lazy on its own). InsertEnter is the last possible moment that
		-- still beats the first completion; in practice the lspconfig
		-- dependency chain has usually pulled it in at BufReadPre already.
		event = "InsertEnter",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				-- <C-n>/<C-p> select, <C-y> accept
				-- <C-Space> open menu / toggle docs, <C-e> cancel.
				preset = "default",
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
				["<C-f>"] = { "scroll_documentation_up", "fallback" },
				["<C-l>"] = { "snippet_forward", "fallback" },
				["<C-h>"] = { "snippet_backward", "fallback" },
			},
			completion = {
				-- show docs manual (<C-Space>).
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
			},
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
					lsp = { fallbacks = { "buffer" } },
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
