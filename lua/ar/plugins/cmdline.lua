local minimal = ar.plugins.minimal

return {
  {
    'rachartier/tiny-cmdline.nvim',
    cond = function()
      local condition = ar.config.ui.cmdline.variant == 'tiny-cmdline'
      return ar.get_plugin_cond('tiny-cmdline.nvim', condition)
    end,
    event = 'VeryLazy',
    init = function()
      vim.o.cmdheight = 0
      ar.highlight.plugin('TinyCmdline', {
        { TinyCmdlineNormal = { link = 'NormalFloat' } },
        { TinyCmdlineBorder = { link = 'FloatBorder' } },
      })
    end,
    opts = {},
    config = function(_, opts)
      local is_blink = ar.config.completion.variant == 'blink'
      if ar.completion.enable and is_blink then
        opts.on_reposition = require('tiny-cmdline').adapters.blink
      end
      require('tiny-cmdline').setup(opts)
    end,
  },
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
