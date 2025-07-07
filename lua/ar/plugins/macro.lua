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
}
