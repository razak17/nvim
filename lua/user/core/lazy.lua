local fn = vim.fn
local lazy = nil

local Lazy = {}
Lazy.__index = Lazy

function Lazy:load_plugins()
  self.repos = {}

  local function get_plugins_list()
    local list = {}
    local modules_dir = join_paths(rvim.get_user_dir(), 'modules')
    local tmp = vim.split(fn.globpath(modules_dir, '*/plugins.lua'), '\n')
    for _, f in ipairs(tmp) do
      list[#list + 1] = string.match(f, 'lua/(.+).lua$')
    end
    return list
  end

  local plugins = get_plugins_list()

  for _, m in ipairs(plugins) do
    local repos = require(m)
    self.repos[#self.repos + 1] = vim.tbl_extend('force', self.repos, repos)
  end
end

function Lazy:bootstrap_lazy()
  Lazy:load_plugins()
  if not lazy then lazy = require('lazy') end
  local lazy_opts = {
    root = join_paths(rvim.get_runtime_dir(), 'site/lazy'),
    defaults = { lazy = true },
    lockfile = join_paths(rvim.get_config_dir(), 'lazy-lock.json'),
    git = { timeout = 720 },
    dev = {
      path = join_paths(vim.env.HOME, 'personal/workspace/coding/plugins'),
      patterns = { 'razak17' },
    },
    install = { colorscheme = { 'zephyr', 'habamax' } },
    ui = { border = 'single' },
    performance = {
      enabled = true,
      cache = { path = join_paths(rvim.get_cache_dir(), 'lazy/cache') },
      rtp = { reset = false },
    },
    readme = { root = join_paths(rvim.get_cache_dir(), 'lazy/readme') },
  }
  lazy.setup(self.repos, lazy_opts)
end

function Lazy:init_ensure_installed()
  local lazy_path = join_paths(rvim.get_runtime_dir(), 'site/lazy/lazy.nvim')
  if not vim.loop.fs_stat(lazy_path) then
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      '--single-branch',
      'https://github.com/folke/lazy.nvim.git',
      lazy_path,
    })
  end
  vim.opt.rtp:prepend(lazy_path)
  self:bootstrap_lazy()
  rvim.nnoremap('<leader>Ll', '<cmd>Lazy<CR>', 'lazygit: toggle ui')
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not lazy then Lazy:bootstrap_lazy() end
    return lazy[key]
  end,
})

function plugins.ensure_plugins() Lazy:init_ensure_installed() end

return plugins
