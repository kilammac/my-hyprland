vim.opt_local.wrap = true
vim.opt_local.spell = false

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | setlocal wrap< spell<"
