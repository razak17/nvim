local G = require 'core.global'
local fn = vim.fn
local packer_compiled = G.local_nvim .. 'site/plugin/packges.vim'
local modules_dir = G.vim_path .. '/lua/modules'
local packer = nil

local Packer = {}
Packer.__index = Packer

function Packer:load_plugins()
  self.repos = {}

  local get_plugins_list = function ()
    local list = {}
    local tmp = vim.split(fn.globpath(modules_dir,'/*/plugins.lua'),'\n')
    for _,f in ipairs(tmp) do
      list[#list+1] = f:sub(#modules_dir - 7,-1)
    end
    return list
  end

  local plugins_file = get_plugins_list()
  for _,m in ipairs(plugins_file) do
    local repos = require(m:sub(0,#m-4))
    for repo,conf in pairs(repos) do
      self.repos[#self.repos+1] = vim.tbl_extend('force',{repo},conf)
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
    git = { clone_timeout = 120 },
    disable_commands = true,
    config = {
      display = {
        _open_fn = function(name)
          local ok, float_win = pcall(function()
            return require('plenary.window.float').percentage_range_window(0.8, 0.8)
          end)

          if not ok then
            vim.cmd [[65vnew  [packer] ]]
            return vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
          end

          local bufnr = float_win.buf
          local win = float_win.win

          vim.api.nvim_buf_set_name(bufnr, name)
          vim.api.nvim_win_set_option(win, 'winblend', 10)

          return win, bufnr
        end
      }
    }
  })

  local use = packer.use
  packer.reset()

  use {'wbthomason/packer.nvim', opt = true }
  use 'tpope/vim-surround'

  if vim.fn.exists('g:vscode') == 0 then
    self:load_plugins()
    for _,repo in ipairs(self.repos) do
      use(repo)
    end
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

function plugins.auto_compile()
  local file = vim.fn.expand('%:p')
  if file:match(modules_dir) then
    plugins.clean()
    plugins.compile()
  end
end

return plugins

