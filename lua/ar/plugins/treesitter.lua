local highlight = ar.highlight
local coding = ar.plugins.coding
local ts_enabled = ar.treesitter.enable
local ts_extra_enabled = ar.ts_extra_enabled
local ts = require('ar.utils.treesitter')

-- https://github.com/rachartier/dotfiles/blob/main/.config/nvim/lua/plugins/utils/treesitter.lua?plain=1#L1
-- https://github.com/chrisgrieser/.config/blob/15cc1b7ad2cfc187c3bc984144136648083e85ca/nvim/lua/plugin-specs/appearance/treesitter.lua?plain=1#L1
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua?plain=1#L1

-- stylua: ignore
local ensure_installed = {
  programming_langs = {
    'c', 'cpp', 'bash', 'javascript', 'lua', 'python', 'ruby', 'rust', 'svelte',
    'swift', 'typescript', 'vim',
  },
  data_formats = { 'json', 'json5', 'jsonc', 'toml', 'xml', 'yaml' },
  content = { 'css', 'html', 'markdown', 'markdown_inline' },
  special_filetypes = {
    'diff', 'dockerfile', 'editorconfig', 'git_config', 'git_rebase', 'gitcommit',
    'gitattributes', 'gitignore', 'just', 'make', 'query', -- treesitter query files
    'requirements',
  },
  embedded_langs = {
    'comment', 'graphql', 'jsdoc', 'luadoc', 'luap', -- lua patterns
    -- 'regex', -- causes cursor to shift to the left when grepping in snacks picker
    'rst', -- python reST
    'vimdoc',
  },
}

return {
  {
    {
      'nvim-treesitter/nvim-treesitter',
      cond = function()
        return ar.get_plugin_cond('nvim-treesitter', ts_enabled)
      end,
      branch = 'main',
      lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
      event = { 'VeryLazy' },
      cmd = { 'TSUpdate', 'TSInstall', 'TSLog', 'TSUninstall' },
      build = function()
        local TS = require('nvim-treesitter')
        if not TS.get_installed then
          vim.notify(
            'Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.',
            vim.log.levels.ERROR
          )
          return
        end
        -- make sure we're using the latest treesitter util
        package.loaded['nvim-treesitter'] = nil
        ts.ensure_treesitter_cli(
          function() TS.update(nil, { summary = true }) end
        )
      end,
      enabled = true,
      ---@alias ar.TSFeat { enable?: boolean, disable?: string[] }
      ---@class ar.TSConfig: TSConfig
      opts = {
        indent = {
          enable = true,
          disable = { 'bash', 'zsh', 'markdown', 'javascript' },
        },
        highlight = { enable = true },
        folds = { enable = true },
        ensure_installed = ensure_installed,
        install_dir = vim.fn.stdpath('data') .. '/treesitter',
      },
      config = function(_, opts)
        local TS = require('nvim-treesitter')
        TS.setup(opts)

        vim.treesitter.language.register('bash', 'zsh')

        -- initialize the installed langs
        ts.get_installed(true)

        local to_install =
          vim.iter(vim.tbl_values(opts.ensure_installed)):flatten():totable()

        -- flatten ensure_installed
        local install = vim.tbl_filter(
          function(lang) return not ts.have(lang) end,
          to_install
        )

        local function install_parsers(parsers)
          ts.ensure_treesitter_cli(function()
            TS.install(parsers, { summary = true }):await(function()
              ts.get_installed(true) -- refresh the installed langs
            end)
          end)
        end

        local function uninstall_parsers(parsers)
          ts.ensure_treesitter_cli(function()
            TS.uninstall(parsers, { summary = true }):await(function()
              ts.get_installed(true) -- refresh the installed langs
            end)
          end)
        end

        ar.add_to_select_menu('command_palette', {
          ['Install Treesitter Parser'] = function()
            vim.ui.input({
              prompt = 'Enter parser names to install (comma separated): ',
            }, function(input)
              if not input or input == '' then return end
              local parsers = vim.split(input, ',', { trimempty = true })
              install_parsers(parsers)
            end)
          end,
          ['Uninstall Treesitter Parser'] = function()
            local installed =
              require('nvim-treesitter').get_installed('parsers')
            table.sort(installed)
            vim.ui.select(installed, {
              prompt = 'Select parser to uninstall: ',
            }, function(choice)
              if not choice then return end
              uninstall_parsers({ choice })
            end)
          end,
        })

        -- install missing parsers
        if #install > 0 then install_parsers(install) end

        ---@param feat string
        ---@param query string
        ---@param ft string
        local function enabled(feat, query, ft)
          local lang = vim.treesitter.language.get_lang(ft)
          local f = opts[feat] or {} ---@type ar.TSFeat
          return f.enable ~= false
            and not vim.tbl_contains(f.disable or {}, lang)
            and ts.have(ft, query)
        end

        -- start treesitter
        ---@param ft string
        local function start(ft, bufnr)
          if not ts.have(ft) then return end

          -- highlighting
          if enabled('highlight', 'highlights', ft) then
            pcall(vim.treesitter.start, bufnr)
          end

          -- indents
          if enabled('indent', 'indents', ft) then
            ar.set_default(
              'indentexpr',
              "v:lua.require'ar.utils.treesitter'.indentexpr()"
            )
          end

          -- folds
          if enabled('folds', 'folds', ft) then
            if ar.set_default('foldmethod', 'expr') then
              ar.set_default(
                'foldexpr',
                "v:lua.require'ar.utils.treesitter'.foldexpr()"
              )
            end
          end
        end

        ar.augroup('ar_treesitter', {
          event = 'FileType',
          command = function(ev)
            local P = require('nvim-treesitter.parsers')
            local parser_name = vim.treesitter.language.get_lang(ev.match)
            if not parser_name then return end

            -- auto install
            if P[ev.match] ~= nil and not ts.have(ev.match) then
              ts.ensure_treesitter_cli(function()
                TS.install({ parser_name }, { summary = true }):await(function()
                  ts.get_installed(true) -- refresh the installed langs
                  start(ev.match, ev.buf)
                end)
              end)
              return
            end

            start(ev.match, ev.buf)
          end,
        })
      end,
    },
    {
      'hrsh7th/nvim-cmp',
      optional = true,
      opts = function(_, opts)
        vim.g.cmp_add_source(opts, {
          menu = { treesitter = '[TS]' },
        })
      end,
    },
  },
  {
    'MeanderingProgrammer/treesitter-modules.nvim',
    cond = function()
      local condition = coding and ts_enabled
      return ar.get_plugin_cond('treesitter-modules.nvim', condition)
    end,
    event = { 'BufRead' },
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<A-o>',
          node_incremental = '<A-o>',
          scope_incremental = '<A-O>',
          node_decremental = '<A-i>',
        },
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    cond = function()
      local condition = coding and ts_enabled
      return ar.get_plugin_cond('nvim-treesitter-textobjects', condition)
    end,
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufRead' },
    keys = {
      {
        'a=',
        mode = { 'x', 'o' },
        function()
          require('nvim-treesitter-textobjects.select').select_textobject(
            '@assignment.outer',
            'textobjects'
          )
        end,
        desc = 'Select inner part of an assignment',
      },
      {
        'i=',
        mode = { 'x', 'o' },
        function()
          require('nvim-treesitter-textobjects.select').select_textobject(
            '@assignment.inner',
            'textobjects'
          )
        end,
        desc = 'Select inner part of an assignment',
      },
      {
        'L=',
        mode = { 'x', 'o' },
        function()
          require('nvim-treesitter-textobjects.select').select_textobject(
            '@assignment.lhs',
            'textobjects'
          )
        end,
        desc = 'Select left hand side of an assignment',
      },
      {
        'R=',
        mode = { 'x', 'o' },
        function()
          require('nvim-treesitter-textobjects.select').select_textobject(
            '@assignment.rhs',
            'textobjects'
          )
        end,
        desc = 'Select right hand side of an assignment',
      },
      {
        'a:',
        mode = { 'x', 'o' },
        function()
          require('nvim-treesitter-textobjects.select').select_textobject(
            '@property.outer',
            'textobjects'
          )
        end,
        desc = 'Select outer part of an object property',
      },
      {
        'i:',
        mode = { 'x', 'o' },
        function()
          require('nvim-treesitter-textobjects.select').select_textobject(
            '@property.inner',
            'textobjects'
          )
        end,
        desc = 'Select inner part of an object property',
      },
      {
        'L:',
        mode = { 'x', 'o' },
        function()
          require('nvim-treesitter-textobjects.select').select_textobject(
            '@property.lhs',
            'textobjects'
          )
        end,
        desc = 'Select left part of an object property',
      },
      {
        'R:',
        mode = { 'x', 'o' },
        function()
          require('nvim-treesitter-textobjects.select').select_textobject(
            '@property.rhs',
            'textobjects'
          )
        end,
        desc = 'Select right part of an object property',
      },
    },
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = {
          enable = not coding,
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
          include_surrounding_whitespace = true,
        },
        -- stylua: ignore
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      })
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    cond = function()
      local condition = coding and ts_extra_enabled
      return ar.get_plugin_cond('nvim-ts-autotag', condition)
    end,
    ft = {
      'typescriptreact',
      'javascript',
      'javascriptreact',
      'html',
      'vue',
      'svelte',
    },
    opts = {},
  },
  {
    'andymass/vim-matchup',
    event = { 'BufReadPre', 'BufNewFile' },
    cond = function()
      local condition = coding and ts_extra_enabled
      return ar.get_plugin_cond('vim-matchup', condition)
    end,
    keys = {
      { '[[', '<plug>(matchup-[%)', mode = { 'n', 'x' } },
      { ']]', '<plug>(matchup-]%)', mode = { 'n', 'x' } },
      {
        '<localleader>lW',
        ':<c-u>MatchupWhereAmI?<CR>',
        desc = 'matchup: where am i',
      },
    },
    config = function()
      highlight.plugin('vim-matchup', {
        theme = {
          ['onedark'] = {
            { MatchWord = { inherit = 'LspReferenceText', underline = true } },
            { MatchParenCursor = { link = 'MatchParen' } },
            { MatchParenOffscreen = { link = 'MatchParen' } },
          },
        },
      })
      vim.g.matchup_surround_enabled = 1
      vim.g.matchup_matchparen_nomode = 'i'
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_deferred_show_delay = 400
      vim.g.matchup_matchparen_deferred_hide_delay = 400
      vim.g.matchup_matchparen_offscreen = {}
    end,
  },
}
