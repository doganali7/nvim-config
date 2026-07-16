return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" }, -- optional, but nicer terminal UX
	config = true,
	keys = {
		{ "<leader>Cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
		{ "<leader>Cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
		{ "<leader>Cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
		{ "<leader>Ca", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer to context" },
		{ "<leader>Cy", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
		{ "<leader>Cn", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Claude diff" },
	},
}
