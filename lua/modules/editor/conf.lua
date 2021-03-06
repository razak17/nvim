local api =  vim.api
local config = {}


function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  print(unpack(objects))
end

function config.makeScratch()
  api.nvim_command('enew') -- equivalent to :enew
  vim.bo[0].buftype='nofile' -- set the current buffer's (buffer 0) buftype to nofile
  vim.bo[0].bufhidden='hide'
  vim.bo[0].swapfile=false
end

function config.OpenTerminal()
  api.nvim_command("split term://zsh")
  api.nvim_command("resize 10")
end

function config.TurnOnGuides()
  vim.cmd('set rnu')
  vim.cmd('set nu ')
  vim.cmd('set signcolumn=yes')
  vim.cmd('set colorcolumn=80')
end

function config.TurnOffGuides()
  vim.cmd('set nornu')
  vim.cmd('set nonu')
  vim.cmd('set signcolumn=no')
  vim.cmd('set colorcolumn=800')
end

function config.ToggleFold()
  local fold = false
  if fold then
    fold = false
    vim.cmd('set foldenable')
  else
    fold = true
    vim.cmd('set nofoldenable')
  end
end

return config
