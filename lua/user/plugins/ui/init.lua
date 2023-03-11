local hl, ui = rvim.highlight, rvim.ui
local border = ui.current.border

return {
  'nvim-tree/nvim-web-devicons',

  { 'fladson/vim-kitty', ft = 'kitty' },
  { 'razak17/zephyr-nvim', lazy = false, priority = 1000 },
  { 'LunarVim/horizon.nvim', lazy = false, priority = 1000 },
  {
    'itchyny/vim-highlighturl',
    event = 'BufReadPre',
    config = function() vim.g.highlighturl_guifg = hl.get('URL', 'fg') end,
  },
  {
    'romainl/vim-cool',
    event = 'BufReadPre',
    config = function() vim.g.CoolTotalMatches = 1 end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      char = '▏', -- ┆ ┊ ▎
      show_foldtext = false,
      context_char = '▏', -- ▎
      char_priority = 12,
      show_current_context = true,
      show_current_context_start = false,
      show_current_context_start_on_current_line = false,
      show_first_indent_level = true,
      -- stylua: ignore
      filetype_exclude = {
        'dbout', 'neo-tree-popup', 'log', 'gitcommit', 'txt', 'help', 'NvimTree', 'git', 'flutterToolsOutline',
        'undotree', 'markdown', 'norg', 'org', 'orgagenda', '', -- for all buffers without a file type
      },
    },
  },
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    config = function()
      require('dressing').setup({
        input = { insert_only = false, border = border },
        select = {
          telescope = rvim.telescope.adaptive_dropdown(),
          get_config = function()
            return { backend = 'telescope', telescope = rvim.telescope.cursor() }
          end,
        },
      })
    end,
  },
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {
      preview = {
        border_chars = { '│', '│', '─', '─', '┌', '┐', '└', '┘', '▊' },
      },
    },
  },
  {
    'j-hui/fidget.nvim',
    event = 'BufReadPre',
    config = function()
      require('fidget').setup({
        align = { bottom = false, right = true },
        fmt = { stack_upwards = false },
      })
      rvim.augroup('CloseFidget', {
        event = { 'VimLeavePre', 'LspDetach' },
        command = 'silent! FidgetClose',
      })
    end,
  },
  {
    'shortcuts/no-neck-pain.nvim',
    keys = {
      {
        '<leader>on',
        function() require('no-neck-pain').toggle() end,
        mode = 'n',
        desc = 'toggle no-neck-pain',
        noremap = true,
        silent = true,
        expr = false,
      },
    },
  },
  {
    'lukas-reineke/headlines.nvim',
    ft = { 'org', 'norg', 'markdown', 'yaml' },
    config = function()
      hl.plugin('Headlines', {
        {
          Headline = {
            bold = true,
            italic = true,
            background = { from = 'Normal', alter = 20 },
          },
        },
        { Headline1 = { background = '#003c30' } },
        { Headline2 = { background = '#00441b' } },
        { Headline3 = { background = '#084081' } },
        { Dash = { background = '#0b60a1', bold = true } },
        {
          CodeBlock = {
            bold = true,
            italic = true,
            background = { from = 'Normal', alter = 30 },
          },
        },
      })
      require('headlines').setup({
        org = { headline_highlights = false },
        norg = { headline_highlights = { 'Headline' }, codeblock_highlight = false },
        markdown = { headline_highlights = { 'Headline1' } },
      })
    end,
  },
  {
    'folke/todo-comments.nvim',
    event = 'BufReadPre',
    cmd = { 'TodoTelescope', 'TodoTrouble', 'TodoQuickFix', 'TodoDots' },
    keys = {
      { '<leader>tt', '<cmd>TodoDots<CR>', desc = 'todo: dotfiles todos' },
      {
        '<leader>tj',
        function() require('todo-comments').jump_next() end,
        desc = 'todo-comments: next todo',
      },
      {
        '<leader>tk',
        function() require('todo-comments').jump_prev() end,
        desc = 'todo-comments: prev todo',
      },
    },
    config = function()
      require('todo-comments').setup({ highlight = { after = '' } })
      rvim.command(
        'TodoDots',
        string.format('TodoTelescope cwd=%s keywords=TODO,FIXME', rvim.get_config_dir())
      )
    end,
  },
  {
    'lukas-reineke/virt-column.nvim',
    event = 'BufReadPre',
    opts = { char = '▕' },
    init = function()
      hl.plugin('virt_column', { { VirtColumn = { link = 'FloatBorder' } } })
      rvim.augroup('VirtCol', {
        event = { 'VimEnter', 'BufEnter', 'WinEnter' },
        command = function(args)
          ui.decorations.set_colorcolumn(
            args.buf,
            function(virtcolumn) require('virt-column').setup_buffer({ virtcolumn = virtcolumn }) end
          )
        end,
      })
    end,
  },
  {
    'uga-rosa/ccc.nvim',
    ft = { 'lua', 'vim', 'typescript', 'typescriptreact', 'javascriptreact', 'svelte', 'astro' },
    keys = { { '<leader>oc', '<cmd>CccHighlighterToggle<CR>', desc = 'toggle ccc' } },
    opts = {
      win_opts = { border = border },
      highlighter = { auto_enable = true, excludes = { 'dart', 'html', 'css', 'typescriptreact' } },
    },
  },
  {
    'levouh/tint.nvim',
    event = 'WinNew',
    opts = {
      tint = -30,
      -- stylua: ignore
      highlight_ignore_patterns = {
        'WinSeparator', 'St.*', 'Comment', 'Panel.*', 'Telescope.*',
        'Bqf.*', 'VirtColumn', 'Headline.*', 'NeoTree.*',
      },
      window_ignore_function = function(win_id)
        local win, buf = vim.wo[win_id], vim.bo[vim.api.nvim_win_get_buf(win_id)]
        -- BUG: neotree cannot be ignore rvim either nofile or by filetype rvim this causes tinting bugs
        if win.diff or not rvim.empty(vim.fn.win_gettype(win_id)) then return true end
        local ignore_bt = rvim.p_table({ terminal = true, prompt = true, nofile = false })
        local ignore_ft =
          rvim.p_table({ ['Telescope.*'] = true, ['Neogit.*'] = true, ['qf'] = true })
        local has_bt, has_ft = ignore_bt[buf.buftype], ignore_ft[buf.filetype]
        return has_bt or has_ft
      end,
    },
  },
}
