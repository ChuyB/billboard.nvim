local config = require("billboard.config")
local commands = require("billboard.commands")
local manager = require("billboard.manager")

local Billboard = {}

function Billboard.setup(opts)
  opts = opts or {}

  if opts.render then
    config.render = opts.render
  end

  commands.set_commands()
end

Billboard.open_new_billboard = manager.open_new_billboard
Billboard.close_billboard = manager.close_billboard

return Billboard
