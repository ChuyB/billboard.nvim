local M = {}

M.config = {
	render = {
		lines = { "Neovim!" },
	},
}

local function get_max_width(lines)
	local max_width = 0

	for _, line in ipairs(lines) do
		local _, character_count = line:gsub("[^\128-\193]", "")
		max_width = math.max(max_width, character_count)
	end

	return max_width
end

local function set_highlight(guifg, guibg)
	local highlight_group = "BillboardText"

	local highlight_cmd =
		string.format("highlight %s guifg=%s guibg=%s", highlight_group, guifg or "#FFFFFF", guibg or "rgba(0,0,0,0)")

	vim.api.nvim_command(highlight_cmd)

	return highlight_group
end

local function write_text(buf, opts)
	-- Gets window height and width
	local win_height = vim.api.nvim_win_get_height(0)
	local win_width = vim.api.nvim_win_get_width(0)

	-- Text starting position
	local start_row = math.floor((win_height - #opts.lines) / 2)
	local start_col = math.floor((win_width - get_max_width(opts.lines)) / 2)

	-- Sets highlight group
	local hl_group = set_highlight(opts.guifg, opts.guibg)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn["repeat"]({ "" }, start_row))

	for i, line in ipairs(opts.lines) do
		local current_row = start_row + i - 1
		vim.api.nvim_buf_set_lines(buf, current_row, current_row, false, { string.rep(" ", start_col) .. line })
		vim.api.nvim_buf_add_highlight(buf, -1, hl_group, current_row, 0, -1)
	end
end

local function set_buf_options(buf)
	-- Set the buffer options
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_set_option_value("filetype", "billboard", { buf = buf })
	vim.api.nvim_buf_set_name(buf, "Billboard")
end

local function set_win_options(win)
	-- Set the window options to match minimal window style
	vim.api.nvim_set_option_value("number", false, { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("relativenumber", false, { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("cursorline", false, { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("cursorcolumn", false, { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("foldcolumn", "0", { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("spell", false, { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("list", false, { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("signcolumn", "no", { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("colorcolumn", "", { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("statuscolumn", "", { win = 0, scope = "local" })
	vim.api.nvim_set_option_value("fillchars", "eob: ", { win = 0, scope = "local" })
end

function M.open_new_billboard()
	-- Get current buffer
	local buf_id = vim.api.nvim_get_current_buf()

  -- TODO: Check if the buffer is a NoName buffer
	if buf_id == nil or not vim.api.nvim_buf_is_valid(buf_id) then
		buf_id = vim.api.nvim_create_buf(false, true)
	end

	-- Sets buffer and window options
	set_buf_options(buf_id)
	set_win_options(0)

	-- Write text to buffer
	write_text(buf_id, M.config.render)

	-- Set buffer to non-modifiable
	vim.api.nvim_buf_set_option(buf_id, "modifiable", false)
end

function M.close_billboard()
	local buf_id = vim.api.nvim_get_current_buf()

	if buf_id == nil or not vim.api.nvim_buf_is_valid(buf_id) then
		return
	end

	local file_type = vim.api.nvim_buf_get_option(buf_id, "filetype")
	if file_type == "billboard" then
		vim.api.nvim_buf_delete(buf_id, { force = true })
	end

end

local function set_commands()
	-- Open Billboard on VimEnter
	vim.cmd([[
    augroup OpenBillboard
      autocmd!
      autocmd VimEnter * lua require("billboard").open_new_billboard()
    augroup END
  ]])

	-- Command to open billboard
	vim.cmd([[
    command! OpenBillboard lua require("billboard").open_new_billboard()
  ]])

	-- Command to close billboard
	vim.cmd([[
    command! CloseBillboard lua require("billboard").close_billboard()
  ]])
end

function M.setup(opts)
	opts = opts or {}

	if opts.render then
		M.config.render = opts.render
	end

	set_commands()
end

return M
