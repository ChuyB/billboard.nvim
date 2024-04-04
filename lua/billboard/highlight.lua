local M = {}

M.set_highlight = function(guifg, guibg)
  local highlight_group = "BillboardText"

  local highlight_cmd =
    string.format("highlight %s guifg=%s guibg=%s", highlight_group, guifg or "#FFFFFF", guibg or "rgba(0,0,0,0)")

  vim.api.nvim_command(highlight_cmd)

  return highlight_group
end

return M
