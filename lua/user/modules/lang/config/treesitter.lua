rvim.treesitter = rvim.treesitter or {
  install_attempted = {},
}

return function()
  rvim.treesitter = {
    setup = {
      auto_install = true,
      highlight = { enabled = true },
      ensure_installed = {
        'lua',
        'dart',
        'rust',
        'typescript',
        'javascript',
        'comment',
        'markdown',
        'markdown_inline',
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<TAB>',
          node_decremental = '<C-CR>',
        },
      },
      textobjects = {
        lookahead = true,
        select = {
          enable = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['aC'] = '@conditional.outer',
            ['iC'] = '@conditional.inner',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['[w'] = { '@parameter.inner' },
          },
          swap_previous = {
            [']w'] = { '@parameter.inner' },
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']m'] = { '@function.outer', '@class.outer' },
          },
          goto_previous_start = {
            ['[m'] = { '@function.outer', '@class.outer' },
          },
        },
        lsp_interop = {
          enable = true,
          border = rvim.style.border.current,
          peek_definition_code = {
            ['<leader>lu'] = '@function.outer',
            ['<leader>lc'] = '@class.outer',
          },
        },
      },
      rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = 1000,
        disable = { 'lua', 'json', 'c', 'cpp', 'html' },
        colors = {
          'royalblue3',
          'darkorange3',
          'seagreen3',
          'firebrick',
          'darkorchid3',
        },
      },
    },
  }

  ---Get all filetypes for which we have a treesitter parser installed
  ---@return string[]
  function rvim.treesitter.get_filetypes()
    vim.cmd([[packadd nvim-treesitter]])
    local parsers = require('nvim-treesitter.parsers')
    local configs = parsers.get_parser_configs()
    return vim.tbl_map(function(ft)
      return configs[ft].filetype or ft
    end, parsers.available_parsers())
  end

  local Log = require('user.core.log')
  local status_ok, treesitter_configs = rvim.safe_require('nvim-treesitter.configs')
  if not status_ok then
    Log:debug('Failed to load nvim-treesitter.configs')
    return
  end

  treesitter_configs.setup({
    highlight = {
      enable = rvim.treesitter.setup.highlight.enabled,
      additional_vim_regex_highlighting = true,
    },
    incremental_selection = rvim.treesitter.setup.incremental_selection,
    textobjects = rvim.treesitter.setup.textobjects,
    indent = { enable = { 'javascriptreact' } },
    matchup = { enable = true, disable = { 'c', 'python' } },
    autopairs = { enable = true },
    rainbow = rvim.treesitter.setup.rainbow,
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { 'BufWrite', 'CursorHold' },
    },
    playground = {
      persist_queries = true,
    },
    ensure_installed = rvim.treesitter.setup.ensure_installed,
  })

  rvim.nnoremap('R', ':edit | TSBufEnable highlight<CR>', {})

  require('which-key').register({
    ['<leader>Le'] = { ':TSInstallInfo<cr>', 'treesitter: info' },
    ['<leader>Lm'] = { ':TSModuleInfo<cr>', 'treesitter: module info' },
    ['<leader>Lu'] = { ':TSUpdate<cr>', 'treesitter: update' },
  })

  -- Only apply folding to supported files:
  rvim.augroup('TreesitterFolds', {
    {
      event = { 'FileType' },
      pattern = rvim.treesitter.get_filetypes(),
      command = function()
        vim.cmd('setlocal foldexpr=nvim_treesitter#foldexpr()')
      end,
    },
  })
end
