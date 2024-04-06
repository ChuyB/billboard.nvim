local M = {}

M.get_new_hl_group = function(name, guifg, guibg)
  if guifg == "" and guibg == "" then
    return nil
  end

  local highlight_group = ("BillboardText_%s_Block%s"):format(name.location, name.index)
  local guifg_text = ""
  local guibg_text = ""

  if guifg ~= "" then
    guifg_text = ("guifg=%s"):format(guifg)
  end

  if guibg ~= "" then
    guibg_text = ("guibg=%s"):format(guibg)
  end

  local highlight_cmd = ("highlight %s %s %s"):format(highlight_group, guifg_text, guibg_text)

  vim.api.nvim_command(highlight_cmd)

  return highlight_group
end

return M
