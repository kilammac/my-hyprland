local capabilities = vim.lsp.protocol.make_client_capabilities()

pcall(function()
	capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
end)

-- Configuration globale appliquée à tous les serveurs
vim.lsp.config("*", {
	capabilities = capabilities,
})

-- Lua
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					"${3rd}/luv/library",
				},
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

-- Python
vim.lsp.config("pyright", {})

-- JavaScript / TypeScript / Next.js
vim.lsp.config("ts_ls", {})

-- ESLint
vim.lsp.config("eslint", {})

-- HTML / CSS / JSON
vim.lsp.config("html", {})
vim.lsp.config("cssls", {})
vim.lsp.config("jsonls", {})

-- Tailwind CSS
vim.lsp.config("tailwindcss", {})

-- Bash
vim.lsp.config("bashls", {})

-- Rust
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			cargo = {
				-- Respecter les features par défaut du projet ; pas de --all-features.
				allFeatures = false,
			},
			check = {
				command = "clippy",
			},
		},
	},
})

-- C / C++ / Arduino éventuel
vim.lsp.config("clangd", {})

-- Docker / Podman
vim.lsp.config("dockerls", {})
local compose_bin = vim.fn.stdpath("data") .. "/tools/bin/docker-compose-langserver"
vim.lsp.config("docker_compose_language_service", {
	cmd = { vim.fn.executable(compose_bin) == 1 and compose_bin or "docker-compose-langserver", "--stdio" },
})

-- Markdown
vim.lsp.config("marksman", {})

-- PHP
vim.lsp.config("intelephense", {})

-- YAML
vim.lsp.config("yamlls", {})

-- Flutter / Dart
vim.lsp.config("dartls", {})

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"ts_ls",
	"eslint",
	"html",
	"cssls",
	"jsonls",
	"tailwindcss",
	"bashls",
	"rust_analyzer",
	"clangd",
	"dockerls",
	"docker_compose_language_service",
	"marksman",
	"intelephense",
	"yamlls",
	"dartls",
})

-- Les séquences natives grn/gra/grr/gri/grt restent disponibles.
-- Les alias personnels n'existent que dans les buffers avec un serveur attaché.
local group = vim.api.nvim_create_augroup("UserLsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(event)
		local bufnr = event.buf
		local function map(key, callback, desc)
			vim.keymap.set("n", key, callback, { buffer = bufnr, desc = desc })
		end
		map("gd", vim.lsp.buf.definition, "Aller à la définition")
		map("gD", vim.lsp.buf.declaration, "Aller à la déclaration")
		map("gi", vim.lsp.buf.implementation, "Aller à l’implémentation")
		map("K", vim.lsp.buf.hover, "Documentation du symbole")
		map("<leader>rn", vim.lsp.buf.rename, "Renommer le symbole")
		map("<leader>ca", vim.lsp.buf.code_action, "Action de code")
		map("<F2>", vim.lsp.buf.rename, "Renommer le symbole")
		map("<F4>", vim.lsp.buf.code_action, "Action de code")
		map("<leader>lf", function()
			require("conform").format({
				async = true,
				lsp_format = "prefer",
				filter = require("config.format").lsp_filter,
			})
		end, "Formater en privilégiant le LSP (secours Conform)")
	end,
	desc = "Installer les raccourcis LSP locaux",
})

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})
