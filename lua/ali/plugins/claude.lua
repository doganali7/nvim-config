return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" }, -- optional, but nicer terminal UX
  config = true,
  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>",         desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",     desc = "Focus Claude" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>",      mode = "v", desc = "Send selection to Claude" },
    { "<leader>aa", "<cmd>ClaudeCodeAdd<cr>",       desc = "Add file to context" },
    -- accept / reject proposed diffs:
    { "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
    { "<leader>an", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Reject Claude diff" },
  },
}
