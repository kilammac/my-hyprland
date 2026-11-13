local group = vim.api.nvim_create_augroup("UserEditing", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.hl.on_yank()
	end,
	desc = "Mettre la copie en surbrillance",
})

-- Les exceptions par langage vivent dans after/ftplugin ; EditorConfig
-- (intégré à Neovim) peut ensuite appliquer les règles propres au projet.

-- Le runtime ne distingue pas encore ces fichiers du YAML ordinaire.
vim.filetype.add({
	filename = {
		["compose.yaml"] = "yaml.docker-compose",
		["compose.yml"] = "yaml.docker-compose",
		["docker-compose.yaml"] = "yaml.docker-compose",
		["docker-compose.yml"] = "yaml.docker-compose",
	},
	pattern = {
		[".*[/]docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
		[".*[/]compose%..*%.ya?ml"] = "yaml.docker-compose",
	},
})
