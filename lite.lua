------------------------------------------------------------------------------
-- Options {{{1
------------------------------------------------------------------------------
vim.o.udir = vim.fn.stdpath('cache') .. '/undodir'
vim.o.viewdir = vim.fn.stdpath('cache') .. '/view'
vim.opt.formatoptions = {
  ['1'] = true,
  ['2'] = true, -- Use indent from 2nd line of a paragraph
  q = true, -- continue comments with gq"
  n = true, -- Recognize numbered lists
  t = false, -- autowrap lines using text width value
  j = true, -- remove a comment leader when joining lines.
  -- Only break if the line was not longer than 'textwidth' when the insert
  -- started and only at a white character that has been entered during the
  -- current insert command.
  l = true,
  v = true,
}
vim.opt.clipboard = { 'unnamedplus' }
vim.opt.iskeyword:append('-')
vim.o.wrap = false
vim.o.wrapmargin = 2
vim.o.textwidth = 0
vim.o.autoindent = true
vim.o.shiftround = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = -1
vim.o.cindent = true -- Increase indent on line after opening brace
vim.o.smartindent = true
------------------------------------------------------------------------------
-- Leader {{{1
------------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ','
------------------------------------------------------------------------------
-- Plugns {{{1
------------------------------------------------------------------------------
local api, fn = vim.api, vim.fn
local data = fn.stdpath('data')

local lazy_path = data .. '/lazy' .. '/lazy.nvim'
if not vim.uv.fs_stat(lazy_path) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  -- stylua: ignore start
  local out = vim.system({ 'git', 'clone', '--filter=blob:none', '--single-branch', lazyrepo, lazy_path }):wait().stdout
  -- stylua: ignore end
  if vim.v.shell_error ~= 0 then
    api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazy_path)

require('lazy').setup({
  spec = {
    {
      'kylesnowschwartz/prompt-tower.nvim',
      cmd = { 'PromptTower' },
      config = function()
        require('prompt-tower').setup({
          output_format = {
            default_format = 'markdown', -- Options: 'xml', 'markdown', 'minimal'
          },
        })
      end,
    },
  },
  defaults = { lazy = true },
  change_detection = { notify = false },
  git = { timeout = 720 },
  install = { colorscheme = { colorscheme, 'habamax' } },
  checker = {
    enabled = true,
    concurrency = 30,
    notify = false,
    frequency = 3600,
  },
})
