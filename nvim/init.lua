require("config.options")
require("config.plugins")
require("config.colorscheme")
require("config.keymaps")
require("config.autocmds")
require("config.oil")
require("config.lsp")
require("config.format")
require("config.bufferline")
require("config.git")
require("config.treesitter")

-- La complétion est initialisée seulement au premier besoin.
local completion_group = vim.api.nvim_create_augroup("UserCompletion", { clear = true })
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
	group = completion_group,
	once = true,
	callback = function()
		require("config.cmp")
	end,
	desc = "Initialiser la complétion au premier besoin",
})
