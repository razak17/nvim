local uv, api, fn = vim.loop, vim.api, vim.fn
local fmt = string.format

local M = {}
M.__index = M

function M:plug_notify(msg, level) vim.notify(msg, level, { title = 'Packer' }) end

function M:get_plugins_list()
  local list = {}
  local modules_dir = join_paths(rvim.get_user_dir(), 'modules')
  local tmp = vim.split(fn.globpath(modules_dir, '*/init.lua'), '\n')
  for _, f in ipairs(tmp) do
    list[#list + 1] = f:sub(#modules_dir - 6, -1)
  end
  return list
end

function M:load_plugins(plugins)
  self.repos = {}

  for _, m in ipairs(plugins) do
    local repos = require(join_paths('user', m:sub(0, #m - 4)))
    for repo, conf in pairs(repos) do
      self.repos[#self.repos + 1] = vim.tbl_extend('force', { repo }, conf)
    end
  end
end

function M:init_ensure_installed()
  local packer_dir = rvim.get_runtime_dir() .. '/site/pack/packer/opt/packer.nvim'
  local state = uv.fs_stat(packer_dir)
  if not state then
    local cmd = '!git clone https://github.com/wbthomason/packer.nvim ' .. packer_dir
    api.nvim_command(cmd)
    uv.fs_mkdir(
      rvim.get_runtime_dir() .. '/site/lua',
      511,
      function() assert('make compile path dir failed') end
    )
    self:load_packer()
    require('packer').sync()
  end
end

function M:bootstrap_packer(packer, plugins)
  packer.init({
    package_root = join_paths(rvim.get_runtime_dir(), 'site/pack/'),
    compile_path = rvim.paths.packer_compiled,
    git = {
      clone_timeout = 7000,
      subcommands = {
        -- this is more efficient than what Packer is using
        fetch = 'fetch --no-tags --no-recurse-submodules --update-shallow --progress',
      },
    },
    disable_commands = true,
    display = {
      open_fn = function()
        return require('packer.util').float({
          border = rvim.style.border.current,
        })
      end,
    },
  })
  packer.reset()
  M:load_plugins(plugins)
  packer.startup(function(use)
    use({ 'wbthomason/packer.nvim', opt = true })
    if rvim.plugins.SANE then
      for _, repo in ipairs(M.repos) do
        local local_spec = repo.local_path
        if local_spec then
          M:use_local(repo)
        else
          use(repo)
        end
      end
    end
  end)
end

---Some plugins are not safe to be reloaded because their setup functions
---are not idempotent. This wraps the setup calls of such plugins
---@param func fun()
function M.block_reload(func)
  if vim.g.packer_compiled_loaded then return end
  func()
end

---Require a plugin config
---@param dir string
---@param name string
---@return any
function M.load_conf(dir, name)
  local module_dir = fmt('user.modules.%s', dir)
  if dir == 'user' then return require(fmt(dir .. '.%s', name)) end

  return require(fmt(module_dir .. '.%s', name))
end

--- Automagically register local and remote plugins as well as managing when they are enabled or disabled
--- 1. Local plugins that I created should be used but specified with their git URLs so they are
--- installed from git on other machines
--- 2. If DEVELOPING is set to true then local plugins I contribute to should be loaded vs their
--- remote counterparts
---@param spec table
function M:with_local(spec)
  assert(type(spec) == 'table', fmt('spec must be a table', spec[1]))
  assert(spec.local_path, fmt('%s has no specified local path', spec[1]))

  local name = vim.split(spec[1], '/')[2]
  local path = M:dev(name)
  if fn.isdirectory(fn.expand(path)) < 1 then return spec, nil end
  local local_spec = {
    path,
    config = spec.config,
    setup = spec.setup,
    rocks = spec.rocks,
    opt = spec.local_opt,
    as = fmt('local-%s', name),
    disable = spec.disable,
  }

  spec.local_path = nil
  spec.local_cond = nil
  spec.local_disable = nil

  return spec, local_spec
end

---local variant of packer's use function that specifies both a local and
---upstream version of a plugin
---@param original table
function M:use_local(original)
  local use = require('packer').use
  local spec, local_spec = M:with_local(original)
  if local_spec then
    use(local_spec)
  else
    -- NOTE: Don't install from repo is local is available
    use(spec)
  end
end

function M.goto_repo()
  local repo = fn.expand('<cfile>')
  if repo:match('https://') then return vim.cmd('norm gx') end
  if not repo or #vim.split(repo, '/') ~= 2 then return vim.cmd('norm! gf') end
  local url = fmt('https://www.github.com/%s', repo)
  fn.system(fn.printf(rvim.open_command .. ' "https://github.com/%s"', repo))
  -- fn.jobstart(fmt('%s %s', vim.g.open_command, url))
  vim.notify(fmt('Opening %s at %s', repo, url))
end

---@param path string
function M:dev(path) return join_paths(vim.env.HOME, 'personal/workspace/coding/plugins', path) end

return M
