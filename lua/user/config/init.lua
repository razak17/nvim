local Log = require "user.core.log"
Log:debug "Starting rVim"

vim.g.python3_host_prog = rvim.python_path
vim.g.node_host_prog = rvim.node_path
for _, v in pairs(rvim.providers_disabled) do
  vim.g["loaded_" .. v .. "_provider"] = 0
end

if rvim.defer then
  vim.cmd [[syntax off]]
  vim.cmd [[filetype off]]
  vim.defer_fn(
    vim.schedule_wrap(function()
      vim.defer_fn(function()
        vim.cmd [[syntax on]]
        vim.cmd [[filetype plugin indent on]]
      end, 0)
    end),
    0
  )
end

vim.g.colors_name = rvim.colorscheme
vim.cmd("colorscheme " .. rvim.colorscheme)
R("user.config.settings"):init()
R "user.core.commands"
R("user.core.plugins").ensure_installed()
R("user.lsp").setup()
