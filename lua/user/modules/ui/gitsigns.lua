local M = { 'lewis6991/gitsigns.nvim', event = 'BufReadPre' }

function M.config()
  local cwd = vim.fn.getcwd()
  require('gitsigns').setup({
    signs = {
      add = { hl = 'GitSignsAdd', text = '▋' },
      change = { hl = 'GitSignsChange', text = '▋' },
      delete = { hl = 'GitSignsDelete', text = '▋' },
      topdelete = { hl = 'GitSignsChangeDelete', text = '▔' },
      changedelete = { hl = 'GitSignsChange', text = '▎' },
      untracked = { hl = 'GitSignsAdd', text = '▋' },
    },
    _threaded_diff = true, -- NOTE: experimental but I'm curious
    word_diff = false,
    current_line_blame = not cwd:match('personal') and not cwd:match('dots'),
    current_line_blame_formatter = ' <author>, <author_time> · <summary>',
    numhl = false,
    preview_config = {
      border = rvim.style.border.current,
    },
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
      nnoremap('<leader>hr', gs.reset_hunk, 'reset hunk')
      nnoremap('<leader>hs', gs.stage_hunk, 'stage hunk')
      nnoremap('<leader>hu', gs.undo_stage_hunk, 'undo stage')
      nnoremap('<leader>hw', gs.toggle_word_diff, 'toggle word diff')

      nnoremap('<leader>gL', qf_list_modified, 'gitsigns: list modified in quickfix')
      nnoremap('<leader>gb', gs.blame_line, 'gitsigns: blame current line')
      nnoremap('<localleader>gr', gs.reset_buffer, 'gitsigns: reset entire buffer')
      nnoremap('<localleader>gw', gs.stage_buffer, 'gitsigns: stage entire buffer')

      vnoremap('<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
      vnoremap('<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end)
      vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end,
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    sign_priority = 6,
    update_debounce = 200,
    status_formatter = nil, -- Use default
  })
end

return M
