local M = {}
local vim = vim
local api =  vim.api
local G = require 'global'
local HOME = G.home

function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, {...})
  print(unpack(objects))
end

function M.load_config(dir, plugin, stp)
  if plugin and stp then
    require(dir .. '.' .. plugin).setup()
  elseif plugin then
    require(dir .. '.' .. plugin)
  else
    require(dir)
  end
end

function M.makeScratch()
  api.nvim_command('enew') -- equivalent to :enew
  vim.bo[0].buftype='nofile' -- set the current buffer's (buffer 0) buftype to nofile
  vim.bo[0].bufhidden='hide'
  vim.bo[0].swapfile=false
end

function M.restart_lsp()
  local clients = vim.lsp.get_active_clients()
  if not vim.tbl_isempty(clients) then
    vim.lsp.stop_client(clients)
    vim.defer_fn(function() vim.cmd('edit') end, 100)
  end
end

function M.EmptyRegisters()
  local regs=vim.fn.split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
  for _, r in ipairs(regs) do
    vim.fn.call(vim.fn.setreg(r, {}))
  end
end

function M.OpenTerminal()
  api.nvim_command("split term://zsh")
  api.nvim_command("resize 10")
end

function M.search_dotfiles()
  require('telescope.builtin').find_files {
    find_command = {'git', '--git-dir=', HOME .. '/dots/', '--work-tree', HOME, 'ls-tree', '--full-tree', '-r', '--name-only', 'HEAD'}
  }
end

function M.ColorMyPencils()
  vim.o['background']='dark'
  -- vim.cmd('highlight ColorColumn ctermbg=0 guibg=cyan')
  vim.cmd('highlight Normal guibg=none')
  vim.cmd('highlight LineNr guifg=#4dd2dc')
  vim.cmd('highlight netrwDir guifg=#aeacec')
  vim.cmd('highlight qfFileName guifg=#aed75f')
  vim.cmd('hi TelescopeBorder guifg=#4dd2dc')
  vim.cmd('hi FloatermBorder guifg=#4dd2dc')
  vim.cmd("hi TsVirtText guifg=#4dd2dc")
end

local fold = false
function M.ToggleFold()
  if fold then
    fold = false
    vim.cmd('set foldenable')
  else
    fold = true
    vim.cmd('set nofoldenable')
  end
end

function M.TurnOnGuides()
  vim.cmd('set rnu')
  vim.cmd('set nu ')
  vim.cmd('set signcolumn=yes')
  vim.cmd('set colorcolumn=80')
end

function M.TurnOffGuides()
  vim.cmd('set nornu')
  vim.cmd('set nonu')
  vim.cmd('set signcolumn=no')
  vim.cmd('set colorcolumn=800')
end

function M.RunPython()
  api.nvim_command('exec "! python %"')
end

function M.RunTS()
  api.nvim_command('exec "! ts-node %"')
end

function M.RunJS()
  api.nvim_command('exec "! node %"')
end

function M.plug_config(use, item)
  local conf, cmd, branch, opt, requires, run, ft, event = nil, nil, nil, nil, nil, nil, nil, nil
  if item.config then
    conf = item.config
  end
  if item.cmd then
    cmd = item.cmd
  end
  if item.branch then
    branch = item.branch
  end
  if item.opt then
    opt = item.opt
  end
  if item.requires then
    requires = item.requires
  end
  if item.run then
    run = item.run
  end
  if item.ft then
    ft = item.ft
  end
  if item.event then
    event = item.event
  end
  use {
    item.repo,
    config = conf,
    cmd = cmd,
    branch = branch,
    opt = opt,
    requires = requires,
    run = run,
    ft = ft,
    event = event
  }
end

return M
