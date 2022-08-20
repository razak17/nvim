if not rvim.plugin_installed('nvim-treesitter') then return end

return function()
  ---Get all filetypes for which we have a treesitter parser installed
  ---@return string[]
  local function get_filetypes()
    vim.cmd([[packadd nvim-treesitter]])
    local parsers = require('nvim-treesitter.parsers')
    local configs = parsers.get_parser_configs()
    return vim.tbl_map(
      function(ft) return configs[ft].filetype or ft end,
      parsers.available_parsers()
    )
  end

  local status_ok, treesitter_configs = rvim.safe_require('nvim-treesitter.configs')
  if not status_ok then return end

  treesitter_configs.setup({
    auto_install = true,
    highlight = { enable = true },
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
        include_surrounding_whitespace = true,
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
          ['<leader>lC'] = '@class.outer',
        },
      },
    },
    indent = { enable = { 'javascriptreact' } },
    matchup = { enable = true, disable = { 'c', 'python' } },
    autopairs = { enable = true },
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
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { 'BufWrite', 'CursorHold' },
    },
    playground = { persist_queries = true },
    ensure_installed = {
      'lua',
      'dart',
      'rust',
      'typescript',
      'javascript',
      'comment',
      'markdown',
      'markdown_inline',
      'prisma',
      'graphql',
      'go',
    },
  })

  -- Only apply folding to supported files:
  if not rvim.plugin_installed('nvim-ufo') then
    rvim.augroup('TreesitterFolds', {
      {
        event = { 'FileType' },
        pattern = get_filetypes(),
        command = function() vim.cmd('setlocal foldexpr=nvim_treesitter#foldexpr()') end,
      },
    })
  end
end
