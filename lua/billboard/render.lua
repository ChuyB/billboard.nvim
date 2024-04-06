local config = require("billboard.config")
local highlight = require("billboard.highlight")
local utils = require("billboard.utils")
local M = {}

local function prepare_buffer(buf)
  local win_height = vim.api.nvim_win_get_height(0)
  local win_width = vim.api.nvim_win_get_width(0)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn["repeat"]({ string.rep(" ", win_width) }, win_height))
end

local function add_to_window_groups(groups, blocks)
  for _, block in ipairs(blocks) do
    -- Set defaults alingments if not specified
    block.alignment = block.alignment or config.default_alignment
    block.alignment.vertical = block.alignment.vertical or config.default_alignment.vertical
    block.alignment.horizontal = block.alignment.horizontal or config.default_alignment.horizontal
    -- Set defaults highlight if not specified
    block.highlight = block.highlight or config.default_highlight
    block.highlight.guifg = block.highlight.guifg or config.default_highlight.guifg
    block.highlight.guibg = block.highlight.guibg or config.default_highlight.guibg

    local group_name = block.alignment.vertical .. "_" .. block.alignment.horizontal

    groups[group_name] = groups[group_name] or {}

    table.insert(groups[group_name], { block = block, position = { row = 0, col = 0 } })
  end
end

local function set_contents_offset(group)
  local prev_block_height = 0
  -- local prev_block_width = 0
  for _, element in ipairs(group) do
    element.position.row = prev_block_height
    prev_block_height = #element.block.content
    -- prev_block_width = utils.get_max_width(element.block.content)
  end
end

local function get_group_dimensions(group)
  local height = 0
  local width = 0
  for _, element in ipairs(group) do
    height = height + #element.block.content
    width = math.max(width, utils.get_max_width(element.block.content))
  end
  return height, width
end

local function get_group_start_pos(location, group_width, group_height)
  local win_height = vim.api.nvim_win_get_height(0)
  local win_width = vim.api.nvim_win_get_width(0)
  local start_row = 0
  local start_col = 0
  local cases = {
    ["top_left"] = function()
      start_row = 0
      start_col = 0
    end,
    ["top_center"] = function()
      start_row = 0
      start_col = math.floor((win_width - group_width) / 2)
    end,
    ["top_right"] = function()
      start_row = 0
      start_col = win_width - group_width
    end,
    ["center_left"] = function()
      start_row = math.floor((win_height - group_height) / 2)
      start_col = 0
    end,
    ["center_center"] = function()
      start_row = math.floor((win_height - group_height) / 2)
      start_col = math.floor((win_width - group_width) / 2)
    end,
    ["center_right"] = function()
      start_row = math.floor((win_height - group_height) / 2)
      start_col = win_width - group_width
    end,
    ["bottom_left"] = function()
      start_row = win_height - group_height
      start_col = 0
    end,
    ["bottom_center"] = function()
      start_row = win_height - group_height
      start_col = math.floor((win_width - group_width) / 2)
    end,
    ["bottom_right"] = function()
      start_row = win_height - group_height
      start_col = win_width - group_width
    end,
    ["default"] = function()
      start_row = 0
      start_col = 0
    end,
  }

  if cases[location] then
    cases[location]()
  else
    cases["default"]()
  end

  return start_row, start_col
end

local function print_group(buf, group, location)
  local group_height, group_width = get_group_dimensions(group)
  local group_start_row, group_start_col = get_group_start_pos(location, group_width, group_height)

  for i, element in ipairs(group) do
    local hl_group = highlight.get_new_hl_group(
      { location = location, index = i },
      element.block.highlight.guifg,
      element.block.highlight.guibg
    )
    local block = element.block
    local position = element.position

    local start_row = group_start_row + position.row
    local start_col = group_start_col + position.col
    local end_col = start_col + utils.get_max_width(block.content) + 1

    for j, line in ipairs(block.content) do
      local current_row = start_row + j - 1
      vim.api.nvim_buf_set_text(buf, current_row, start_col, current_row, end_col, { line })
      if hl_group ~= nil then
        vim.api.nvim_buf_add_highlight(buf, -1, hl_group, current_row, start_col, -1)
      end
    end
  end
end

M.write_text = function(buf, render)
  local groups = {}
  prepare_buffer(buf)
  add_to_window_groups(groups, render)

  for location, group in pairs(groups) do
    set_contents_offset(group)
    print_group(buf, group, location)
  end
end

return M
