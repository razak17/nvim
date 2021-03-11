local config = {}

-- UTILS
function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  print(unpack(objects))
end

function config.makeScratch()
  vim.api.nvim_command('enew') -- equivalent to :enew
  vim.bo[0].buftype='nofile' -- set the current buffer's (buffer 0) buftype to nofile
  vim.bo[0].bufhidden='hide'
  vim.bo[0].swapfile=false
end

function config.OpenTerminal()
  vim.api.nvim_command("split term://zsh")
  vim.api.nvim_command("resize 10")
end

function config.TurnOnGuides()
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.signcolumn = "yes"
  vim.wo.colorcolumn = "+1"
end

function config.TurnOffGuides()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.wo.colorcolumn = ""
end

function config.ToggleFold()
  if vim.wo.foldenable == true then
    vim.cmd('set nofoldenable')
  else
    vim.cmd('set foldenable')
  end
end

return config
