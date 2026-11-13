require("oil").setup({
	default_file_explorer = true,
	-- Préserver Ctrl-s pour sauvegarder et Ctrl-h/l pour changer de fenêtre.
	keymaps = {
		["<C-s>"] = false,
		["<C-h>"] = false,
		["<C-l>"] = false,
		["<C-v>"] = { "actions.select", opts = { vertical = true } },
		["<C-x>"] = { "actions.select", opts = { horizontal = true } },
		["gR"] = "actions.refresh",
	},
	view_options = {
		show_hidden = true,
	},
	columns = {
		"icon",
	},
})
