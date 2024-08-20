local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'jake-stewart/recursive-macro.nvim',
    cond = not minimal,
    event = 'VeryLazy',
    opts = {
      registers = { 'q', 'w', 'e', 'r', 't', 'y' },
      startMacro = 'q',
      replayMacro = 'Q',
    },
  },
  {
    'ecthelionvi/NeoComposer.nvim',
    init = function()
      require('which-key').add({
        { '<localleader>qr', desc = 'neocomposer: toggle record' },
        { '<localleader>qq', desc = 'neocomposer: play macro' },
        { '<localleader>qy', desc = 'neocomposer: yank macro' },
        { '<localleader>qs', desc = 'neocomposer: stop macro' },
        { '<localleader>qn', desc = 'neocomposer: cycle next' },
        { '<localleader>qp', desc = 'neocomposer: cycle prev' },
        { '<localleader>qm', desc = 'neocomposer: toggle menu' },
      })
      require('which-key').add({
        mode = { 'x' },
        { '<localleader>qq', desc = 'neocomposer: play macro' },
      })
    end,
    enabled = false,
    cond = not minimal and niceties and false,
    event = { 'BufReadPost', 'BufNewFile' },
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
    end,
  },
}
