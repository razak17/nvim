local highlight = ar.highlight
local minimal = ar.plugins.minimal
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
  content = { 'css', 'html', 'markdown', 'markdown_inline'
  },
  special_filetypes = {
    'diff', 'dockerfile', 'editorconfig', 'git_config', 'git_rebase', 'gitcommit',
    'gitattributes', 'gitignore', 'just', 'make', 'query', -- treesitter query files
    'requirements',
  },
  embedded_langs = {
    'comment', 'graphql', 'jsdoc', 'luadoc', 'luap', -- lua patterns
    'regex', 'rst', -- python reST
    'vimdoc',
  },
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    cond = ts_enabled,
    branch = 'main',
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    event = { 'VeryLazy' },
    cmd = { 'TSUpdate', 'TSInstall', 'TSLog', 'TSUninstall' },
    build = function()
      local TS = require('nvim-treesitter')
      ts.ensure_treesitter_cli(
        function() TS.update(nil, { summary = true }) end
      )
    end,
    enabled = true,
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

      -- install missing parsers
      if #install > 0 then
        ts.ensure_treesitter_cli(function()
          TS.install(install, { summary = true }):await(function()
            ts.get_installed(true) -- refresh the installed langs
          end)
        end)
      end

      -- start treesitter
      local function start(match, buf)
        if not ts.have(match) then return end

        -- highlighting
        if vim.tbl_get(opts, 'highlight', 'enable') ~= false then
          pcall(vim.treesitter.start)
        end

        -- indents
        if vim.tbl_get(opts, 'indent', 'enable') ~= false then
          local disable = opts.indent.disable or {}
          if not vim.list_contains(disable, match) then
            ar.set_default(
              'indentexpr',
              "v:lua.require'ar.utils.treesitter'.indentexpr()"
            )
          end
        end

        -- folds
        if vim.tbl_get(opts, 'folds', 'enable') ~= false then
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
          local parser_name = vim.treesitter.language.get_lang(ev.match)
          if not parser_name then return end

          -- auto install
          if not ts.have(ev.match) then
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
    'nvim-treesitter/nvim-treesitter-textobjects',
    cond = not minimal and ts_enabled,
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
          enable = not minimal,
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
    cond = not minimal and ts_extra_enabled,
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
    cond = not minimal and ts_extra_enabled and false,
    keys = {
      { '[[', '<plug>(matchup-[%)', mode = { 'n', 'x' } },
      { ']]', '<plug>(matchup-]%)', mode = { 'n', 'x' } },
      {
        '<localleader>lW',
        ':<c-u>MatchupWhereAmI?<CR>',
        desc = 'matchup: where am i',
      },
    },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treeitter** module to be loaded in time.
      -- Luckily, the only thins that those plugins need are the custom queries, which we make available
      -- during startup.
      require('lazy.core.loader').add_to_rtp(plugin)
      require('nvim-treesitter.query_predicates')
    end,
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
