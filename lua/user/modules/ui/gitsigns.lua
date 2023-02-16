local M = {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
}

function M.config()
  local cwd = vim.fn.getcwd()
  local right_block = '🮉'
  require('gitsigns').setup({
    signs = {
      add = { hl = 'GitSignsAdd', text = right_block },
      change = { hl = 'GitSignsChange', text = right_block },
      delete = { hl = 'GitSignsDelete', text = right_block },
      topdelete = { hl = 'GitSignsChangeDelete', text = right_block },
      changedelete = { hl = 'GitSignsChange', text = right_block },
      untracked = { hl = 'GitSignsAdd', text = right_block },
    },
    current_line_blame = not cwd:match('personal') and not cwd:match('dots'),
    current_line_blame_formatter = ' <author>, <author_time> · <summary>',
    preview_config = { border = rvim.ui.current.border },
    on_attach = function()
      local gs = package.loaded.gitsigns

      local function qf_list_modified() gs.setqflist('all') end
      local nnoremap, vnoremap = rvim.nnoremap, rvim.vnoremap

      nnoremap('<leader>hd', gs.toggle_deleted, 'show deleted lines')
      nnoremap(
        '<leader>hj',
        function() gs.next_hunk({ navigation_message = false }) end,
        'next hunk'
      )
      nnoremap(
        '<leader>hk',
        function() gs.prev_hunk({ navigation_message = false }) end,
        'prev hunk'
      )
      nnoremap('<leader>hp', gs.preview_hunk_inline, 'preview hunk')
      nnoremap(
        '<leader>hr',
        function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
        'reset hunk'
      )
      nnoremap('<leader>hs', gs.stage_hunk, 'stage hunk')
      nnoremap('<leader>hu', gs.undo_stage_hunk, 'undo stage')
      nnoremap('<leader>hw', gs.toggle_word_diff, 'toggle word diff')

      nnoremap('<leader>gL', qf_list_modified, 'gitsigns: list modified in quickfix')
      nnoremap('<leader>gb', gs.blame_line, 'gitsigns: blame current line')
      nnoremap('<leader>gr', gs.reset_buffer, 'gitsigns: reset entire buffer')
      nnoremap('<leader>gw', gs.stage_buffer, 'gitsigns: stage entire buffer')

      vnoremap('<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
      vnoremap('<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
      vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
  })
end

return M
