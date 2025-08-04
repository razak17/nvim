local highlight = ar.highlight
local minimal = ar.plugins.minimal
local ts_enabled = ar.treesitter.enable
local ts_extra_enabled = ar.ts_extra_enabled

-- https://github.com/rachartier/dotfiles/blob/main/.config/nvim/lua/plugins/utils/treesitter.lua?plain=1#L1
local function start_treesitter(bufnr, match)
  local ok, _ = pcall(vim.treesitter.start, bufnr)

  if not ok then return end

  vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

  local dont_use_treesitter_indent = { 'bash', 'zsh', 'markdown' }
  if not vim.list_contains(dont_use_treesitter_indent, match) then
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

local function treesitter_install(ensure_installed)
  -- Only install parsers that aren't already installed
  local parsers_to_install = vim
    .iter(ensure_installed)
    :filter(function(parser)
      local already_installed = require('nvim-treesitter').get_installed()
      return not vim.tbl_contains(already_installed, parser)
    end)
    :totable()

  -- Install missing parsers if any
  if #parsers_to_install > 0 then
    require('nvim-treesitter').install(parsers_to_install)
  end
end

local function setup_treesitter_autocmd()
  local ts = require('nvim-treesitter')
  local parsers = ts.get_available()
  if not parsers or #parsers == 0 then return end

  local ft_to_attach = vim
    .iter(parsers)
    :map(function(parser)
      local filetypes = vim.treesitter.language.get_filetypes(parser)
      if filetypes and #filetypes > 0 then return filetypes end
    end)
    :filter(function(ft) return ft ~= nil end)
    :flatten()
    :totable()

  local function treesitter_auto_install(parser_name, cb)
    local installed_parser = ts.get_installed()
    local is_installed = parsers
      and vim.tbl_contains(installed_parser, parser_name)

    if not is_installed then ts.install({ parser_name }):await(cb) end
    return is_installed
  end

  ar.augroup('treesitter', {
    event = 'FileType',
    pattern = ft_to_attach,
    command = function(event)
      local ft = vim.api.nvim_get_option_value('filetype', { buf = event.buf })

      local parser_name = vim.treesitter.language.get_lang(ft)
      if not parser_name then return end

      local is_installed = treesitter_auto_install(
        parser_name,
        function() start_treesitter(event.buf, event.match) end
      )
      if is_installed then start_treesitter(event.buf, event.match) end
    end,
  })
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    cond = ts_enabled,
    branch = 'main',
    build = { ':TSUpdate' },
    event = { 'BufRead' },
    enabled = true,
    ---@class TSConfig
    opts = {
      ensure_installed = {
        programmingLangs = {
          'c',
          'cpp',
          'bash',
          'javascript',
          'lua',
          'python',
          'ruby',
          'rust',
          'svelte',
          'swift',
          'typescript',
          'vim',
        },
        dataFormats = {
          'json',
          'json5',
          'jsonc',
          'toml',
          'xml',
          'yaml',
        },
        content = {
          'css',
          'html',
          'markdown',
          'markdown_inline',
        },
        specialFiletypes = {
          'diff',
          'dockerfile',
          'editorconfig',
          'git_config',
          'git_rebase',
          'gitcommit',
          'gitattributes',
          'gitignore',
          'just',
          'make',
          'query', -- treesitter query files
          'requirements',
        },
        embeddedLangs = {
          'comment',
          'graphql',
          'jsdoc',
          'luadoc',
          'luap', -- lua patterns
          'regex',
          'rst', -- python reST
          'vimdoc',
        },
      },
      install_dir = vim.fn.stdpath('data') .. '/treesitter',
    },
    config = function(_, opts)
      local parsers_to_install =
        vim.iter(vim.tbl_values(opts.ensure_installed)):flatten():totable()
      vim.treesitter.language.register('bash', 'zsh')
      setup_treesitter_autocmd()
      treesitter_install(parsers_to_install)
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
    'nvim-treesitter/playground',
    cond = not minimal and ts_extra_enabled,
    cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
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
