return {
  {
    'jake-stewart/recursive-macro.nvim',
    cond = not rvim.plugins.minimal,
    event = 'VeryLazy',
    opts = {
      registers = { 'q', 'w', 'e', 'r', 't', 'y' },
      startMacro = 'q',
      replayMacro = 'Q',
    },
  },
  {
    'ecthelionvi/NeoComposer.nvim',
    cond = not rvim.plugins.minimal,
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'kkharji/sqlite.lua' },
    -- stylua: ignore
    keys = {
      { '<localleader>qe', "<cmd>lua require('NeoComposer.ui').edit_macros()<cr>", desc = 'neocomposer: edit macro ', },
      { '<localleader>qt', "<cmd>lua require('NeoComposer.macro').toggle_delay()<cr>", desc = 'neocomposer: delay macro toggle', },
      { '<localleader>qd', "<cmd>lua require('NeoComposer.store').clear_macros()<cr>", desc = 'neocomposer: delete all macros', },
    },
    config = function()
      require('NeoComposer').setup({
        notify = false,
        keymaps = {
          toggle_record = '<localleader>qr',
          play_macro = '<localleader>qq',
          yank_macro = '<localleader>qy',
          stop_macro = '<localleader>qs',
          cycle_next = '<localleader>qn',
          cycle_prev = '<localleader>qp',
          toggle_macro_menu = '<localleader>qm',
        },
      })
      if rvim.is_available('which-key.nvim') then
        require('which-key').register({
          ['<localleader>qr'] = 'neocomposer: toggle record',
          ['<localleader>qq'] = 'neocomposer: play macro',
          ['<localleader>qy'] = 'neocomposer: yank macro',
          ['<localleader>qs'] = 'neocomposer: stop macro',
          ['<localleader>qn'] = 'neocomposer: cycle next',
          ['<localleader>qp'] = 'neocomposer: cycle prev',
          ['<localleader>qm'] = 'neocomposer: toggle menu',
        })
        require('which-key').register({
          qq = 'neocomposer: play macro',
        }, { mode = 'x', prefix = '<localleader>' })
      end
    end,
  },
}
