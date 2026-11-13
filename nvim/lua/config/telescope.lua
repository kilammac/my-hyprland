require("telescope").setup({
	defaults = {
		file_ignore_patterns = {
			"^node_modules/",
			"/node_modules/",
			"^%.git/",
			"/%.git/",
			"^dist/",
			"/dist/",
			"^build/",
			"/build/",
			"^target/",
			"/target/",
			"^%.next/",
			"/%.next/",
		},
	},
	pickers = {
		-- Inclure les fichiers cachés, tout en respectant les fichiers ignorés par Git.
		find_files = { hidden = true },
		live_grep = { additional_args = { "--hidden" } },
	},
})
