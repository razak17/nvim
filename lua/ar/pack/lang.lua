local ui, highlight = ar.ui, ar.highlight
local border = ui.current.border.default
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties
local enabled = not minimal and ar.lsp.enable

ar.pack.add({
  -- Web Dev (Typescript)
  --------------------------------------------------------------------------------
  {
    src = 'https://github.com/Redoxahmii/json-to-types.nvim',
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
    src = 'https://github.com/midoBB/nvim-quicktype',
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
      ar.add_to_select('command_palette', {
        ['Generate Types From JSON'] = function()
          if not ar.plugin_available('nvim-quicktype') then return end
          vim.cmd('QuickType')
        end,
      })
    end,
    setup = function() require('nvim-quicktype').setup() end,
  },
  {
    src = 'https://github.com/razak17/package-info.nvim',
    cond = function() return ar.get_plugin_cond('package-info.nvim') end,
    cmd = {
      'PackageInfoChangeVersion',
      'PackageInfoDelete',
      'PackageInfoHide',
      'PackageInfoInstall',
      'PackageInfoShow',
      'PackageInfoShowForce',
      'PackageInfoUpdate',
    },
    init = function()
      ar.augroup('PackageInfoLoad', {
        event = 'BufRead',
        pattern = 'package.json',
        command = function()
          ar.pack.load('https://github.com/razak17/package-info.nvim')
        end,
      })
    end,
    setup = function()
      vim.g.whichkey_add_spec({ '<leader><leader>P', group = 'Package Info' })

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
        win = {
          border = 'single',
          highlight = 'Normal:NormalFloat,FloatBorder:FloatBorder',
        },
      })
    end,
  },
  {
    src = 'https://github.com/bennypowers/template-literal-comments.nvim',
    cond = function()
      return ar.get_plugin_cond('template-literal-comments.nvim', not minimal)
    end,
    ft = { 'javascript', 'typescript' },
    setup = function() require('template-literal-comments').setup() end,
  },
  {
    src = 'https://github.com/jdrupal-dev/code-refactor.nvim',
    cond = function()
      return ar.get_plugin_cond('code-refactor.nvim', not minimal)
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>la', '<cmd>CodeActions all<CR>', desc = 'Show code-refactor.nvim (not LSP code actions)' },
    },
    setup = function() require('code-refactor').setup() end,
  },
  {
    -- 'razak17/template-string.nvim',
    src = 'https://github.com/axelvc/template-string.nvim',
    cond = function()
      return ar.get_plugin_cond('template-string.nvim', not minimal)
    end,
    cmd = { 'TemplateString' },
    init = function()
      ar.add_to_select('toggle', {
        ['Toggle Template String'] = 'TemplateString toggle',
      })
    end,
    ft = (function()
      local fts = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'svelte',
      }
      if not ar.lsp.enable then table.insert(fts, 'python') end
      return fts
    end)(),
    setup = function()
      require('template-string').setup({ remove_template_string = true })
    end,
  },
  {
    src = 'https://github.com/joeldotdias/jsdoc-switch.nvim',
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
    setup = function()
      require('jsdoc-switch').setup({ auto_set_keys = false, notify = false })
    end,
  },
  {
    -- 'fabridamicelli/cronex.nvim',
    src = 'https://github.com/razak17/cronex.nvim',
    cond = function() return ar.get_plugin_cond('cronex.nvim', not minimal) end,
    build = 'npm install -g cronstrue',
    cmd = {
      'CronExplainedEnable',
      'CronExplainedDisable',
      'CronExplainedToggle',
    },
    init = function()
      ar.add_to_select(
        'command_palette',
        { ['Toggle Cronex'] = 'CronExplainedToggle' }
      )
    end,
    setup = function()
      require('cronex').setup({
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
      })
    end,
  },
  {
    src = 'https://github.com/razak17/sortjson.nvim',
    cond = function() return ar.get_plugin_cond('sortjson.nvim') end,
    cmd = {
      'SortJSONByAlphaNum',
      'SortJSONByAlphaNumReverse',
      'SortJSONByKeyLength',
      'SortJSONByKeyLengthReverse',
    },
    setup = function() require('sortjson').setup() end,
  },
  {
    src = 'https://github.com/razak17/stringbreaker.nvim',
    cond = function() return ar.get_plugin_cond('stringbreaker.nvim') end,
    cmd = { 'BreakString', 'SaveString' },
    setup = function() require('string-breaker').setup() end,
  },
  {
    src = 'https://github.com/AndrewRadev/inline_edit.vim',
    cond = function() return ar.get_plugin_cond('inline_edit.nvim') end,
    cmd = { 'InlineEdit' },
  },
  {
    src = 'https://github.com/Kenzo-Wada/boundary.nvim',
    cond = function() return ar.get_plugin_cond('boundary.nvim', not minimal) end,
    cmd = { 'BoundaryRefresh' },
    ft = { 'javascriptreact', 'typescriptreact' },
    setup = function() require('boundary').setup() end,
  },
  -- Python
  --------------------------------------------------------------------------------
  {
    src = 'https://github.com/linux-cultist/venv-selector.nvim',
    cond = function() return ar.get_plugin_cond('venv-selector.nvim', enabled) end,
    version = 'regexp', -- This is the regexp branch, use this for the new version
    init = function()
      ar.add_to_select('command_palette', {
        ['Venv Selector: select env'] = 'VenvSelect',
        ['Venv Selector: select cached env'] = 'VenvSelectCached',
      })
    end,
    cmd = 'VenvSelect',
    setup = function()
      require('venv-selector').setup({
        name = { 'venv', '.venv', 'env', '.env' },
      })
    end,
  },
  {
    src = 'https://github.com/alexpasmantier/pymple.nvim',
    cond = function() return ar.get_plugin_cond('pymple.nvim', enabled) end,
    build = function() require('pymple').install() end,
    ft = { 'python' },
    setup = function()
      require('pymple').setup({
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
      })
    end,
  },
  -- Golang
  --------------------------------------------------------------------------------
  {
    src = 'https://github.com/olexsmir/gopher.nvim',
    cond = function()
      local condition = ar.lsp.enable and not minimal
      return ar.get_plugin_cond('gopher.nvim', condition)
    end,
    ft = 'go',
  },
  {
    src = 'https://github.com/jack-rabe/impl.nvim',
    cond = function()
      local cond = not ar.plugin_disabled('telescope.nvim') and not minimal
      return ar.get_plugin_cond('impl.nvim', cond)
    end,
    ft = 'go',
    cmd = { 'ImplGenerate', 'ImplSearch' },
    setup = function() require('impl').setup() end,
  },
  {
    src = 'https://github.com/fredrikaverpil/godoc.nvim',
    cond = function() return ar.get_plugin_cond('godoc.nvim') end,
    cmd = { 'GoDoc' }, -- optional
    version = vim.version.range('*'),
    build = 'go install github.com/lotusirous/gostdsym/stdsym@latest', -- optional
    setup = function()
      local function get_picker()
        local variant = ar.config.picker.variant
        if variant == 'fzf-lua' then return 'fzf_lua' end
        if variant == 'mini.pick' then return 'mini' end
        return variant
      end
      require('godoc').setup({ picker = { type = get_picker() } })
    end, -- see further down below for configuration
  },
  {
    src = 'https://github.com/sjclayton/goplexity.nvim',
    cond = function() return ar.get_plugin_cond('goplexity.nvim') end,
    cmd = { 'Goplexity' },
    setup = function() require('goplexity').setup() end,
  },
  -- CSV
  --------------------------------------------------------------------------------
  {
    src = 'https://github.com/emmanueltouzery/decisive.nvim',
    cond = function() return ar.get_plugin_cond('decisive.nvim', not minimal) end,
    ft = { 'csv' },
    keys = function()
      local function jump(options)
        return ar.jump(function(opt)
          if opt.forward then require('decisive').align_csv_next_col() end
          if not opt.forward then require('decisive').align_csv_prev_col() end
        end, options)
      end
      return {
        {
          '<localleader>ci',
          "<Cmd>lua require('decisive').align_csv({})<CR>",
          desc = 'decisive: align',
        },
        {
          '<localleader>cx',
          "<Cmd>lua require('decisive').align_csv_clear({})<CR>",
          desc = 'decisive: clear',
        },
        {
          '<localleader>cp',
          jump({ forward = false }),
          desc = 'decisive: prev col',
        },
        {
          '<localleader>cn',
          jump({ forward = true }),
          desc = 'decisive: next col',
        },
      }
    end,
  },
  -- Regex
  --------------------------------------------------------------------------------
  {
    -- Describe the regexp under the cursor
    src = 'https://github.com/bennypowers/nvim-regexplainer',
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
    setup = function()
      require('regexplainer').setup({
        display = 'popup',
        popup = {
          border = {
            padding = { 1, 2 },
            style = border,
          },
        },
      })
    end,
  },
  {
    -- A Neovim plugin that provides an explanation for regular expressions.
    src = 'https://github.com/tomiis4/Hypersonic.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('Hypersonic.nvim', condition)
    end,
    event = 'CmdlineEnter',
    cmd = { 'Hypersonic' },
    setup = function() require('hypersonic').setup({ border = border }) end,
  },
  -- }}}
  -- Typst
  --------------------------------------------------------------------------------
  {
    src = 'https://github.com/chomosuke/typst-preview.nvim',
    ft = 'typst',
    cond = function() return ar.get_plugin_cond('typst-preview') end,
    cmd = { 'TypstPreview', 'TypstPreviewToggle', 'TypstPreviewUpdate' },
  },
  -- }}}
  ------------------------------------------------------------------------------
  -- Syntax {{{1
  ------------------------------------------------------------------------------
  {
    src = 'https://github.com/psliwka/vim-dirtytalk',
    cond = function() return ar.get_plugin_cond('vim-dirtytalk', not minimal) end,
    event = { 'BufRead' },
    build = function() vim.cmd('DirtytalkUpdate') end,
    init = function() vim.opt.spelllang:prepend('programming') end,
  },
  ---}}}
})
