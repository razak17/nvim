local ui, highlight = rvim.ui, rvim.highlight
local border = ui.current.border
local minimal, niceties = rvim.plugins.minimal, rvim.plugins.niceties

return {
  ------------------------------------------------------------------------------
  -- Filetype Plugins {{{1
  ------------------------------------------------------------------------------
  { 'razak17/slides.nvim', ft = 'slide' },
  { 'fladson/vim-kitty', ft = 'kitty' },
  {
    'raimon49/requirements.txt.vim',
    cond = not minimal and niceties,
    lazy = false,
  },
  { 'gennaro-tedesco/nvim-jqx', ft = { 'json', 'yaml' } },
  -- Web Dev (Typescript)
  --------------------------------------------------------------------------------
  {
    'Redoxahmii/json-to-types.nvim',
    build = 'sh install.sh npm',
    keys = {
      {
        '<leader>tju',
        '<Cmd>ConvertJSONtoLang typescript<CR>',
        desc = 'Convert JSON to TS',
      },
      {
        '<leader>tjt',
        '<Cmd>ConvertJSONtoLangBuffer typescript<CR>',
        desc = 'Convert JSON to TS in buffer',
      },
    },
  },
  {
    'razak17/package-info.nvim',
    cond = not minimal and false,
    event = 'BufRead package.json',
    config = function()
      require('which-key').register({
        ['<localleader>'] = { p = 'Package Info' },
      })

      highlight.plugin('package-info', {
        theme = {
          -- stylua: ignore
          ['onedark'] = {
            { PackageInfoUpToDateVersion = { link = 'DiagnosticVirtualTextInfo' } },
            { PackageInfoOutdatedVersion = { link = 'DiagnosticVirtualTextWarn' } },
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
    'jdrupal-dev/parcel.nvim',
    cond = not minimal,
    event = 'BufRead package.json',
    opts = {},
    dependencies = { 'phelipetls/jsonpath.nvim' },
  },
  {
    'bennypowers/template-literal-comments.nvim',
    ft = { 'javascript', 'typescript' },
    opts = {},
  },
  {
    'jdrupal-dev/code-refactor.nvim',
    -- stylua: ignore
    keys = {
      { '<localleader>la', '<cmd>CodeActions all<CR>', desc = 'Show code-refactor.nvim (not LSP code actions)' },
    },
    opts = {},
  },
  {
    'axelvc/template-string.nvim',
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
    'joeldotdias/jsdoc-switch.nvim',
    -- ft = { 'javascript', 'javascriptreact' },
    -- stylua: ignore
    keys = {
      { '<leader><leader>jds', '<cmd>JsdocSwitchStart<CR>', desc = 'jsdoc-switch: start' },
      { '<leader><leader>jdt', '<cmd>JsdocSwitchToggle<CR>', desc = 'jsdoc-switch: toggle' },
      { '<leader><leader>jdn', '<cmd>JsdocSwitchStop<CR>', desc = 'jsdoc-switch: stop' },
    },
    opts = { auto_set_keys = false, notify = false },
  },
  {
    'turbio/bracey.vim',
    cond = not minimal and false,
    ft = 'html',
    build = 'npm install --prefix server',
  },
  {
    'Diogo-ss/five-server.nvim',
    cmd = { 'FiveServer' },
    build = function() require('fs.utils.install')() end,
    opts = {
      notify = true,
      bin = 'five-server',
    },
    config = function(_, opts) require('fs').setup(opts) end,
  },
  {
    'rest-nvim/rest.nvim',
    cond = not minimal and false, -- archived
    ft = { 'http', 'json' },
    init = function()
      require('which-key').register({ ['<leader>rr'] = { name = 'Rest' } })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>rrs', '<Plug>RestNvim', desc = 'rest: run', buffer = 0 },
      { '<leader>rrp', '<Plug>RestNvimPreview', desc = 'rest: preview', buffer = 0, },
      { '<leader>rrl', '<Plug>RestNvimLast', desc = 'rest: run last', buffer = 0, },
    },
    opts = { skip_ssl_verification = true },
    config = function(_, opts) require('rest-nvim').setup(opts) end,
    dependencies = {
      { 'vhyrro/luarocks.nvim', opts = {} },
    },
  },
  -- Tailwind
  --------------------------------------------------------------------------------
  {
    'razak17/tailwind-fold.nvim',
    opts = { min_chars = 5 },
    ft = {
      'html',
      'svelte',
      'astro',
      'vue',
      'typescriptreact',
      'php',
      'blade',
      'eruby'
    },
  },
  {
    'MaximilianLloyd/tw-values.nvim',
    cond = rvim.lsp.enable,
    -- stylua: ignore
    keys = {
      { '<localleader>lt', '<cmd>TWValues<cr>', desc = 'tw-values: show values', },
    },
    opts = { border = border, show_unknown_classes = true },
  },
  {
    'luckasRanarison/tailwind-tools.nvim',
    cond = rvim.lsp.enable and false,
    ft = { 'html', 'svelte', 'astro', 'vue', 'typescriptreact', 'php', 'blade' },
    event = { 'BufRead' },
    cmd = {
      'TailwindConcealToggle',
      'TailwindColorToggle',
      'TailwindSort',
      'TailwindSortSelection',
    },
    opts = {
      document_color = { enabled = true, inline_symbol = '󰝤 ' },
      conceal = { enabled = true, symbol = '󱏿' },
      custom_filetypes = {},
    },
  },
  -- Python
  --------------------------------------------------------------------------------
  {
    'roobert/f-string-toggle.nvim',
    cond = false,
    ft = { 'python' },
    opts = {
      key_binding = '<localleader>ls',
    },
  },
  {
    'linux-cultist/venv-selector.nvim',
    init = function()
      require('which-key').register({
        ['<localleader>lv'] = { name = 'Venv Selector' },
      })
    end,
    cond = rvim.lsp.enable,
    cmd = 'VenvSelect',
    opts = {
      name = { 'venv', '.venv', 'env', '.env' },
    },
    -- stylua: ignore
    keys = {
      { '<localleader>lvo', '<Cmd>VenvSelect<cr>', desc = 'venv-selector: select env' },
      { '<localleader>lvc', '<Cmd>VenvSelectCached<cr>', desc = 'venv-selector: select cached env' },
    },
  },
  -- Golang
  --------------------------------------------------------------------------------
  {
    'olexsmir/gopher.nvim',
    init = function()
      require('which-key').register({
        ['<localleader>g'] = { name = 'Gopher' },
      })
    end,
    cond = rvim.lsp.enable and not minimal,
    ft = 'go',
  },
  -- Markdown
  --------------------------------------------------------------------------------
  {
    'ellisonleao/glow.nvim',
    cond = not minimal,
    cmd = 'Glow',
    opts = {
      border = 'single',
      width = 120,
    },
  },
  {
    'wallpants/github-preview.nvim',
    cond = not minimal,
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
    cmd = { 'MarkdownHeaders', 'MarkdownHeadersClosest' },
    -- stylua: ignore
    keys = {
      { '<localleader>mh', '<cmd>MarkdownHeaders<CR>', desc = 'md-header: headers', },
      { '<localleader>mn', '<cmd>MarkdownHeadersClosest<CR>', desc = 'md-header: closest', },
    },
    opts = { borderchars = ui.border.common },
    config = function(_, opts)
      highlight.plugin('md-headers', {
        theme = {
          ['onedark'] = {
            { MarkdownHeadersBorder = { inherit = 'FloatBorder' } },
            { MarkdownHeadersTitle = { inherit = 'FloatTitle' } },
          },
        },
      })
      require('md-headers').setup(opts)
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cond = not minimal,
    build = function() vim.fn['mkdp#util#install']() end,
    cmd = {
      'MarkdownPreview',
      'MarkdownPreviewStop',
      'MarkdownPreviewToggle',
    },
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
    build = 'yarn global add markmap-cli',
    cmd = { 'MarkmapOpen', 'MarkmapSave', 'MarkmapWatch', 'MarkmapWatchStop' },
    opts = {},
  },
  {
    '3rd/image.nvim',
    cond = not minimal and niceties,
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
  {
    'https://git.sr.ht/~swaits/thethethe.nvim',
    cond = not minimal and niceties and false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'HakonHarnes/img-clip.nvim',
    cmd = { 'PasteImage' },
    opts = {},
  },
  {
    'MeanderingProgrammer/markdown.nvim',
    cond = niceties,
    name = 'render-markdown',
    cmd = { 'RenderMarkdownToggle' },
    ft = { 'markdown' },
    init = function()
      highlight.plugin('render-markdown', {
        theme = {
          ['onedark'] = { { MarkdownCodeBlock = { link = 'CodeBlock' } } },
        },
      })
    end,
    opts = {
      start_enabled = false,
      highlights = {
        code = 'MarkdownCodeBlock',
        heading = {
          backgrounds = { 'Headline1', 'Headline2', 'Headline3' },
          foregrounds = {
            'markdownH1',
            'markdownH2',
            'markdownH3',
            'markdownH4',
            'markdownH5',
            'markdownH6',
          },
        },
      },
      headings = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      checkbox = { unchecked = '󰄱', checked = '' },
      conceal = { rendered = 2 },
      bullets = { '●', '○', '▶', '▷' },
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
  },
  {
    'emmanueltouzery/decisive.nvim',
    ft = { 'csv' },
    keys = {
      {
        '<localleader>ci',
        "<Cmd>lua require('decisive').align_csv({})<CR>",
        desc = 'align CSV',
      },
      {
        '<localleader>cA',
        "<Cmd>lua require('decisive').align_csv_clear({})<CR>",
        desc = 'align CSV clear',
      },
      {
        '<localleader>cj',
        "<Cmd>lua require('decisive').align_csv_prev_col()<CR>",
        desc = 'align CSV prev col',
      },
      {
        '<localleader>caK',
        "<Cmd>lua require('decisive').align_csv_next_col()<CR>",
        desc = 'align CSV next col',
        silent = true,
      },
    },
  },
  -- Regex
  --------------------------------------------------------------------------------
  {
    'bennypowers/nvim-regexplainer',
    keys = {
      {
        '<leader>rx',
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
    cond = not minimal and niceties,
    event = 'CmdlineEnter',
    cmd = 'Hypersonic',
    keys = {
      {
        mode = 'v',
        '<localleader>rh',
        '<Cmd>HypersonichCR>',
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
    cond = not minimal and niceties,
    lazy = false,
    build = ':DirtytalkUpdate',
    init = function() vim.opt.spelllang:append('programming') end,
  },
  ---}}}
}
