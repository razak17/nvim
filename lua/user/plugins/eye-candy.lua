local highlight, ui = rvim.highlight, rvim.ui
local separators, decorations = ui.icons.separators, ui.decorations

return {
  'nvim-tree/nvim-web-devicons',

  { 'razak17/onedark.nvim', lazy = false, priority = 1000 },
  { 'LunarVim/horizon.nvim', lazy = false, priority = 1000 },
  { 'fladson/vim-kitty', ft = 'kitty' },
  { 'romainl/vim-cool', event = 'BufReadPre', config = function() vim.g.CoolTotalMatches = 1 end },
  { 'razak17/tailwind-fold.nvim', ft = { 'html', 'svelte', 'astro', 'vue', 'typescriptreact' } },
  {
    'kevinhwang91/nvim-hlslens',
    event = 'BufReadPre',
    opts = {},
    init = function() highlight.plugin('hlslens', { { HlSearchLens = { fg = { from = 'Comment', alter = 0.15 } } } }) end,
    keys = {
      { 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]] },
      { 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]] },
    },
  },
  {
    'itchyny/vim-highlighturl',
    event = 'ColorScheme',
    config = function() vim.g.highlighturl_guifg = highlight.get('URL', 'fg') end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'UIEnter',
    opts = {
      char = separators.left_thin_block,
      show_foldtext = false,
      context_char = separators.left_thin_block,
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
    opts = { char = separators.right_thin_block },
    init = function()
      rvim.augroup('VirtCol', {
        event = { 'VimEnter', 'BufEnter', 'WinEnter' },
        command = function(args)
          decorations.set_colorcolumn(
            args.buf,
            function(virtcolumn) require('virt-column').setup_buffer({ virtcolumn = virtcolumn }) end
          )
        end,
      })
    end,
  },
}
