return {
	"David-Kunz/gen.nvim",
	opts = {
		model = "qwen_ov",
		command = "ov-chat $prompt",
		debug = false,
		quit_map = "q",
		retry = 1,
		replace = false,
	},
	keys = {
		{ "<space>a", ":Gen Ask<CR>", mode = { "n" } },
		{ "<space>a", ":'<,'>:Gen Ask<CR>", mode = "v" },
		{ "<space>r", ":Gen Review_Code<CR>", mode = { "n" } },
	},
}
