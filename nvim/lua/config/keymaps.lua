local map = vim.keymap.set

local function telescope(method)
	return function()
		require("config.telescope")
		require("telescope.builtin")[method]()
	end
end

-- =========================
-- BASE
-- =========================

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Sauvegarder" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quitter" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quitter tout sans sauvegarder" })

map("n", "<C-s>", "<cmd>w<cr>", { desc = "Sauvegarder (rapide)" })

-- =========================
-- EXPLORATEUR (oil)
-- =========================

map("n", "-", "<cmd>Oil<cr>", { desc = "Ouvrir le dossier parent" })

-- =========================
-- BUFFERS
-- =========================

map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Fermer le buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Buffer suivant" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Buffer précédent" })

-- =========================
-- NAVIGATION FENÊTRES
-- =========================

map("n", "<C-h>", "<C-w>h", { desc = "Aller à la fenêtre gauche" })
map("n", "<C-j>", "<C-w>j", { desc = "Aller à la fenêtre du bas" })
map("n", "<C-k>", "<C-w>k", { desc = "Aller à la fenêtre du haut" })
map("n", "<C-l>", "<C-w>l", { desc = "Aller à la fenêtre droite" })

map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Fermer la fenêtre" })

-- =========================
-- DÉPLACER LIGNES
-- =========================

map("n", "<A-j>", ":m .+1<cr>==", { desc = "Déplacer la ligne vers le bas" })
map("n", "<A-k>", ":m .-2<cr>==", { desc = "Déplacer la ligne vers le haut" })

map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Déplacer la sélection vers le bas" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Déplacer la sélection vers le haut" })

-- =========================
-- RECHERCHE (Telescope)
-- =========================

map("n", "<leader>ff", telescope("find_files"), { desc = "Rechercher un fichier" })

map("n", "<leader>fg", telescope("live_grep"), { desc = "Rechercher du texte dans le projet" })

map("n", "<leader>fb", telescope("buffers"), { desc = "Rechercher un buffer ouvert" })

map("n", "<leader>fh", telescope("help_tags"), { desc = "Rechercher dans l'aide" })

-- =========================
-- DIAGNOSTICS (erreurs)
-- =========================

map("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Diagnostic précédent" })
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Diagnostic suivant" })

map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Afficher l’erreur" })
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Liste des diagnostics" })

-- =========================
-- FORMATAGE
-- =========================

map("n", "<leader>cf", function()
	require("conform").format({ async = true })
end, { desc = "Formater le fichier" })

map("x", "<leader>cf", function()
	local first = vim.fn.getpos("v")[2]
	local last = vim.fn.getpos(".")[2]
	if first > last then
		first, last = last, first
	end
	local line = vim.api.nvim_buf_get_lines(0, last - 1, last, false)[1] or ""
	-- Fin exclusive : inclure toute la dernière ligne, aussi avec Stylua.
	require("conform").format({
		async = true,
		range = { start = { first, 0 }, ["end"] = { last, #line } },
	})
end, { desc = "Formater les lignes sélectionnées" })

map("n", "<leader>uf", function()
	require("config.format").toggle()
end, { desc = "Basculer le formatage automatique du buffer" })

map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Effacer le surlignage de recherche" })

-- =========================
-- TERMINAL
-- =========================

map("n", "<leader>tt", "<cmd>botright split | terminal<cr>", { desc = "Ouvrir un terminal" })
map("t", "<esc>", [[<C-\><C-n>]], { desc = "Quitter le mode terminal" })

-- =========================
-- FERMETURE RAPIDE
-- =========================

map("n", "<leader>x", "<cmd>close<cr>", { desc = "Fermer la fenêtre actuelle" })
