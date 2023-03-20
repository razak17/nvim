local hl, ui = rvim.highlight, rvim.ui

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
}