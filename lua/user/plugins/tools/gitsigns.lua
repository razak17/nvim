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
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function bmap(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      map('n', '<leader>hs', gs.stage_hunk, { desc = 'stage hunk' })
      map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage' })
      map('n', '<leader>hw', gs.toggle_word_diff, { desc = 'toggle word diff' })
      map('n', '<leader>hd', gs.toggle_deleted, { desc = 'show deleted lines' })
      map('n', '<leader>hp', gs.preview_hunk_inline, { desc = 'preview hunk' })

      map('n', '<leader>gb', gs.blame_line, { desc = 'blame current line' })
      map('n', '<leader>gr', gs.reset_buffer, { desc = 'reset entire buffer' })
      map('n', '<leader>gw', gs.stage_buffer, { desc = 'stage entire buffer' })

      map(
        'n',
        '<leader>gl',
        function() gs.setqflist('all') end,
        { desc = 'list modified in quickfix' }
      )
      bmap({ 'n', 'v' }, '<leader>hs', '<Cmd>Gitsigns stage_hunk<CR>', { desc = 'stage hunk' })
      bmap({ 'n', 'v' }, '<leader>hr', '<Cmd>Gitsigns reset_hunk<CR>', { desc = 'reset hunk' })
      bmap({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select hunk' })

      map('n', '<leader>hj', function()
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, { expr = true, desc = 'next hunk' })

      map('n', '<leader>hk', function()
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, { expr = true, desc = 'previous hunk' })
    end,
  },
}
