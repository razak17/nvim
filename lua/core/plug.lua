local fn, uv, api = vim.fn, vim.loop, vim.api
local vim_path = require('core.global').vim_path
local data_dir = require('core.global').data_dir
local modules_dir = vim_path .. '/lua/modules'
local packer_compiled = data_dir .. 'packer_compiled.vim'
local compile_to_lua = data_dir .. 'lua/_compiled.lua'
local packer = nil

local Plug = {}
Plug.__index = Plug

function Plug:load_plugins()
  self.repos = {}

  local get_plugins_list = function()
    local list = {}
    local tmp = vim.split(fn.globpath(modules_dir, '*/plugins.lua'), '\n')
    for _, f in ipairs(tmp) do
      list[#list + 1] = f:sub(#modules_dir - 6, -1)
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

function Plug:load_packer()
  if not packer then
    api.nvim_command('packadd packer.nvim')
    packer = require('packer')
  end
  packer.init({
    compile_path = packer_compiled,
    git = {clone_timeout = 120},
    disable_commands = true
  })
  packer.reset()
  local use = packer.use
  self:load_plugins()
  use {"wbthomason/packer.nvim", opt = true}
  use 'tpope/vim-surround'
  use 'tpope/vim-fugitive'
  for _, repo in ipairs(self.repos) do
    use(repo)
  end
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then
      Plug:load_packer()
    end
    return packer[key]
  end
})

function Plug:init_ensure_plugins()
  local packer_dir = data_dir .. 'pack/packer/opt/packer.nvim'
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = "!git clone https://github.com/wbthomason/packer.nvim " ..
                    packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(data_dir .. 'lua', 511, function()
      assert("make compile path dir faield")
    end)
    self:load_packer()
    packer.install()
  end
end

function plugins.ensure_plugins()
  Plug:init_ensure_plugins()
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

  if vim.fn.isdirectory(data_dir .. 'lua') ~= 1 then
    os.execute('mkdir -p ' .. data_dir .. 'lua')
  end

  if vim.fn.filereadable(compile_to_lua) == 1 then
    os.remove(compile_to_lua)
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
  end
end

function plugins.load_compile()
  if vim.fn.filereadable(compile_to_lua) == 1 then
    require('_compiled')
  else
    plugins.magic_compile()
  end

  vim.cmd [[command! PlugCompile lua require('core.plug').magic_compile()]]
  vim.cmd [[command! PlugInstall lua require('core.plug').install()]]
  vim.cmd [[command! PlugUpdate lua require('core.plug').update()]]
  vim.cmd [[command! PlugSync lua require('core.plug').sync()]]
  vim.cmd [[command! PlugClean lua require('core.plug').clean()]]
  vim.cmd [[autocmd User PlugComplete lua require('core.plug').magic_compile()]]
end

return plugins

