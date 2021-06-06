local M = {}

M.luaFormat = {
  formatCommand = "lua-format -i -c" .. vim.fn.stdpath('config') ..
      "/.lua-format",
  formatStdin = true
}

M.isort = {formatCommand = "isort --quiet -", formatStdin = true}
M.yapf = {formatCommand = "yapf --quiet", formatStdin = true}
M.black = {formatCommand = "black --quiet -", formatStdin = true}

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
