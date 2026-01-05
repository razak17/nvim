local enabled = ar.config.plugin.custom.tab_search.enable

if not ar or ar.none or not enabled then return end

local fn = vim.fn
local fmt = string.format

-- smooth searching, allow tabbing between search results similar to using <c-g>
-- or <c-t> the main difference being tab is easier to hit and remapping those keys
-- to these would swallow up a tab mapping
-- UPDATE: Pick a key you don’t type normally (commonly Ctrl-Z) as wildcharm.
-- Return that key from your expr mapping when cmdtype is ':'.
vim.opt.wildcharm = 26 -- Ctrl-Z
local function search(direction_key, default)
  local c_type = fn.getcmdtype()
  return (c_type == '/' or c_type == '?') and fmt('<CR>%s<C-r>/', direction_key)
    or default
end

map('c', '<Tab>', function() return search('/', '<C-z>') end, { expr = true })
map('c', '<S-Tab>', function() return search('?', '<C-z>') end, { expr = true })
