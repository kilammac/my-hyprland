local M = {}

-- Limite commune pour les traitements automatiques coûteux : 1 Mio.
M.max_file_size = 1024 * 1024

function M.is_large_buffer(bufnr)
	bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	return vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr)) > M.max_file_size
end

return M
