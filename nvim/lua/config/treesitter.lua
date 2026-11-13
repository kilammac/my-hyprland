-- Version moderne de nvim-treesitter : pas de require("nvim-treesitter.configs").setup.
-- Les parseurs sont installés explicitement, jamais téléchargés à chaque ouverture.
require("nvim-treesitter").setup({})

local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	callback = function(event)
		if vim.bo[event.buf].buftype ~= "" then
			return
		end
		if require("config.util").is_large_buffer(event.buf) then
			-- Certains ftplugins natifs démarrent déjà Treesitter (Lua, Markdown…).
			vim.treesitter.stop(event.buf)
			return
		end
		local lang = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
		if lang and vim.treesitter.language.add(lang) then
			vim.treesitter.start(event.buf, lang)
		end
	end,
	desc = "Coloration Treesitter si un parseur est installé (hors gros fichiers)",
})
