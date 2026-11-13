local M = {}

-- Choisir un seul serveur pour éviter plusieurs formatages LSP successifs.
local preferred = {
	lua = "lua_ls",
	python = "pyright",
	javascript = "ts_ls",
	javascriptreact = "ts_ls",
	typescript = "ts_ls",
	typescriptreact = "ts_ls",
	html = "html",
	css = "cssls",
	json = "jsonls",
	jsonc = "jsonls",
	rust = "rust_analyzer",
	c = "clangd",
	cpp = "clangd",
	php = "intelephense",
	dart = "dartls",
	yaml = "yamlls",
	["yaml.docker-compose"] = "yamlls",
}

function M.lsp_filter(client)
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" })
	table.sort(clients, function(a, b)
		local target = preferred[vim.bo[bufnr].filetype]
		if (a.name == target) ~= (b.name == target) then
			return a.name == target
		end
		if a.name == b.name then
			return a.id < b.id
		end
		return a.name < b.name
	end)
	return clients[1] ~= nil and client.id == clients[1].id
end

function M.toggle()
	vim.b.autoformat_disabled = not vim.b.autoformat_disabled
	vim.notify("Formatage automatique : " .. (vim.b.autoformat_disabled and "désactivé" or "activé"))
end

require("conform").setup({
	default_format_opts = {
		lsp_format = "fallback",
		filter = M.lsp_filter,
	},
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		["yaml.docker-compose"] = { "prettier" },
		markdown = { "prettier" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		rust = { "rustfmt" },
	},
	format_on_save = function(bufnr)
		if vim.b[bufnr].autoformat_disabled or require("config.util").is_large_buffer(bufnr) then
			return
		end
		-- L'écriture attend le formatage ; le formatage manuel reste asynchrone.
		return { timeout_ms = 2000 }
	end,
})

return M
