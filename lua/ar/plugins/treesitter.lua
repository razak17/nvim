local highlight = ar.highlight
local coding = ar.plugins.coding
local ts_enabled = ar.treesitter.enable
local ts = require('ar.utils.treesitter')

-- https://github.com/rachartier/dotfiles/blob/main/.config/nvim/lua/plugins/utils/treesitter.lua?plain=1#L1
-- https://github.com/chrisgrieser/.config/blob/15cc1b7ad2cfc187c3bc984144136648083e85ca/nvim/lua/plugin-specs/appearance/treesitter.lua?plain=1#L1
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua?plain=1#L1

-- stylua: ignore
local ensure_installed = {
  programming_langs = {
    'c', 'cpp', 'bash', 'javascript', 'lua', 'python', 'ruby', 'rust', 'svelte',
    'swift', 'typescript', 'tsx', 'vim',
  },
  data_formats = { 'json', 'json5', 'toml', 'xml', 'yaml' },
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
    'romus204/tree-sitter-manager.nvim',
    cond = function()
      return ar.get_plugin_cond('tree-sitter-manager.nvim', ts_enabled)
    end,
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    event = { 'VeryLazy' },
    cmd = { 'TSManager', 'TSInstall', 'TSUninstall', 'TSUpdate' },
    build = function()
      ts.ensure_treesitter_cli(function() vim.cmd('TSUpdate') end)
    end,
    init = function()
      local parser_path = vim.fn.stdpath('data') .. '/treesitter'
      vim.opt.rtp:prepend(parser_path)
    end,
    ---@alias ar.TSFeat { enable?: boolean, disable?: string[] }
    ---@class ar.TSConfig: TSConfig
    opts = {
      indent = {
        enable = true,
        disable = { 'bash', 'zsh', 'markdown', 'javascript' },
      },
      highlight = { enable = true },
      folds = { enable = true },
    },
    config = function(_, opts)
      -- flatten ensure_installed
      local to_install =
        vim.iter(vim.tbl_values(ensure_installed)):flatten():totable()

      require('tree-sitter-manager').setup({
        auto_install = true,
        highlight = false,
        ensure_installed = to_install,
        parser_dir = vim.fn.stdpath('data') .. '/treesitter/parser',
        query_dir = vim.fn.stdpath('data') .. '/treesitter/queries',
      })

      local function jump(options)
        return ar.jump(function(o)
          local which = o.forward and 'select_next' or 'select_prev'
          require('vim.treesitter._select')[which](vim.v.count1)
        end, options)
      end

      map({ 'n', 'x', 'o' }, ']n', jump({ forward = true }), {
        desc = 'next node',
      })
      map({ 'n', 'x', 'o' }, '[n', jump({ forward = false }), {
        desc = 'prev node',
      })

      local function pt_jump(options)
        return ar.jump(function(o)
          local which = o.forward and 'select_parent' or 'select_child'
          if vim.treesitter.get_parser(nil, nil, { error = false }) then
            require('vim.treesitter._select')[which](vim.v.count1)
            return
          end
          if o.forward then
            vim.lsp.buf.selection_range(vim.v.count1)
            return
          end
          vim.lsp.buf.selection_range(-vim.v.count1)
        end, options)
      end

      map({ 'n', 'x', 'o' }, '<A-o>', pt_jump({ forward = true }), {
        desc = 'parent node',
      })
      map({ 'n', 'x', 'o' }, '<A-i>', pt_jump({ forward = false }), {
        desc = 'child node',
      })

      vim.treesitter.language.register('bash', 'zsh')

      -- initialize the installed langs
      ts.get_installed(true)

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

      ar.augroup('ar_treesitter_manager', {
        event = 'FileType',
        command = function(ev)
          local parser_name = vim.treesitter.language.get_lang(ev.match)
          if not parser_name then return end

          if not ts.have(ev.match) then return end

          -- highlighting
          if enabled('highlight', 'highlights', ev.match) then
            pcall(vim.treesitter.start, bufnr)
          end

          -- indents
          if enabled('indent', 'indents', ev.match) then
            ar.set_default(
              'indentexpr',
              "v:lua.require'ar.utils.treesitter'.indentexpr()"
            )
          end

          -- folds
          if enabled('folds', 'folds', ev.match) then
            if ar.set_default('foldmethod', 'expr') then
              ar.set_default(
                'foldexpr',
                "v:lua.require'ar.utils.treesitter'.foldexpr()"
              )
            end
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    cond = function()
      return ar.get_plugin_cond('nvim-treesitter-textobjects', ts_enabled)
    end,
    branch = 'main',
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
    cond = function() return ar.get_plugin_cond('nvim-ts-autotag', coding) end,
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
    cond = function() return ar.get_plugin_cond('vim-matchup', coding) end,
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
        { MatchWord = { inherit = 'LspReferenceText', underline = true } },
        { MatchParenCursor = { link = 'MatchParen' } },
        { MatchParenOffscreen = { link = 'MatchParen' } },
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
