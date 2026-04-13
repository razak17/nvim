if not ar then return end

local enabled = ar.config.plugin.custom.baredot.enable

if ar.none or not enabled then return end

-- Ref: https://plugins.ejri.dev/baredot.nvim

ar.baredot = {
  enable = false,
  git_work_tree = '~',
  git_dir = '~/.dots/dotfiles',
}

local api, fn = vim.api, vim.fn

-- set/unset GIT_WORK_TREE and GIT_DIR environment variables
---@enable boolean whether to set or unset the environment variables
local function set_env(enable)
  local git_work_tree = nil
  local git_dir = nil
  if enable then
    git_work_tree = fn.expand(ar.baredot.git_work_tree)
    git_dir = fn.expand(ar.baredot.git_dir)
  end
    vim.env.GIT_WORK_TREE = git_work_tree
    vim.env.GIT_DIR = git_dir
end

ar.command('DotsEnvSet', function() set_env(true) end)
ar.command('DotsEnvUnSet', function() set_env(false) end)

-- resolve the active context from current buffer, with fallback to cwd for unnamed/URI buffers
---@bufnr integer|nil buffer number, defaults to current buffer
local function current_path(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local name = api.nvim_buf_get_name(bufnr)
  if name == '' or name:match('^%w+://') then return fn.getcwd() end
  local path = fn.fnamemodify(name, ':p:h')
  if path == '' then return fn.getcwd() end
  return path
end

-- detect nested paths inside repos
local function has_git_upwards(path)
  local found = vim.fs.find('.git/config', { upward = true, path = path })[1]
  return found ~= nil
end

local function update()
  local p = current_path()
  local has_git = has_git_upwards(p) or ar.has_git(p)
  ar.baredot.enable = not has_git and not ar.is_git_worktree(p)
  set_env(ar.baredot.enable)
end

vim.schedule(update)

ar.augroup('Baredot', {
  event = { 'DirChanged', 'BufDelete' },
  desc = 'Baredot: scan for .git',
  command = update,
})

local pending_buf = 0
ar.augroup('BaredotCursorHold', {
  event = { 'CursorHold' },
  command = function(arg)
    if pending_buf == arg.buf then return end
    pending_buf = arg.buf
    vim.schedule(update)
  end,
})
