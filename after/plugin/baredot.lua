local enabled = ar_config.plugin.custom.baredot.enable

if not ar or ar.none or not enabled then return end

-- Ref: https://github.com/ejrichards/baredot.nvim

ar.baredot = {
  git_work_tree = '~',
  git_dir = '~/.dots/dotfiles',
}

local function set_env(enable)
  local git_work_tree = vim.fn.expand(ar.baredot.git_work_tree)
  local git_dir = vim.fn.expand(ar.baredot.git_dir)

  if enable then
    vim.env.GIT_WORK_TREE = git_work_tree
    vim.env.GIT_DIR = git_dir
  else
    vim.env.GIT_WORK_TREE = nil
    vim.env.GIT_DIR = nil
  end
end

if not ar.is_git_repo() then set_env(true) end

ar.augroup('BaredotLocal', {
  event = { 'DirChanged' },
  desc = 'Baredot: scan for .git',
  command = function()
    if vim.v.event.scope == 'global' then set_env(not ar.is_git_repo()) end
  end,
})
