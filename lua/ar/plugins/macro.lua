local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'jake-stewart/recursive-macro.nvim',
    cond = function() return ar.get_plugin_cond('recursive-macro.nvim', not minimal) end,
    event = 'VeryLazy',
    init = function()
      vim.g.whichkey_add_spec({
        { '<localleader>q', desc = 'recursive-macro: start recording' },
      })
    end,
    opts = {
      registers = { 'q', 'w', 'e', 'r', 't', 'y' },
      startMacro = ',q',
      replayMacro = 'Q',
    },
  },
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'ecthelionvi/NeoComposer.nvim',
    init = function()
      vim.g.whichkey_add_spec({
        { '<localleader>q', group = 'NeoComposer' },
        { '<localleader>qr', desc = 'neocomposer: toggle record' },
        { '<localleader>qy', desc = 'neocomposer: yank macro' },
        { '<localleader>qs', desc = 'neocomposer: stop macro' },
        { '<localleader>qn', desc = 'neocomposer: cycle next' },
        { '<localleader>qp', desc = 'neocomposer: cycle prev' },
        { '<localleader>qm', desc = 'neocomposer: toggle menu' },
      })
      vim.g.whichkey_add_spec({
        '<localleader>qq',
        desc = 'neocomposer: play macro',
        mode = { 'n', 'x' },
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
