local M = {}

local lua_indent = ' --tab-width=2 --indent-width=2'
local lua_no_simple_block = ' --no-keep-simple-control-block-one-line'
local lua_no_simple_func = ' --no-keep-simple-function-one-line'
local lua_break =
    ' --break-after-table-lb --break-before-table-rb --chop-down-table '
local lua_limit = ' --column-limit=80'

M.luaFormat = {
  formatCommand = "lua-format -i" .. lua_indent .. lua_no_simple_block ..
      lua_no_simple_func .. lua_break .. lua_limit,
  formatStdin = true
}

M.isort = {formatCommand = "isort --quiet -", formatStdin = true}
M.yapf = {formatCommand = "yapf --quiet", formatStdin = true}

M.prettier = {
  formatCommand = "prettier --stdin-filepath ${INPUT}",
  formatStdin = true
}
M.prettier_yaml = {
  formatCommand = "prettier --stdin-filepath ${INPUT}",
  formatStdin = true
}

M.shfmt = {formatCommand = 'shfmt -ci -s -bn', formatStdin = true}

return M
