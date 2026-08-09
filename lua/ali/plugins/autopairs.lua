return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	opts = {
		check_ts = true, -- use treesitter to be smarter about pair insertion
	},
}
