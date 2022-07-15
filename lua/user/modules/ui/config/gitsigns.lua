return function()
  local cwd = vim.fn.getcwd()
  local gitsigns_ok, gitsigns = rvim.safe_require('gitsigns')
  if not gitsigns_ok then return end

  rvim.gitsigns = {
    setup = {
      signs = {
        add = { hl = 'GitGutterAdd', text = '▋' },
        change = { hl = 'GitGutterChange', text = '▋' },
        delete = { hl = 'GitGutterDelete', text = '▋' },
        topdelete = { hl = 'GitGutterDeleteChange', text = '▔' },
        changedelete = { hl = 'GitGutterChange', text = '▎' },
      },
      _threaded_diff = true, -- NOTE: experimental but I'm curious
      word_diff = false,
      current_line_blame = not cwd:match('personal') and not cwd:match('dotfiles'),
      numhl = false,
      preview_config = {
        border = rvim.style.border.current,
      },
      on_attach = function()
        local gs = package.loaded.gitsigns

        local function qf_list_modified() gs.setqflist('all') end

        require('which-key').register({
          ['<leader>h'] = {
            name = '+Gitsigns',
            d = { gs.toggle_deleted, 'show deleted lines' },
            j = { gs.next_hunk, 'Next Hunk' },
            k = { gs.prev_hunk, 'Prev Hunk' },
            p = { gs.preview_hunk, 'preview hunk' },
            r = { gs.reset_hunk, 'reset current hunk' },
            s = { gs.stage_hunk, 'stage current hunk' },
            u = { gs.undo_stage_hunk, 'undo stage' },
            w = { gs.toggle_word_diff, 'toggle word diff' },
          },
          ['<leader>g'] = {
            name = '+git',
            b = { gs.blame_line, 'gitsigns: blame' },
            m = { qf_list_modified, 'gitsigns: list modified in quickfix' },
            r = {
              name = '+reset',
              e = { gs.reset_buffer, 'gitsigns: reset entire buffer' },
            },
            w = { gs.stage_buffer, 'gitsigns: stage entire buffer' },
          },
        })
      end,
      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },
      sign_priority = 6,
      update_debounce = 200,
      status_formatter = nil, -- Use default
    },
  }

  gitsigns.setup(rvim.gitsigns.setup)

  rvim.vnoremap(
    '<leader>hs',
    function() gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end
  )
  rvim.vnoremap(
    '<leader>hr',
    function() gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end
  )
  vim.keymap.set({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
end
