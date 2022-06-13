local Log = require("user.core.log")
Log:debug("Starting rVim")

vim.g.python3_host_prog = rvim.paths.python3
vim.g.node_host_prog = rvim.paths.node
for _, v in pairs(rvim.util.disabled_providers) do
  vim.g["loaded_" .. v .. "_provider"] = 0
end

if rvim.util.defer then
  vim.cmd([[syntax off]])
  vim.cmd([[filetype off]])
  vim.defer_fn(
    vim.schedule_wrap(function()
      vim.defer_fn(function()
        vim.cmd([[syntax on]])
        vim.cmd([[filetype plugin indent on]])
      end, 0)
    end),
    0
  )
end

R("user.config.settings"):init()
R("user.core.commands")
R("user.highlights")
R("user.core.plugins").ensure_installed()
R("user.lsp").setup()
