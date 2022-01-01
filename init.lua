local init_path = debug.getinfo(1, "S").source:sub(2)
local base_dir = init_path:match("(.*[/\\])"):sub(1, -2)

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then
  vim.opt.rtp:append(base_dir)
end

-- Load Modules
require "user.config.globals"
require("user.config.bootstrap"):init(base_dir)

local Log = require "user.core.log"
Log:debug "Starting Rvim"

require("user.config"):load()
