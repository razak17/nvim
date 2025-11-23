local minimal = ar.plugins.minimal

return {
  {
    'tyru/capture.vim',
    cmd = { 'Capture' },
    cond = function() return ar.get_plugin_cond('capture.vim') end,
  },
  {
    'ariel-frischer/bmessages.nvim',
    cond = function() return ar.get_plugin_cond('bmessages.nvim', not minimal) end,
    cmd = { 'Bmessages', 'Bmessagesvs', 'Bmessagessp', 'BmessagesEdit' },
    event = 'CmdlineEnter',
    opts = {},
  },
  {
    'smjonas/live-command.nvim',
    cond = function()
      return ar.get_plugin_cond('live-command.nvim', not minimal)
    end,
    event = 'VeryLazy',
    opts = {
      commands = {
        Norm = { cmd = 'norm' },
        G = { cmd = 'g' },
        D = { cmd = 'd' },
        LSubvert = { cmd = 'Subvert' },
      },
    },
    config = function(_, opt) require('live-command').setup(opt) end,
  },
}
