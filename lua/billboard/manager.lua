local render = require("billboard.render")
local config = require("billboard.config")
local utils = require("billboard.utils")

local M = {}

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

  -- Opens a float if buffer is not valid or buffer is not empty
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
  render.write_text(buf_id, config.render)

  -- Set buffer to non-modifiable
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf_id })
end

return M
