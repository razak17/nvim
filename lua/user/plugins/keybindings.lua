return {
  {
    'folke/which-key.nvim',
    init = function()
      local which_key = require('which-key')

      which_key.setup({
        plugins = {
          spelling = { enabled = true },
        },
        icons = { breadcrumb = rvim.ui.icons.misc.double_chevron_right },
        window = { border = rvim.ui.current.border },
        layout = { align = 'center' },
        hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ' },
        show_help = true,
      })

      which_key.register({
        [']'] = {
          name = 'next',
          ['<space>'] = 'add space below',
        },
        ['['] = {
          name = 'prev',
          ['<space>'] = 'add space above',
        },
        ['<leader>'] = {
          a = { name = 'A.I.' },
          d = { name = 'Debugprint' },
          f = { name = 'Telescope' },
          fg = { name = 'Git' },
          fv = { name = 'Vim' },
          g = { name = 'Git' },
          h = { name = 'Gitsigns' },
          i = { name = 'Toggler' },
          l = { name = 'Lsp' },
          lt = { name = 'Toggle' },
          m = { name = 'Marks' },
          n = { name = 'Notify' },
          o = { name = 'Toggle' },
          r = { name = 'Run' },
          s = { name = 'Session' },
          t = { name = 'Test' },
        },
        ['<localleader>'] = {
          c = { name = 'Conceal' },
          d = { name = 'Dap' },
          g = { name = 'Git' },
          l = { name = 'Neogen' },
          n = { name = 'Neorg' },
          r = { name = 'Rest' },
          s = { name = 'Sniprun' },
          w = { name = 'Window' },
        },
      })

      which_key.register({
        l = 'lsp',
      }, { mode = 'x', prefix = '<leader>' })

      which_key.register({
        g = 'git',
      }, { mode = 'x', prefix = '<localleader>' })

      rvim.augroup('WhichKeyMode', {
        event = { 'FileType' },
        pattern = { 'which_key' },
        command = 'set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2',
      })
    end,
  },
  {
    'anuvyklack/hydra.nvim',
    enabled = not rvim.plugins.minimal,
    event = 'VeryLazy',
    config = function()
      local Hydra = require('hydra')
      local pcmd = require('hydra.keymap-util').pcmd
      local hint_opts = { position = 'bottom', border = rvim.ui.current.border, type = 'window' }

      local splits = rvim.reqcall('smart-splits')
      local fold_cycle = rvim.reqcall('fold-cycle')

      local base_config = function(opts)
        return vim.tbl_extend('force', {
          invoke_on_body = true,
          hint = hint_opts,
        }, opts or {})
      end

      Hydra({
        name = 'Folds',
        mode = 'n',
        body = '<leader>z',
        color = 'teal',
        config = base_config(),
        heads = {
          { 'j', 'zj', { desc = 'next fold' } },
          { 'k', 'zk', { desc = 'previous fold' } },
          { 'l', fold_cycle.open_all, { desc = 'open folds underneath' } },
          { 'h', fold_cycle.close_all, { desc = 'close folds underneath' } },
          { '<Esc>', nil, { exit = true, desc = 'Quit' } },
        },
      })

      Hydra({
        name = 'Buffer management',
        mode = 'n',
        body = '<leader>b',
        color = 'teal',
        config = base_config(),
        heads = {
          { 'a', '<Cmd>BWipeout! all<CR>', { desc = 'close all' } },
          { 'c', '<Cmd>BWipeout other<CR>', { desc = 'delete others' } },
          { 'd', '<Cmd>BDelete this<CR>', { desc = 'delete buffer' } },
          { 'p', '<Plug>(CybuPrev)', { desc = 'prev buffer' } },
          { 'n', '<Plug>(CybuNext)', { desc = 'next buffer' } },
          { '<Esc>', nil, { exit = true, desc = 'Quit' } },
        },
      })

      Hydra({
        name = 'Side scroll',
        mode = 'n',
        body = 'z',
        config = base_config({ invoke_on_body = false }),
        heads = {
          { 'h', '5zh' },
          { 'l', '5zl', { desc = '←/→' } },
          { 'H', 'zH' },
          { 'L', 'zL', { desc = 'half screen ←/→' } },
        },
      })

      local window_hint = [[
      ^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split
      ^^^^^^^^^^^^-------------  ^^-----------^^   ^^---------------
      ^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally 
      _h_ ^ ^ _l_  _H_ ^ ^ _L_   _<C-h>_ _<C-l>_   _v_: vertically
      ^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _q_, _c_: close
      focus^^^^^^  window^^^^^^  ^_=_: equalize^   _o_: remain only
      ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^
      ]]

      Hydra({
        name = 'Window management',
        hint = window_hint,
        config = base_config({ invoke_on_body = false }),
        mode = 'n',
        body = '<C-w>',
        heads = {
          --- Move
          { 'h', '<C-w>h' },
          { 'j', '<C-w>j' },
          { 'k', pcmd('wincmd k', 'E11', 'close') },
          { 'l', '<C-w>l' },

          { 'o', '<C-w>o', { exit = true, desc = 'remain only' } },
          { '<C-o>', '<C-w>o', { exit = true, desc = false } },
          -- Resize
          { '<C-h>', function() splits.resize_left(2) end },
          { '<C-j>', function() splits.resize_down(2) end },
          { '<C-k>', function() splits.resize_up(2) end },
          { '<C-l>', function() splits.resize_right(2) end },
          { '=', '<C-w>=', { desc = 'equalize' } },
          -- Split
          { 's', pcmd('split', 'E36') },
          { '<C-s>', pcmd('split', 'E36'), { desc = false } },
          { 'v', pcmd('vsplit', 'E36') },
          { '<C-v>', pcmd('vsplit', 'E36'), { desc = false } },
          -- Size
          { 'H', function() splits.swap_buf_left() end },
          { 'J', function() splits.swap_buf_down() end },
          { 'K', function() splits.swap_buf_up() end },
          { 'L', function() splits.swap_buf_right() end },

          { 'c', pcmd('close', 'E444') },
          { 'q', pcmd('close', 'E444'), { desc = 'close window' } },
          { '<C-c>', pcmd('close', 'E444'), { desc = false } },
          { '<C-q>', pcmd('close', 'E444'), { desc = false } },
          --
          { '<Esc>', nil, { exit = true } },
        },
      })

      Hydra({
        name = 'Wrap',
        mode = 'n',
        body = '<leader>w',
        color = 'teal',
        config = {
          hint = hint_opts,
          invoke_on_body = true,
        },
        heads = {
          { '"', [[ciw"<c-r>""<esc>]], { desc = 'double quotes' } },
          { "'", [[ciw'<c-r>"'<esc>]], { desc = 'single quotes' } },
          { '`', [[ciw`<c-r>"`<esc>]], { desc = 'backticks' } },
          { '|', [[ciw|<c-r>"|<esc>]], { desc = 'pipe' } },
          { ')', [[ciw(<c-r>")<esc>]], { desc = 'parenthesis' } },
          { '}', [[ciw{<c-r>"}<esc>]], { desc = 'curly bracket' } },
          { ']', [[ciw[<c-r>"]<esc>]], { desc = 'square bracket' } },
          { '<Esc>', nil, { exit = true, desc = 'Quit' } },
        },
      })
    end,
  },
}
