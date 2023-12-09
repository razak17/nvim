local ui, highlight = rvim.ui, rvim.highlight
local border = ui.current.border

return {
  ------------------------------------------------------------------------------
  -- Filetype Plugins {{{1
  ------------------------------------------------------------------------------
  { 'razak17/slides.nvim', ft = 'slide' },
  { 'fladson/vim-kitty', ft = 'kitty' },
  { 'raimon49/requirements.txt.vim', lazy = false },
  { 'gennaro-tedesco/nvim-jqx', ft = { 'json', 'yaml' } },
  -- Web Dev (Typescript)
  --------------------------------------------------------------------------------
  {
    'razak17/package-info.nvim',
    cond = not rvim.plugins.minimal,
    event = 'BufRead package.json',
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      highlight.plugin('package-info', {
        theme = {
          -- stylua: ignore
          ['onedark'] = {
            { PackageInfoUpToDateVersion = { link = 'DiagnosticVirtualTextInfo', }, },
            { PackageInfoOutdatedVersion = { link = 'DiagnosticVirtualTextWarn', }, },
          },
        },
      })
      require('package-info').setup({
        autostart = false,
        hide_up_to_date = true,
      })
    end,
  },
  {
    'bennypowers/template-literal-comments.nvim',
    cond = rvim.treesitter.enable,
    ft = { 'javascript', 'typescript' },
    opts = {},
  },
  {
    'llllvvuu/nvim-js-actions',
    cond = rvim.treesitter.enable,
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'axelvc/template-string.nvim',
    cond = rvim.treesitter.enable,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'svelte',
      'python',
    },
    opts = { remove_template_string = true },
  },
  {
    'turbio/bracey.vim',
    cond = not rvim.plugins.minimal,
    ft = 'html',
    build = 'npm install --prefix server',
  },
  {
    'NTBBloodbath/rest.nvim',
    cond = not rvim.plugins.minimal,
    ft = { 'http', 'json' },
    -- stylua: ignore
    keys = {
      { '<localleader>rs', '<Plug>RestNvim', desc = 'rest: run', buffer = 0 },
      { '<localleader>rp', '<Plug>RestNvimPreview', desc = 'rest: preview', buffer = 0, },
      { '<localleader>rl', '<Plug>RestNvimLast', desc = 'rest: run last', buffer = 0, },
    },
    opts = { skip_ssl_verification = true },
  },
  -- Tailwind
  --------------------------------------------------------------------------------
  {
    'razak17/tailwind-fold.nvim',
    cond = false,
    opts = { min_chars = 2 },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { 'html', 'svelte', 'astro', 'vue', 'typescriptreact' },
  },
  {
    'MaximilianLloyd/tw-values.nvim',
    cond = rvim.treesitter.enable and rvim.lsp.enable,
    -- stylua: ignore
    keys = {
      { '<localleader>lt', '<cmd>TWValues<cr>', desc = 'tw-values: show values', },
    },
    opts = { border = border, show_unknown_classes = true },
  },
  -- Python
  --------------------------------------------------------------------------------
  {
    'roobert/f-string-toggle.nvim',
    cond = rvim.treesitter.enable and false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = { 'python' },
    opts = {
      key_binding = '<localleader>ls',
    },
  },
  {
    'linux-cultist/venv-selector.nvim',
    cmd = 'VenvSelect',
    opts = {
      name = { 'venv', '.venv', 'env', '.env' },
    },
    keys = {
      { '<localleader>le', '<cmd>:VenvSelect<cr>', desc = 'Select VirtualEnv' },
    },
  },
  -- Golang
  --------------------------------------------------------------------------------
  {
    'olexsmir/gopher.nvim',
    cond = rvim.lsp.enable and not rvim.plugins.minimal,
    ft = 'go',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  },
  -- Markdown
  --------------------------------------------------------------------------------
  {
    'ellisonleao/glow.nvim',
    cond = not rvim.plugins.minimal,
    cmd = 'Glow',
    -- ft = 'markdown',
    opts = {
      border = 'single',
      width = 120,
    },
  },
  {
    'wallpants/github-preview.nvim',
    cond = not rvim.plugins.minimal,
    -- ft = 'markdown',
    cmd = {
      'GithubPreviewStart',
      'GithubPreviewStop',
      'GithubPreviewToggle',
    },
    opts = {},
  },
  -- https://github.com/AntonVanAssche/md-headers.nvim
  {
    'AntonVanAssche/md-headers.nvim',
    cond = rvim.treesitter.enable,
    -- ft = 'markdown',
    cmd = { 'MarkdownHeaders', 'MarkdownHeadersClosest' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- stylua: ignore
    keys = {
      { '<localleader>mh', '<cmd>MarkdownHeaders<CR>', desc = 'md-header: headers', },
      { '<localleader>mn', '<cmd>MarkdownHeadersClosest<CR>', desc = 'md-header: closest', },
    },
    opts = { borderchars = ui.border.common },
    config = function(_, opts)
      highlight.plugin('md-headers', {
        { MarkdownHeadersBorder = { inherit = 'FloatBorder' } },
        { MarkdownHeadersTitle = { inherit = 'FloatTitle' } },
      })
      require('md-headers').setup(opts)
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cond = not rvim.plugins.minimal,
    build = function() vim.fn['mkdp#util#install']() end,
    cmd = {
      'MarkdownPreview',
      'MarkdownPreviewStop',
      'MarkdownPreviewToggle',
    },
    -- ft = 'markdown',
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    'AckslD/nvim-FeMaco.lua',
    cmd = { 'FeMaco' },
    opts = {
      float_opts = function(code_block)
        local clip_val = require('femaco.utils').clip_val
        return {
          relative = 'cursor',
          width = clip_val(5, 120, vim.api.nvim_win_get_width(0) - 10),
          height = clip_val(
            5,
            #code_block.lines,
            vim.api.nvim_win_get_height(0) - 6
          ),
          anchor = 'NW',
          row = 0,
          col = 0,
          style = 'minimal',
          border = ui.current.border,
          zindex = 1,
        }
      end,
    },
  },
  {
    'nfrid/markdown-togglecheck',
    -- ft = { 'markdown' },
    -- stylua: ignore
    keys = {
      { '<leader>om', function() require('markdown-togglecheck').toggle() end, desc = 'toggle markdown checkbox', },
    },
    dependencies = { 'nfrid/treesitter-utils' },
  },
  {
    'NFrid/due.nvim',
    -- ft = { 'markdown' },
    -- stylua: ignore
    keys = {
      { '<localleader>mc', function() require('due_nvim').draw(0) end, desc = 'due: mode', },
      { '<localleader>md', function() require('due_nvim').clean(0) end, desc = 'due: clean', },
      { '<localleader>mr', function() require('due_nvim').redraw(0) end, desc = 'due: redraw', },
      { '<localleader>mu', function() require('due_nvim').async_update(0) end, desc = 'due: async update', },
    },
    opts = {
      prescript = 'due: ', -- prescript to due data
      prescript_hi = 'Comment', -- highlight group of it
      due_hi = 'String', -- highlight group of the data itself
      ft = '*.md', -- filename template to apply aucmds :)
      today = 'TODAY', -- text for today's due
      today_hi = 'Character', -- highlight group of today's due
      overdue = 'OVERDUE', -- text for overdued
      overdue_hi = 'Error', -- highlight group of overdued
      date_hi = 'Conceal', -- highlight group of date string
      -- NOTE: needed for more complex patterns (e.g orgmode dates)
      pattern_start = '', -- start for a date string pattern
      pattern_end = '', -- end for a date string pattern
      regex_hi = [[\d*-*\d\+-\d\+\( \d*:\d*\( \a\a\)\?\)\?]],
      use_clock_time = false, -- display also hours and minutes
      use_clock_today = false, -- do it instead of TODAY
      use_seconds = false, -- if use_clock_time == true, display seconds
      default_due_time = 'midnight', -- if use_clock_time == true, calculate time
    },
    config = function(_, opts)
      local date_pattern = [[(%d%d)%-(%d%d)]]
      local datetime_pattern = date_pattern .. ' (%d+):(%d%d)' -- m, d, h, min
      local fulldatetime_pattern = '(%d%d%d%d)%-' .. datetime_pattern -- y, m, d, h, min

      vim.o.foldlevel = 99

      vim.tbl_deep_extend('force', opts, {
        date_pattern = date_pattern, -- m, d
        datetime_pattern = datetime_pattern, -- m, d, h, min
        datetime12_pattern = datetime_pattern .. ' (%a%a)', -- m, d, h, min, am/pm
        fulldatetime_pattern = fulldatetime_pattern, -- y, m, d, h, min
        fulldatetime12_pattern = fulldatetime_pattern .. ' (%a%a)', -- y, m, d, h, min, am/pm
        fulldate_pattern = '(%d%d%d%d)%-' .. date_pattern, -- y, m, d
      })

      require('due_nvim').setup(opts)
    end,
  },
  {
    'Zeioth/markmap.nvim',
    -- ft = { 'markdown' },
    build = 'yarn global add markmap-cli',
    cmd = { 'MarkmapOpen', 'MarkmapSave', 'MarkmapWatch', 'MarkmapWatchStop' },
    opts = {},
  },
  {
    '3rd/image.nvim',
    cond = not rvim.plugins.minimal and rvim.plugins.niceties,
    ft = { 'markdown', 'vimwiki' },
    opts = {
      backend = 'kitty',
      max_width = 50,
      max_height = 50,
      integrations = {
        markdown = {
          only_render_image_at_cursor = true,
        },
      },
    },
  },
  -- CSV
  --------------------------------------------------------------------------------
  {
    'vidocqh/data-viewer.nvim',
    -- ft = { 'csv', 'tsv', 'sqlite' },
    cmd = { 'DataViewer', 'DataViewerClose' },
    opts = {},
    config = function(_, opts)
      highlight.plugin('data-viewer', {
        theme = {
          ['onedark'] = {
            { DataViewerColumn0 = { link = 'Keyword' } },
            { DataViewerColumn1 = { link = 'String' } },
            { DataViewerColumn2 = { link = 'Function' } },
          },
        },
      })
      require('data-viewer').setup(opts)
    end,
    dependencies = { 'nvim-lua/plenary.nvim', 'kkharji/sqlite.lua' },
  },
  -- Regex
  --------------------------------------------------------------------------------
  {
    'bennypowers/nvim-regexplainer',
    keys = {
      {
        '<localleader>rx',
        '<Cmd>RegexplainerToggle<CR>',
        desc = 'regexplainer: toggle',
      },
    },
    opts = {
      display = 'popup',
      popup = {
        border = {
          padding = { 1, 2 },
          style = border,
        },
      },
    },
  },
  {
    'tomiis4/Hypersonic.nvim',
    cond = not rvim.plugins.minimal and rvim.plugins.niceties,
    event = 'CmdlineEnter',
    cmd = 'Hypersonic',
    keys = {
      {
        mode = 'v',
        '<localleader>rx',
        '<Cmd>Hypersonic<CR>',
        desc = 'hypersonic: toggle',
      },
    },
    opts = { border = border },
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Syntax {{{1
  ------------------------------------------------------------------------------
  {
    'psliwka/vim-dirtytalk',
    cond = not rvim.plugins.minimal,
    lazy = false,
    build = ':DirtytalkUpdate',
    init = function() vim.opt.spelllang:append('programming') end,
  },
  ---}}}
}
