local M = {}

function M.get_max_width(lines)
  local max_width = 0

  for _, line in ipairs(lines) do
    local _, character_count = line:gsub("[^\128-\193]", "")
    max_width = math.max(max_width, character_count)
  end

  return max_width
end

function M.set_buf_options(buf)
  local scope = { buf = buf }

  local options = {
    buftype = "nofile",
    bufhidden = "delete",
    swapfile = false,
    modifiable = true,
    filetype = "billboard",
  }

  for opt, val in pairs(options) do
    vim.api.nvim_set_option_value(opt, val, scope)
  end

  vim.api.nvim_buf_set_name(buf, "Billboard")
end

function M.set_win_options(win)
  local scope = { win = win, scope = "local" }

  local options = {
    number = false,
    relativenumber = false,
    cursorline = false,
    cursorcolumn = false,
    foldcolumn = "0",
    spell = false,
    list = false,
    signcolumn = "no",
    colorcolumn = "",
    statuscolumn = "",

    fillchars = "eob: ",
  }

  for opt, val in pairs(options) do
    vim.api.nvim_set_option_value(opt, val, scope)
  end
end

return M
