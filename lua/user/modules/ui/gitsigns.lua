local cwd = vim.fn.getcwd()
local icons = rvim.ui.icons.separators

return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {
    signs = {
      add = { hl = 'GitSignsAdd', text = icons.right_block },
      change = { hl = 'GitSignsChange', text = icons.right_block },
      delete = { hl = 'GitSignsDelete', text = icons.right_block },
      topdelete = { hl = 'GitSignsChangeDelete', text = icons.right_block },
      changedelete = { hl = 'GitSignsChange', text = icons.right_block },
      untracked = { hl = 'GitSignsAdd', text = icons.right_block },
    },
    _threaded_diff = true,
    _extmark_signs = false,
    _signs_staged_enable = true,
    word_diff = false,
    numhl = false,
    current_line_blame = not cwd:match('personal') and not cwd:match('dots'),
    current_line_blame_formatter = ' <author>, <author_time> · <summary>',
    preview_config = { border = rvim.ui.current.border },
    on_attach = function()
      local gs = package.loaded.gitsigns

      local function qf_list_modified() gs.setqflist('all') end

      map('n', '<leader>hd', gs.toggle_deleted, { desc = 'show deleted lines' })
      map(
        'n',
        '<leader>hj',
        function() gs.next_hunk({ navigation_message = false }) end,
        { desc = 'next hunk' }
      )
      map(
        'n',
        '<leader>hk',
        function() gs.prev_hunk({ navigation_message = false }) end,
        { desc = 'prev hunk' }
      )
      map('n', '<leader>hp', gs.preview_hunk_inline, { desc = 'preview hunk' })
      map(
        'n',
        '<leader>hr',
        function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
        { desc = 'reset hunk' }
      )
      map('n', '<leader>hs', gs.stage_hunk, { desc = 'stage hunk' })
      map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage' })
      map('n', '<leader>hw', gs.toggle_word_diff, { desc = 'toggle word diff' })

      map('n', '<leader>gL', qf_list_modified, { desc = 'gitsigns: list modified in quickfix' })
      map('n', '<leader>gb', gs.blame_line, { desc = 'gitsigns: blame current line' })
      map('n', '<leader>gr', gs.reset_buffer, { desc = 'gitsigns: reset entire buffer' })
      map('n', '<leader>gw', gs.stage_buffer, { desc = 'gitsigns: stage entire buffer' })

      map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
      map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
      vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
  },
}
