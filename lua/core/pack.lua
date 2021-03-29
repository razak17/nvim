local fn = vim.fn
local G = require 'core.global'
local data_dir = G.data_dir
local packer_compiled = data_dir .. 'plugin/packages.vim'
local modules_dir = G.vim_path .. 'lua/modules'
local compile_to_lua = data_dir .. 'lua/_compiled.lua'
local packer = nil

local Packer = {}
Packer.__index = Packer

function Packer:load_plugins()
  self.repos = {}

  local get_plugins_list = function()
    local list = {}
    local tmp = vim.split(fn.globpath(modules_dir, '*/plugins.lua'), '\n')
    for _, f in ipairs(tmp) do
      list[#list + 1] = f:sub(#modules_dir - 7, -1)
    end
    return list
  end

  local plugins_file = get_plugins_list()
  for _, m in ipairs(plugins_file) do
    local repos = require(m:sub(0, #m - 4))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend('force', {repo}, conf)
    end
  end
end

function Packer:load_packer()
  if not packer then
    vim.api.nvim_command('packadd packer.nvim')
    packer = require('packer')
  end
  packer.init({
    compile_path = packer_compiled,
    git = {clone_timeout = 120},
    disable_commands = true
  })
  local use = packer.use
  packer.reset()
  use {'wbthomason/packer.nvim', opt = true}
  self:load_plugins()
  for _, repo in ipairs(self.repos) do
    use(repo)
  end
end

function Packer:init_ensure_plugins()
  self:load_packer()
  packer.install()
  packer.compile()
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if packer == nil then
      Packer:load_packer()
    end
    return packer[key]
  end
})

function plugins.ensure_plugins()
  Packer:init_ensure_plugins()
end

function plugins.convert_compile_file()
  local lines = {}
  local lnum = 1
  lines[#lines + 1] = 'vim.cmd [[packadd packer.nvim]]\n'

  for line in io.lines(packer_compiled) do
    lnum = lnum + 1
    if lnum > 15 then
      lines[#lines + 1] = line .. '\n'
      if line == 'END' then
        break
      end
    end
  end
  table.remove(lines, #lines)

  if G.exists(compile_to_lua) then
    os.remove(compile_to_lua)
  else
    if not G.isdir(data_dir .. 'lua') then
      os.execute('mkdir -p ' .. data_dir .. 'lua')
    end
  end

  local file = io.open(compile_to_lua, "w")
  for _, line in ipairs(lines) do
    file:write(line)
  end
  file:close()

  os.remove(packer_compiled)
end

function plugins.magic_compile()
  plugins.compile()
  plugins.convert_compile_file()
end

function plugins.auto_compile()
  local file = vim.fn.expand('%:p')
  if file:match(modules_dir) then
    plugins.clean()
    plugins.compile()
    plugins.convert_compile_file()
  end
end

function plugins.load_compile()
  if G.exists(compile_to_lua) then
    require('_compiled')
  else
    assert(
        'Missing packer compile file Run PackerCompile Or PackerInstall to fix')
  end
  vim.cmd [[command! PlugCompile lua require('core.pack').magic_compile()]]
  vim.cmd [[command! PlugInstall lua require('core.pack').install()]]
  vim.cmd [[command! PlugUpdate lua require('core.pack').update()]]
  vim.cmd [[command! PlugSync lua require('core.pack').sync()]]
  vim.cmd [[command! PlugClean lua require('core.pack').clean()]]
  vim.cmd [[autocmd User PlugComplete lua require('core.pack').magic_compile()]]
end

return plugins
