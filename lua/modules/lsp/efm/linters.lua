local M = {}

M.eslint = {
  lintCommand = "./node_modules/.bin/eslint -f unix --stdin --stdin-filename ${INPUT}",
  lintIgnoreExitCode = true,
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  formatCommand = "./node_modules/.bin/eslint --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

M.flake8 = {
  LintCommand = "flake8 --ignore=E501 --stdin-display-name ${INPUT} -",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"}
}

M.shellcheck = {
  LintCommand = 'shellcheck -f gcc -x',
  lintFormats = {
    '%f:%l:%c: %trror: %m',
    '%f:%l:%c: %tarning: %m',
    '%f:%l:%c: %tote: %m'
  }
}

return M
