local config = require("billboard.config")
local highlight = require("billboard.highlight")
local utils = require("billboard.utils")

local M = {}

local function write_text(buf, opts)
  local win_height = vim.api.nvim_win_get_height(0)
  local win_width = vim.api.nvim_win_get_width(0)

  local start_row = math.floor((win_height - #opts.lines) / 2)
  local start_col = math.floor((win_width - utils.get_max_width(opts.lines)) / 2)

  local hl_group = highlight.set_highlight(opts.guifg, opts.guibg)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn["repeat"]({ "" }, start_row))

  for i, line in ipairs(opts.lines) do
    local current_row = start_row + i - 1
    vim.api.nvim_buf_set_lines(buf, current_row, current_row, false, { string.rep(" ", start_col) .. line })
    vim.api.nvim_buf_add_highlight(buf, -1, hl_group, current_row, 0, -1)
  end
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

function M.open_new_billboard()
  -- Get current buffer
  local buf_id = vim.api.nvim_get_current_buf()
  local win_id = 0

  -- Opens a float if buffer is not valid or if buffer is not empty
  if buf_id == nil or not vim.api.nvim_buf_is_valid(buf_id) or not (vim.api.nvim_buf_get_name(buf_id) == "") then
    buf_id = vim.api.nvim_create_buf(false, true)
    win_id = vim.api.nvim_open_win(buf_id, true, {
      relative = "editor",
      width = vim.api.nvim_win_get_width(0),
      height = vim.api.nvim_win_get_height(0),
      col = 0,
      row = 0,
      style = "minimal",
      border = "none",
    })
  end

  -- Sets buffer and window options
  utils.set_buf_options(buf_id)
  utils.set_win_options(win_id)

  -- Write text to buffer
  write_text(buf_id, config.render)

  -- Set buffer to non-modifiable
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf_id })
end

return M
