local uv, api, fn = vim.loop, vim.api, vim.fn
local fmt = string.format
local utils = require('user.utils.plugins')
local plug_notify = utils.plug_notify
local packer_compiled = rvim.paths.packer_compiled
local packer = nil

local Packer = {
  repos = {},
}
Packer.__index = Packer

function Packer:load_plugins()
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
    require(m)
  end
end

function Packer:bootstrap_packer()
  if not packer then
    vim.cmd.packadd({ 'packer.nvim', bang = true })
    packer = require('packer')
  end
  -- rvim.safe_require('impatient')
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
  Packer:load_plugins()
  packer.startup(function(use)
    use({ 'wbthomason/packer.nvim', opt = true })
    if rvim.plugins.SANE then
      for _, repo in ipairs(self.repos) do
        local local_path = repo.local_path
        if local_path then
          utils.use_local(repo)
        else
          use(repo)
        end
      end
    end
  end)
end

function Packer:init_ensure_installed()
  local packer_dir = rvim.get_runtime_dir() .. '/site/pack/packer/opt/packer.nvim'
  local state = uv.fs_stat(packer_dir)
  if state then
    self:bootstrap_packer()
    return
  end
  local cmd = '!git clone https://github.com/wbthomason/packer.nvim ' .. packer_dir
  api.nvim_command(cmd)
  uv.fs_mkdir(
    rvim.get_runtime_dir() .. '/site/lua',
    511,
    function() assert('could not create compile_path dir') end
  )
  self:bootstrap_packer()
  packer.sync()
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    if not packer then Packer:bootstrap_packer() end
    return packer[key]
  end,
})

function plugins.ensure_plugins()
  Packer:init_ensure_installed()

  if not vim.g.packer_compiled_loaded and vim.loop.fs_stat(packer_compiled) then
    vim.cmd.source(packer_compiled)
    vim.g.packer_compiled_loaded = true
  end
end

function plugins.del_compiled()
  if vim.fn.filereadable(packer_compiled) ~= 1 then
    plug_notify('packer_compiled file does not exist', 'info')
  else
    vim.fn.delete(packer_compiled)
    plug_notify('packer_compiled was deleted', 'info')
  end
end

function plugins.reload()
  plugins.install()
  plugins.compile()
  require('_compiled_rolling')
end

function plugins.invalidate()
  rvim.invalidate('user.modules', true)
  plugins.reload()
end

function plugins.recompile()
  rvim.invalidate(fmt('user.modules.%s', vim.split(vim.fn.expand('%'), '/')[4]), true)
  plugins.reload()
end

function plugins.package(repo) table.insert(Packer.repos, repo) end

function plugins.load_compile()
  if vim.fn.filereadable(packer_compiled) ~= 1 then plugins.compile() end

  rvim.augroup('PackerSetupInit', {
    {
      event = { 'BufWritePost' },
      desc = 'Packer setup and reload',
      pattern = { '*/user/modules/**/*.lua' },
      command = function()
        vim.cmd.doautocmd('LspDetach')
        plugins.recompile()
      end,
    },
    {
      event = { 'User' },
      pattern = { 'PackerCompileDone' },
      desc = 'Inform me that packer has finished compiling',
      command = function() plug_notify('Packer compile complete', 'info') end,
    },
  })
end

return plugins
