local gs = require("gitsigns")

gs.setup({
	on_attach = function(bufnr)
		local function navigate(direction)
			return function()
				if vim.wo.diff then
					vim.cmd.normal({ direction == "next" and "]c" or "[c", bang = true })
				else
					gs.nav_hunk(direction)
				end
			end
		end
		vim.keymap.set("n", "]c", navigate("next"), { buffer = bufnr, desc = "Modification Git suivante" })
		vim.keymap.set("n", "[c", navigate("prev"), { buffer = bufnr, desc = "Modification Git précédente" })
		vim.keymap.set(
			"n",
			"<leader>hp",
			gs.preview_hunk,
			{ buffer = bufnr, desc = "Prévisualiser la modification Git" }
		)
		vim.keymap.set("n", "<leader>hb", gs.blame_line, { buffer = bufnr, desc = "Auteur de la ligne Git" })
	end,
})
