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
  -- Markdown
  --------------------------------------------------------------------------------
  { 'bullets-vim/bullets.vim', ft = { 'markdown' } },
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
    'Zeioth/markmap.nvim',
    build = 'yarn global add markmap-cli',
    cmd = { 'MarkmapOpen', 'MarkmapSave', 'MarkmapWatch', 'MarkmapWatchStop' },
    opts = {},
  },
  {
    '3rd/image.nvim',
    cond = not minimal,
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
    cond = not minimal and niceties,
    cmd = { 'RenderMarkdownToggle' },
    ft = { 'markdown' },
    opts = {
      heading = {
        sign = false,
        -- signs = { '󰫎 ' },
        enabled = not ar.treesitter.enable,
        icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
        backgrounds = {
          'Headline1Bg',
          'Headline2Bg',
          'Headline3Bg',
          'Headline4Bg',
          'Headline5Bg',
          'Headline6Bg',
        },
        foregrounds = {
          'Headline1Fg',
          'Headline2Fg',
          'Headline3Fg',
          'Headline4Fg',
          'Headline5Fg',
          'Headline6Fg',
        },
      },
      checkbox = {
        enabled = not ar.treesitter.enable,
        unchecked = {
          icon = '🔲',
          highlight = '@markup.list.unchecked',
        },
        checked = {
          icon = '✅',
          highlight = '@markup.heading',
        },
      },
      bullets = {
        enabled = false,
        icons = { '▶', '○', '●', '▷' }, --  '◆', '◇'
        highlight = 'Directory',
      },
      code = {
        enabled = true,
        style = 'normal',
        highlight = 'ColorColumn',
      },
    },
    config = function(_, opts)
      require('render-markdown').setup(opts)

      local color1_bg = '#f265b5'
      local color2_bg = '#37f499'
      local color3_bg = '#04d1f9'
      local color4_bg = '#a48cf2'
      local color5_bg = '#f1fc79'
      local color6_bg = '#f7c67f'
      local color_fg = '#323449'

      highlight.plugin('render-markdown', {
        theme = {
          ['onedark'] = {
            { MarkdownCodeBlock = { link = 'CodeBlock' } },
            -- Heading colors (when not hovered over), extends through the entire line
            { Headline1Bg = { fg = color_fg, bg = color1_bg } },
            { Headline2Bg = { fg = color_fg, bg = color2_bg } },
            { Headline3Bg = { fg = color_fg, bg = color3_bg } },
            { Headline4Bg = { fg = color_fg, bg = color4_bg } },
            { Headline5Bg = { fg = color_fg, bg = color5_bg } },
            { Headline6Bg = { fg = color_fg, bg = color6_bg } },
            -- Highlight for the heading and sign icons (symbol on the left)
            -- I have the sign disabled for now, so this makes no effect
            { Headline1Fg = { fg = color1_bg, cterm = 'bold', gui = 'bold' } },
            { Headline2Fg = { fg = color2_bg, cterm = 'bold', gui = 'bold' } },
            { Headline3Fg = { fg = color3_bg, cterm = 'bold', gui = 'bold' } },
            { Headline4Fg = { fg = color4_bg, cterm = 'bold', gui = 'bold' } },
            { Headline5Fg = { fg = color5_bg, cterm = 'bold', gui = 'bold' } },
            { Headline6Fg = { fg = color6_bg, cterm = 'bold', gui = 'bold' } },
          },
        },
      })
    end,
  },
  {
    'OXY2DEV/markview.nvim',
    cond = not minimal and not niceties,
    cmd = { 'Markview' },
    ft = { 'markdown' },
    opts = {},
  },
  {
    'arminveres/md-pdf.nvim',
    keys = {
      {
        '<localleader>mp',
        function() require('md-pdf').convert_md_to_pdf() end,
        desc = 'md-pdf: convert to pdf',
      },
    },
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
