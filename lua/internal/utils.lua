local M = {}

function M.OpenTerminal()
  vim.api.nvim_command("split term://zsh")
  vim.api.nvim_command("resize 10")
end

function M.TurnOnGuides()
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.signcolumn = "yes"
  vim.wo.colorcolumn = "+1"
  vim.o.laststatus = 2
  vim.o.showtabline = 2
end

function M.TurnOffGuides()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.wo.colorcolumn = ""
  vim.o.laststatus = 0
  vim.o.showtabline = 0
end

return M
