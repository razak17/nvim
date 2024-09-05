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
    enabled = false,
    cond = not minimal and false,
    event = 'BufRead package.json',
    config = function()
      require('which-key').add({
        { '<localleader>P', group = 'Package Info' },
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
    init = function()
      require('which-key').add({
        { '<leader><leader>j', group = 'jSdoc Switch' },
        { '<leader><leader>jd', desc = 'doc switch' },
      })
    end,
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
    enabled = false,
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
    enabled = false,
    cond = not minimal and false, -- archived
    ft = { 'http', 'json' },
    init = function()
      require('which-key').add({
        { '<leader>rr', group = 'Rest' },
      })
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
  {
    'mistweaverco/kulala.nvim',
    ft = { 'http' },
    init = function()
      require('which-key').add({ { '<leader>rk', group = 'Kulala' } })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>rke', ':lua require("kulala").set_selected_env()<CR>', desc = 'kulala: select env' },
      { '<leader>rkk', ':lua require("kulala").run()<CR>', desc = 'kulala: run' },
      { '<leader>rkn', ':lua require("kulala").jump_next()<CR>', desc = 'kulala: next' },
      { '<leader>rkp', ':lua require("kulala").jump_prev()<CR>', desc = 'kulala: prev' },
      { '<leader>rks', ':lua require("kulala").scratchpad()<CR>', desc = 'kulala: scratchpad' },
      { '<leader>rkt', ':lua require("kulala").toggle_view()<CR>', desc = 'kulala: toggle view' },
    },
    opts = { default_env = 'local' },
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
      'eruby',
    },
  },
  {
    'MaximilianLloyd/tw-values.nvim',
    cond = ar.lsp.enable,
    -- stylua: ignore
    keys = {
      { '<localleader>lt', '<cmd>TWValues<cr>', desc = 'tw-values: show values', },
    },
    opts = { border = border, show_unknown_classes = true },
  },
  {
    'luckasRanarison/tailwind-tools.nvim',
    enabled = false,
    cond = ar.lsp.enable and false,
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
      require('which-key').add({
        { '<localleader>lv', group = 'Venv Selector' },
      })
    end,
    cond = ar.lsp.enable,
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
  {
    'alexpasmantier/pymple.nvim',
    build = ':PympleBuild',
    event = { 'BufEnter', 'BufNewFile' },
    cond = ar.lsp.enable,
    opts = {
      resolve_import_under_cursor = {
        desc = 'resolve import under cursor',
        keys = '<leader><leader>li',
      },
      python = {
        root_markers = { 'pyproject.toml', 'setup.py', '.git', 'manage.py' },
        virtual_env_names = { 'env' },
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
}
