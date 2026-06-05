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
    { StatusLineNC = { bg = 'NONE' } },
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
-- Settings {{{1
------------------------------------------------------------------------------
local o, opt, fn = vim.o, vim.opt, vim.fn
o.udir = fn.stdpath('cache') .. '/undodir'
o.viewdir = fn.stdpath('cache') .. '/view'
o.backup = false
o.undofile = true
o.undolevels = 10000
o.swapfile = false
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
    {
      'olimorris/persisted.nvim',
      event = 'BufReadPre',
      cmd = { 'SessionLoad', 'SessionLoadLast', 'SessionSelect', 'SessionStop' },
      -- stylua: ignore
      keys = {
        { '<leader>ql', '<Cmd>Persisted load<CR>', desc = 'restore session', silent = true },
        { '<leader>qL', '<Cmd>Persisted load_last<CR>', desc = 'restore last session', silent = true },
        { '<leader>qo', '<Cmd>Persisted select<CR>', desc = 'list session', silent = true },
        { '<leader>qd', '<Cmd>Persisted stop<CR>', desc = "don't save current session", silent = true },
      },
      opts = {
        follow_cwd = true, -- Change the session file to match any change in the cwd?
        use_git_branch = true,
        save_dir = vim.fn.expand(vim.fn.stdpath('cache') .. '/sessions/'),
        on_autoload_no_session = function() vim.cmd.Alpha() end,
        should_save = function()
          return not vim.tbl_contains({ 'alpha', 'cheatsheet' }, vim.bo.ft)
            and not vim.tbl_contains({ 'nofile' }, vim.bo.bt)
        end,
      },
    },
    {
      'mason-org/mason.nvim',
      lazy = false,
      build = ':MasonUpdate',
      cmd = {
        'Mason',
        'MasonInstall',
        'MasonUninstall',
        'MasonUninstallAll',
        'MasonLog',
        'MasonUpdate',
      },
      opts = {
        registries = {
          'lua:mason-registry.index',
          'github:mason-org/mason-registry',
          'github:nvim-java/mason-registry',
        },
        providers = { 'mason.providers.registry-api', 'mason.providers.client' },
      },
    },
    {
      'williamboman/mason-lspconfig.nvim',
      event = { 'BufReadPre' },
      config = function()
        require('mason-lspconfig').setup({ automatic_enable = { 'lua_ls' } })
      end,
      dependencies = {
        'mason-org/mason.nvim',
        { 'neovim/nvim-lspconfig' },
      },
    },
    {
      'rachartier/tiny-cmdline.nvim',
      event = 'VeryLazy',
      lazy = false,
      config = function()
        vim.o.cmdheight = 0
        require('tiny-cmdline').setup()
      end,
    },
  },
  defaults = { lazy = true },
  performance = { rtp = { reset = false } },
  change_detection = { notify = false },
  git = { timeout = 720 },
  install = { colorscheme = { 'habamax' } },
  checker = {
    enabled = true,
    concurrency = 30,
    notify = false,
    frequency = 3600,
  },
})

vim.cmd('packadd nvim.undotree')

vim.keymap.set(
  'n',
  '<leader>uU',
  function()
    require('undotree').open({
      command = math.floor(vim.api.nvim_win_get_width(0) / 3) .. 'vnew',
    })
  end,
  { desc = 'undotree toggle' }
)

vim.lsp.config('lua_ls', {
  ---@type lspconfig.settings.lua_ls
  settings = {
    Lua = {
      codeLens = { enable = true },
      completion = { keywordSnippet = 'Replace', callSnippet = 'Replace' },
      diagnostics = {
        disable = {
          'cast-local-type',
          'incomplete-signature-doc',
          'lowercase-global',
          'missing-fields',
          'missing-parameter',
          'param-type-mismatch',
          'return-type-mismatch',
        },
        unusedLocalExclude = { '_*' },
        workspacedelay = -1,
      },
      format = { enable = false },
      hint = {
        enable = true,
        setType = false,
        paramType = true,
        paramName = 'Disable',
        semicolon = 'Disable',
        arrayIndex = 'Disable',
      },
      runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
      type = { castNumberToInteger = true, inferParamType = true },
      -- don't make workspace diagnostic, as it consumes too much cpu and ram
      workspace = {
        maxPreload = 100000,
        preloadFileSize = 10000,
        checkThirdParty = false,
        library = {
          fn.expand('$VIMRUNTIME/lua'),
          -- fn.expand('$VIMRUNTIME/lua/vim/lsp'),
          -- unpack(vim.api.nvim_list_runtime_paths()),
          -- unpack(vim.api.nvim_get_runtime_file('', true)),
        },
      },
    },
  },
})
