local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties
local augroup, ui = ar.augroup, ar.ui

return {
  {
    'delphinus/auto-cursorline.nvim',
    cond = not minimal and niceties,
    event = { 'BufRead', 'CursorMoved', 'CursorMovedI', 'WinEnter', 'WinLeave' },
    init = function()
      augroup('auto_cursorline', {
        event = 'FileType',
        command = function(args)
          if not ui.show_cursorline(args.buf) then
            require('auto-cursorline').disable({ buffer = args.buf })
          end
        end,
      })
    end,
    opts = { wait_ms = '300' },
  },
  -- NOTE::use fork until PR is merged: https://github.com/tummetott/reticle.nvim/pull/13
  {
    -- 'tummetott/reticle.nvim',
    'razak17/reticle.nvim',
    cond = not minimal and not niceties, -- auto-cursorline kinda does this already
    event = { 'BufRead', 'BufNewFile' },
    init = function()
      augroup('reticle', {
        event = {
          'BufRead',
          'BufEnter',
          -- 'FocusGained',
          -- 'CmdlineLeave',
          -- 'InsertLeave',
          'WinEnter',
          -- 'FileType',
        },
        command = function(args)
          if not ui.show_cursorline then return end
          if not ui.show_cursorline(args.buf) then
            require('reticle').set_cursorline(false)
            return
          end
          require('reticle').set_cursorline(true)
        end,
      })
    end,
    opts = {
      ignore = {
        cursorline = { 'neo-tree-popup' },
      },
    },
  },
}
