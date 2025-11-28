local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border.default
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties
local enabled = not minimal and ar.lsp.enable

return {
  ------------------------------------------------------------------------------
  -- Filetype Plugins {{{1
  ------------------------------------------------------------------------------
  {
    'razak17/slides.nvim',
    ft = 'slide',
    cond = function() return ar.get_plugin_cond('slides.nvim') end,
  },
  {
    'fladson/vim-kitty',
    ft = 'kitty',
    cond = function() return ar.get_plugin_cond('vim-kitty') end,
  },
  {
    'raimon49/requirements.txt.vim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('requirements.txt.vim', condition)
    end,
    lazy = false,
  },
  {
    'gennaro-tedesco/nvim-jqx',
    cond = function() return ar.get_plugin_cond('nvim-jqx', not minimal) end,
    ft = { 'json', 'yaml' },
  },
  -- Web Dev (Typescript)
  --------------------------------------------------------------------------------
  {
    'brianhuster/live-preview.nvim',
    cmd = { 'LivePreview' },
    cond = function() return ar.get_plugin_cond('live-preview') end,
  },
  {
    'Redoxahmii/json-to-types.nvim',
    cond = function()
      return ar.get_plugin_cond('json-to-types.nvim', not minimal)
    end,
    build = 'sh install.sh npm',
    init = function()
      vim.g.whichkey_add_spec({ '<leader><leader>t', group = 'JSON to types' })
    end,
    keys = {
      {
        '<leader><leader>tu',
        '<Cmd>ConvertJSONtoLang typescript<CR>',
        desc = 'Convert JSON to TS',
      },
      {
        '<leader><leader>tt',
        '<Cmd>ConvertJSONtoLangBuffer typescript<CR>',
        desc = 'Convert JSON to TS in buffer',
      },
    },
  },
  {
    'midoBB/nvim-quicktype',
    cond = function() return ar.get_plugin_cond('nvim-quicktype', not minimal) end,
    cmd = 'QuickType',
    build = 'npm install -g quicktype',
    ft = {
      'typescript',
      'python',
      'java',
      'go',
      'rust',
      'cs',
      'swift',
      'elixir',
      'kotlin',
      'typescriptreact',
    },
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Generate Types From JSON'] = function()
          if not ar.plugin_available('nvim-quicktype') then return end
          vim.cmd('QuickType')
        end,
      })
    end,
    opts = {},
  },
  {
    'razak17/package-info.nvim',
    cond = function()
      return ar.get_plugin_cond('package-info.nvim', not minimal)
    end,
    cmd = {
      'PackageInfoChangeVersion',
      'PackageInfoDelete',
      'PackageInfoHide',
      'PackageInfoInstall',
      'PackageInfoShow',
      'PackageInfoShowForce',
      'PackageInfoUpdate',
    },
    event = 'BufRead package.json',
    config = function()
      vim.g.whichkey_add_spec({ '<localleader>P', group = 'Package Info' })

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
    'bennypowers/template-literal-comments.nvim',
    cond = function()
      return ar.get_plugin_cond('template-literal-comments.nvim', not minimal)
    end,
    ft = { 'javascript', 'typescript' },
    opts = {},
  },
  {
    'jdrupal-dev/code-refactor.nvim',
    cond = function()
      return ar.get_plugin_cond('code-refactor.nvim', not minimal)
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>la', '<cmd>CodeActions all<CR>', desc = 'Show code-refactor.nvim (not LSP code actions)' },
    },
    opts = {},
  },
  {
    -- 'razak17/template-string.nvim',
    'axelvc/template-string.nvim',
    cond = function()
      return ar.get_plugin_cond('template-string.nvim', not minimal)
    end,
    cmd = { 'TemplateString' },
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Template String'] = 'TemplateString toggle',
      })
    end,
    ft = function()
      local fts = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'svelte',
      }
      if not ar.lsp.enable then table.insert(fts, 'python') end
      return fts
    end,
    opts = { remove_template_string = true },
  },
  {
    'joeldotdias/jsdoc-switch.nvim',
    cond = function()
      return ar.get_plugin_cond('jsdoc-switch.nvim', not minimal)
    end,
    -- ft = { 'javascript', 'javascriptreact' },
    init = function()
      vim.g.whichkey_add_spec({
        { '<leader><leader>J', group = 'jSdoc Switch' },
        { '<leader><leader>Jd', desc = 'doc switch' },
      })
    end,
    -- stylua: ignore
    keys = {
      { '<leader><leader>Jds', '<cmd>JsdocSwitchStart<CR>', desc = 'jsdoc-switch: start' },
      { '<leader><leader>Jdt', '<cmd>JsdocSwitchToggle<CR>', desc = 'jsdoc-switch: toggle' },
      { '<leader><leader>Jdn', '<cmd>JsdocSwitchStop<CR>', desc = 'jsdoc-switch: stop' },
    },
    opts = { auto_set_keys = false, notify = false },
  },
  {
    'hat0uma/prelive.nvim',
    cond = function() return ar.get_plugin_cond('prelive.nvim', not minimal) end,
    cmd = {
      'PreLiveGo',
      'PreLiveStatus',
      'PreLiveClose',
      'PreLiveCloseAll',
      'PreLiveLog',
    },
    opts = {},
  },
  {
    -- 'fabridamicelli/cronex.nvim',
    'razak17/cronex.nvim',
    cond = function() return ar.get_plugin_cond('cronex.nvim', not minimal) end,
    build = 'npm install -g cronstrue',
    cmd = {
      'CronExplainedEnable',
      'CronExplainedDisable',
      'CronExplainedToggle',
    },
    init = function()
      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle Cronex'] = 'CronExplainedToggle' }
      )
    end,
    opts = {
      file_patterns = {
        '*.yaml',
        '*.yml',
        '*.tf',
        '*.cfg',
        '*.config',
        '*.conf',
        '*.env',
      },
      highlight = 'DiagnosticVirtualTextInfo',
    },
  },
  {
    '2nthony/sortjson.nvim',
    cond = function() return ar.get_plugin_cond('sortjson.nvim') end,
    cmd = {
      'SortJSONByAlphaNum',
      'SortJSONByAlphaNumReverse',
      'SortJSONByKeyLength',
      'SortJSONByKeyLengthReverse',
    },
    opts = {},
  },
  {
    'razak17/stringbreaker.nvim',
    cond = function() return ar.get_plugin_cond('stringbreaker.nvim') end,
    cmd = { 'BreakString', 'SaveString' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function() require('string-breaker').setup() end,
  },
  {
    'AndrewRadev/inline_edit.vim',
    cond = function() return ar.get_plugin_cond('inline_edit.nvim') end,
    cmd = { 'InlineEdit' },
  },
  {
    'Kenzo-Wada/boundary.nvim',
    cond = function() return ar.get_plugin_cond('boundary.nvim', not minimal) end,
    cmd = { 'BoundaryRefresh' },
    ft = { 'javascriptreact', 'typescriptreact' },
    opts = {},
  },
  -- Python
  --------------------------------------------------------------------------------
  {
    'linux-cultist/venv-selector.nvim',
    cond = function() return ar.get_plugin_cond('venv-selector.nvim', enabled) end,
    branch = 'regexp', -- This is the regexp branch, use this for the new version
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Venv Selector: select env'] = 'VenvSelect',
        ['Venv Selector: select cached env'] = 'VenvSelectCached',
      })
    end,
    cmd = 'VenvSelect',
    opts = {
      name = { 'venv', '.venv', 'env', '.env' },
    },
  },
  {
    'alexpasmantier/pymple.nvim',
    cond = function() return ar.get_plugin_cond('pymple.nvim', enabled) end,
    build = ':PympleBuild',
    ft = { 'python' },
    opts = {
      resolve_import_under_cursor = {
        desc = 'resolve import under cursor',
        keys = '<localleader>li',
      },
      python = {
        root_markers = { 'pyproject.toml', 'setup.py', '.git', 'manage.py' },
        virtual_env_names = { 'env' },
      },
      keymaps = {
        resolve_import_under_cursor = {
          desc = 'resolve import under cursor',
          keys = '<localleader>li',
        },
      },
    },
  },
  -- Golang
  --------------------------------------------------------------------------------
  {
    'olexsmir/gopher.nvim',
    cond = function()
      local condition = ar.lsp.enable and not minimal
      return ar.get_plugin_cond('gopher.nvim', condition)
    end,
    ft = 'go',
  },
  {
    'jack-rabe/impl.nvim',
    cond = function()
      local cond = not ar.plugin_disabled('telescope.nvim') and not minimal
      return ar.get_plugin_cond('impl.nvim', cond)
    end,
    ft = 'go',
    cmd = { 'ImplGenerate', 'ImplSearch' },
    opts = {},
  },
  {
    'fredrikaverpil/godoc.nvim',
    cond = function() return ar.get_plugin_cond('godoc.nvim') end,
    cmd = { 'GoDoc' }, -- optional
    version = '*',
    build = 'go install github.com/lotusirous/gostdsym/stdsym@latest', -- optional
    opts = {}, -- see further down below for configuration
  },
  -- CSV
  --------------------------------------------------------------------------------
  {
    'vidocqh/data-viewer.nvim',
    cond = function()
      return ar.get_plugin_cond('data-viewer.nvim', not minimal)
    end,
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
    cond = function() return ar.get_plugin_cond('decisive.nvim', not minimal) end,
    ft = { 'csv' },
    keys = {
      {
        '<localleader>ci',
        "<Cmd>lua require('decisive').align_csv({})<CR>",
        desc = 'align CSV',
      },
      {
        '<localleader>cx',
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
  {
    'hat0uma/csvview.nvim',
    cond = function() return ar.get_plugin_cond('csvview.nvim') end,
    cmd = { 'CsvViewToggle', 'CsvViewEnable', 'CsvViewDisable' },
    config = function() require('csvview').setup() end,
  },
  -- Regex
  --------------------------------------------------------------------------------
  {
    'bennypowers/nvim-regexplainer',
    cond = function()
      return ar.get_plugin_cond('nvim-regexplainer', not minimal)
    end,
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
    desc = 'A Neovim plugin that provides an explanation for regular expressions.',
    'tomiis4/Hypersonic.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('Hypersonic.nvim', condition)
    end,
    event = 'CmdlineEnter',
    cmd = { 'Hypersonic' },
    opts = { border = border },
  },
  -- }}}
  -- Typst
  --------------------------------------------------------------------------------
  {
    'chomosuke/typst-preview.nvim',
    ft = 'typst',
    cond = function() return ar.get_plugin_cond('typst-preview') end,
    cmd = { 'TypstPreview', 'TypstPreviewToggle', 'TypstPreviewUpdate' },
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Syntax {{{1
  ------------------------------------------------------------------------------
  {
    'psliwka/vim-dirtytalk',
    cond = function() return ar.get_plugin_cond('vim-dirtytalk', not minimal) end,
    event = { 'BufRead' },
    build = ':DirtytalkUpdate',
    init = function() vim.opt.spelllang:prepend('programming') end,
  },
  ---}}}
}
