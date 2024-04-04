local M = {}

local function open_on_enter()
  vim.cmd([[
    augroup OpenBillboard
    autocmd!
    autocmd VimEnter * lua require("billboard").open_new_billboard()
    augroup END
  ]])
end

local function open_cmd()
  vim.cmd([[
    command! OpenBillboard lua require("billboard").open_new_billboard()
  ]])
end

local function close_cmd()
  vim.cmd([[
    command! CloseBillboard lua require("billboard").close_billboard()
  ]])
end

function M.set_commands()
  open_on_enter()
  open_cmd()
  close_cmd()
end

return M
