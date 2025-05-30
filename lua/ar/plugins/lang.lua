local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

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
  {
    'gennaro-tedesco/nvim-jqx',
    cond = not minimal,
    ft = { 'json', 'yaml' },
  },
  -- Web Dev (Typescript)
  --------------------------------------------------------------------------------
  {
    'Redoxahmii/json-to-types.nvim',
    cond = not minimal,
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
    cond = not minimal,
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
    'jdrupal-dev/parcel.nvim',
    cond = not minimal and false,
    event = 'BufRead package.json',
    opts = {},
    dependencies = { 'phelipetls/jsonpath.nvim' },
  },
  {
    'razak17/package-info.nvim',
    cond = not minimal,
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
    cond = not minimal,
    ft = { 'javascript', 'typescript' },
    opts = {},
  },
  {
    'jdrupal-dev/code-refactor.nvim',
    cond = not minimal,
    -- stylua: ignore
    keys = {
      { '<localleader>la', '<cmd>CodeActions all<CR>', desc = 'Show code-refactor.nvim (not LSP code actions)' },
    },
    opts = {},
  },
  {
    -- 'razak17/template-string.nvim',
    'axelvc/template-string.nvim',
    cond = not minimal,
    cmd = { 'TemplateString' },
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Template String'] = 'TemplateString toggle',
      })
    end,
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
    'mawkler/jsx-element.nvim',
    cond = not minimal,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    ft = { 'typescriptreact', 'javascriptreact', 'javascript' },
    opts = {},
  },
  {
    'joeldotdias/jsdoc-switch.nvim',
    cond = not minimal,
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
    'Diogo-ss/five-server.nvim',
    cond = not minimal,
    cmd = { 'FiveServer' },
    build = function() require('fs.utils.install')() end,
    opts = {
      notify = true,
      bin = 'five-server',
    },
  },
  {
    -- 'fabridamicelli/cronex.nvim',
    'razak17/cronex.nvim',
    cond = not minimal,
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
    cmd = {
      'SortJSONByAlphaNum',
      'SortJSONByAlphaNumReverse',
      'SortJSONByKeyLength',
      'SortJSONByKeyLengthReverse',
    },
    opts = {},
  },
  -- Tailwind
  --------------------------------------------------------------------------------
  {
    'razak17/tailwind-fold.nvim',
    init = function()
      ar.add_to_select_menu('toggle', {
        ['Toggle Tailwind Fold'] = 'TailwindFoldToggle',
      })
    end,
    cmd = {
      'TailwindFoldToggle',
      'TailwindFoldEnable',
      'TailwindFoldDisable',
    },
    opts = { min_chars = 5, symbol = '󱏿' },
    ft = {
      'html',
      'clojure',
      'svelte',
      'astro',
      'vue',
      'typescriptreact',
      'javascriptreact',
      'php',
      'blade',
      'eruby',
      'htmlangular',
      'htmldjango',
      'templ',
      'cshtml',
      'razor',
    },
  },
  {
    'MaximilianLloyd/tw-values.nvim',
    cond = ar.lsp.enable,
    -- stylua: ignore
    keys = {
      { '<localleader>lt', '<Cmd>TWValues<cr>', desc = 'tw-values: show values', },
    },
    opts = { border = border, show_unknown_classes = true },
  },
  {
    'atiladefreitas/tinyunit',
    keys = {
      { '<leader>tu', desc = 'tinyunit: open', mode = { 'n', 'x' } },
    },
    opts = {
      keymap = {
        open = 'tu',
        close = 'q',
      },
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
    branch = 'regexp', -- This is the regexp branch, use this for the new version
    init = function()
      ar.add_to_select_menu('command_palette', {
        ['Venv Selector: select env'] = 'VenvSelect',
        ['Venv Selector: select cached env'] = 'VenvSelectCached',
      })
    end,
    cond = ar.lsp.enable,
    cmd = 'VenvSelect',
    opts = {
      name = { 'venv', '.venv', 'env', '.env' },
    },
  },
  {
    'alexpasmantier/pymple.nvim',
    build = ':PympleBuild',
    ft = { 'python' },
    cond = ar.lsp.enable,
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
    dependencies = { 'stevearc/dressing.nvim' },
  },
  -- Golang
  --------------------------------------------------------------------------------
  {
    'olexsmir/gopher.nvim',
    cond = ar.lsp.enable and not minimal,
    ft = 'go',
  },
  {
    'jack-rabe/impl.nvim',
    cond = false,
    ft = 'go',
    cmd = { 'ImplGenerate', 'ImplSearch' },
    opts = {},
  },
  -- CSV
  --------------------------------------------------------------------------------
  {
    'vidocqh/data-viewer.nvim',
    cond = not minimal,
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
    cond = not minimal,
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
    cmd = { 'CsvViewToggle', 'CsvViewEnable', 'CsvViewDisable' },
    config = function() require('csvview').setup() end,
  },
  -- Regex
  --------------------------------------------------------------------------------
  {
    'bennypowers/nvim-regexplainer',
    cond = not minimal,
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
        '<leader><localleader>rh',
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
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'turbio/bracey.vim',
    enabled = false,
    cond = not minimal and false,
    ft = 'html',
    build = 'npm install --prefix server',
  },
  {
    'luckasRanarison/tailwind-tools.nvim',
    enabled = false,
    cond = ar.lsp.enable and false,
    ft = {
      'html',
      'svelte',
      'astro',
      'vue',
      'typescriptreact',
      'javascriptreact',
      'htmlangular',
      'php',
      'blade',
    },
    event = { 'BufRead' },
    cmd = {
      'TailwindConcealToggle',
      'TailwindColorToggle',
      'TailwindSort',
      'TailwindSortSelection',
    },
    init = function()
      ar.add_to_select_menu('lsp', {
        ['Toggle Tailwind Conceal'] = 'TailwindConcealEnable',
        ['Toggle Tailwind Colors'] = 'TailwindColorToggle',
        ['Sort Tailwind Classes'] = 'TailwindSort',
      })
    end,
    opts = {
      document_color = { enabled = true, inline_symbol = '󰝤 ' },
      conceal = { enabled = true, symbol = '󱏿', min_length = 5 },
      custom_filetypes = {},
    },
  },
}
