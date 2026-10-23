ar.pack.add({
  {
    src = 'https://github.com/rachartier/tiny-cmdline.nvim',
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
    setup = function()
      local opts = { position = { x = '50%', y = '10%' } }
      local is_blink = ar.config.completion.variant == 'blink'
      if ar.completion.enable and is_blink then
        opts.on_reposition = require('tiny-cmdline').adapters.blink
      end
      require('tiny-cmdline').setup(opts)
    end,
  },
  {
    src = 'https://github.com/tyru/capture.vim',
    cmd = { 'Capture' },
    cond = function() return ar.get_plugin_cond('capture.vim') end,
  },
  {
    src = 'https://github.com/ariel-frischer/bmessages.nvim',
    cond = function()
      return ar.get_plugin_cond('bmessages.nvim', not ar.plugins.minimal)
    end,
    cmd = { 'Bmessages', 'Bmessagesvs', 'Bmessagessp', 'BmessagesEdit' },
    event = 'CmdlineEnter',
    setup = function() require('bmessages').setup({}) end,
  },
  {
    src = 'https://github.com/smjonas/live-command.nvim',
    cond = function()
      return ar.get_plugin_cond('live-command.nvim', not ar.plugins.minimal)
    end,
    event = 'VeryLazy',
    setup = function()
      require('live-command').setup({
        commands = {
          Norm = { cmd = 'norm' },
          G = { cmd = 'g' },
          D = { cmd = 'd' },
          LSubvert = { cmd = 'Subvert' },
        },
      })
    end,
  },
})
