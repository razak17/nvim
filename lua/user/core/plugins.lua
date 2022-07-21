local packer = nil
local fmt = string.format
local utils = require('user.utils.plugins')
local packer_compiled = rvim.paths.packer_compiled

local Plug = {}
Plug.__index = Plug

function Plug:load_packer()
  if not packer then
    vim.cmd('packadd! packer.nvim')
    packer = require('packer')
  end
  rvim.safe_require('impatient')

  local plugins = utils:get_plugins_list()
  utils:bootstrap_packer(packer, plugins)
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then Plug:load_packer() end
    return packer[key]
  end,
})

function plugins.ensure_installed()
  utils:init_ensure_installed()
  Plug:load_packer()

  plugins.load_compile()

  if not vim.g.packer_compiled_loaded and vim.loop.fs_stat(packer_compiled) then
    rvim.source(packer_compiled)
    vim.g.packer_compiled_loaded = true
  end
end

function plugins.load_compile()
  if vim.fn.filereadable(packer_compiled) ~= 1 then
    plugins.install()
    plugins.compile()
  end
end

function plugins.del_compiled()
  if vim.fn.filereadable(packer_compiled) ~= 1 then
    utils:plug_notify('packer_compiled file does not exist', 'info')
  else
    vim.fn.delete(packer_compiled)
    utils:plug_notify('packer_compiled was deleted', 'info')
  end
end

function plugins.reload()
  Plug:load_packer()
  plugins.ensure_installed()
  plugins.install()
  plugins.compile()
  require('_compiled_rolling')
end

function plugins.invalidate()
  rvim.invalidate('user.modules', true, { 'mason' })
  plugins.reload()
end

function plugins.recompile()
  rvim.invalidate(fmt('user.modules.%s', vim.split(vim.fn.expand('%'), '/')[4]), true, { 'mason' })
  plugins.reload()
end

rvim.augroup('PackerSetupInit', {
  {
    event = { 'BufWritePost' },
    desc = 'Packer setup and reload',
    pattern = { '*/user/modules/**/*.lua', '*/user/config/init.lua' },
    command = function() plugins.recompile() end,
  },
  {
    event = 'User',
    pattern = 'PackerCompileDone',
    desc = 'Inform me that packer has finished compiling',
    command = function() utils:plug_notify('Packer compile complete', 'info') end,
  },
})

return plugins
