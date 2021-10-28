-- -- TODO: handle this better
if os.getenv "RVIM_CONFIG_DIR" then
  vim.opt.rtp:append(os.getenv "RVIM_CONFIG_DIR")
else
  vim.opt.rtp:append(get_config_dir())
end

local init_path = debug.getinfo(1, "S").source:sub(2)
local base_dir = init_path:match("(.*[/\\])"):sub(1, -2)

if not vim.tbl_contains(vim.opt.rtp:get(), base_dir) then
  vim.opt.rtp:append(base_dir)
end

-- Load Modules
require("config"):load()
