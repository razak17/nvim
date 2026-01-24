local minimal = ar.plugins.minimal
local tiny_diags_disabled_by_nes = false

return {
  {
    'folke/sidekick.nvim',
    cond = function()
      local condition = ar.ai.enable
      return ar.get_plugin_cond('sidekick.nvim', condition)
    end,
    lazy = true,
    opts = {
      nes = {
        enabled = true,
      },
      mux = {
        backend = 'tmux',
        enabled = true,
      },
      cli = {
        win = {
          keys = {
            stopinsert = { '<esc>', 'stopinsert', mode = 't' }, -- enter normal mode
            win_p = { '<M-Left>', 'blur' },
          },
        },
      },
    },
    init = function()
      vim.g.whichkey_add_spec({
        '<leader>as',
        group = 'Sidekick',
        mode = { 'n', 'x' },
      })
    end,
    keys = {
      {
        '<leader>aso',
        function() require('sidekick.cli').toggle() end,
        desc = 'sidekick: toggle cli',
      },
      {
        '<leader>asw',
        function() require('sidekick.cli').select() end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = 'sidekick: select cli',
      },
      {
        '<leader>ass',
        function() require('sidekick.cli').send({ msg = '{this}' }) end,
        mode = { 'x', 'n' },
        desc = 'sidekick: send this',
      },
      {
        '<leader>asv',
        function() require('sidekick.cli').send({ msg = '{selection}' }) end,
        mode = { 'x' },
        desc = 'sidekick: send visual selection',
      },
      {
        '<leader>asp',
        function() require('sidekick.cli').prompt() end,
        mode = { 'n', 'x' },
        desc = 'sidekick: select prompt',
      },
      {
        '<leader>asf',
        function() require('sidekick.cli').send({ msg = '{file}' }) end,
        desc = 'sidekick: send file',
      },
      {
        '<c-.>',
        function() require('sidekick.cli').toggle() end,
        mode = { 'n', 't', 'i', 'x' },
        desc = 'sidekick: toggle',
      },
    },
    config = function(_, opts)
      require('sidekick').setup(opts)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'SidekickNesHide',
        callback = function()
          if tiny_diags_disabled_by_nes then
            tiny_diags_disabled_by_nes = false
            require('tiny-inline-diagnostic').enable()
          end
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'SidekickNesShow',
        callback = function()
          tiny_diags_disabled_by_nes = true
          require('tiny-inline-diagnostic').disable()
        end,
      })
    end,
  },
  {
    'folke/snacks.nvim',
    optional = true,
    opts = {
      picker = {
        actions = {
          sidekick_send = function(...)
            return require('sidekick.cli.picker.snacks').send(...)
          end,
        },
        win = {
          input = {
            keys = {
              ['<a-a>'] = {
                'sidekick_send',
                mode = { 'n', 'i' },
              },
            },
          },
        },
      },
    },
  },
}
