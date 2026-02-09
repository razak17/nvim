require('ar.config')
require('ar.globals')
require('ar.highlights')
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
-- Colors {{{1
------------------------------------------------------------------------------
vim.cmd.colorscheme('habamax')
local theming = require('ar.theming')
local hls = theming.generate_overrides({
  default = {
    { Normal = { bg = { from = 'Normal', alter = -0.3 } } },
    { NormalFloat = { bg = { from = 'Normal', alter = -0.5 } } },
    { StatusLine = { bg = 'NONE' } },
    {
      Visual = {
        bg = { from = 'Visual', alter = 0.5 },
        fg = 'NONE',
        reverse = false,
      },
    },
    { Dim = { link = 'NonText' } },
    { WinSeparator = { fg = { from = 'Dim', alter = -0.2 } } },
    {
      SpellBad = {
        sp = { from = 'DiffAdd', attr = 'fg', alter = -0.1 },
        reverse = false,
      },
    },
    {
      IncSearch = {
        inherit = 'IncSearch',
        bg = { from = 'IncSearch', attr = 'fg' },
        fg = { from = 'IncSearch', attr = 'bg' },
        reverse = false,
      },
    },
    {
      DiffAdd = {
        bg = { from = 'Added', attr = 'fg', alter = -0.65 },
        fg = { from = 'Added' },
        reverse = false,
      },
    },
    {
      DiffChange = {
        fg = { from = 'DiffText', attr = 'bg', alter = 1.2 },
        reverse = false,
      },
    },
    {
      DiffDelete = {
        bg = { from = 'Removed', attr = 'fg', alter = -0.55 },
        fg = { from = 'Removed' },
        reverse = false,
      },
    },
  },
})
ar.highlight.all(hls)
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
local config = vim.fn.stdpath('config')
vim.opt.rtp:remove(config)
vim.opt.rtp:remove(config .. '/after')
vim.opt.packpath:remove(config)

require('lazy').setup({
  spec = {
    {
      'folke/snacks.nvim',
      priority = 1000,
      lazy = false,
      opts = {
        picker = {
          layouts = {
            telescope = { reverse = false },
          },
        },
      },
      keys = {
        {
          '<leader>fl',
          function() Snacks.picker.lazy() end,
          desc = 'Search for Plugin Spec',
        },
        {
          '<leader>fs',
          function() Snacks.picker.grep() end,
          desc = 'grep files',
        },
        {
          '<C-p>',
          function()
            Snacks.picker.files({
              matcher = {
                cwd_bonus = true, -- boost cwd matches
                frecency = true, -- use frecency boosting
                sort_empty = true, -- sort even when the filter is empty
              },
              finder = 'files',
              format = 'file',
              show_empty = true,
              supports_live = true,
              layout = 'telescope',
              -- stylua: ignore start
            args = {
              '--exclude', '**/.git/**',
              '--exclude', '**/.next/**',
              '--exclude', '**/node_modules/**',
              '--exclude', '**/build/**',
              '--exclude', '**/tmp/**',
              '--exclude', '**/env/**',
              '--exclude', '**/__pycache__/**',
              '--exclude', '**/.mypy_cache/**',
              '--exclude', '**/.pytest_cache/**',
            },
            })
          end,
          desc = 'Find Files',
        },
      },
    },
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
  performance = { rtp = { reset = false } },
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
