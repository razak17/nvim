---@diagnostic disable: missing-fields
local minimal = ar.plugins.minimal
local niceties = ar.plugins.niceties

return {
  {
    'Goose97/timber.nvim',
    cond = not minimal and niceties,
    event = 'VeryLazy',
    opts = {
      keymaps = {
        insert_log_below = '<leader>p;j',
        insert_log_above = '<leader>p;k',
        insert_batch_log = '<leader>p;b',
        add_log_targets_to_batch = 'g;a',
        insert_log_below_operator = 'g<S-l>j',
        insert_log_above_operator = 'g<S-l>k',
        insert_batch_log_operator = 'g<S-l>b',
        add_log_targets_to_batch_operator = 'g<S-l>a',
      },
    },
    config = function(_, opts) require('timber').setup(opts) end,
  },
  {
    'chrisgrieser/nvim-chainsaw',
    cond = not minimal,
    config = function()
      require('chainsaw').setup({ marker = '[🪲 chainsaw]' })
    end,
    init = function()
      require('which-key').add({ { '<leader>pl', group = 'Chainsaw' } })
    end,
    keys = {
      {
        '<leader>pll',
        function() require('chainsaw').messageLog() end,
        desc = 'message log',
      },
      {
        '<leader>plo',
        function() require('chainsaw').objectLog() end,
        desc = 'object log',
      },
      {
        '<leader>plp',
        function() require('chainsaw').variableLog() end,
        desc = 'variable log',
      },
      {
        '<leader>plb',
        function() require('chainsaw').beepLog() end,
        desc = 'beep log',
      },
      {
        '<leader>plr',
        function() require('chainsaw').removeLogs() end,
        desc = 'remove logs',
      },
    },
  },
  {
    'kungfusheep/randomword.nvim',
    cond = not minimal and niceties,
    event = 'VeryLazy',
    config = function()
      local js = {
        default = 'console.log("<word>", <cursor>)',
        line = 'console.log("<word>")',
      }
      require('randomword').setup({
        templates = {
          lua = {
            default = 'print(string.format("<word> %s", <cursor>))',
            line = "print('<word>')",
          },
          go = {
            default = 'fmt.Printf("<word>: %v \\n", <cursor>)',
            line = 'fmt.Println("<word>")',
          },
          python = {
            default = 'print(string.format("<word> %s", <cursor>))',
            line = "print('<word>')",
          },
          javascript = js,
          javascriptreact = js,
          typescript = js,
          typescriptreact = js,
        },
        keybinds = {
          default = '<leader>pd',
          line = '<leader>pc',
        },
      })
    end,
  },
  {
    'andrewferrier/debugprint.nvim',
    event = 'VeryLazy',
    opts = {
      keymaps = {
        normal = {
          plain_below = 'g?p',
          plain_above = 'g?P',
          variable_below = 'g?v',
          variable_above = 'g?V',
          variable_below_alwaysprompt = 'g?a',
          variable_above_alwaysprompt = 'g?A',
          textobj_below = 'g?o',
          textobj_above = 'g?O',
          toggle_comment_debug_prints = 'g?u',
          delete_debug_prints = 'g?x',
        },
        insert = {
          plain = '<C-g>p',
          variable = '<C-g>v',
        },
        visual = {
          variable_below = 'g?v',
          variable_above = 'g?V',
        },
      },
      commands = {
        toggle_comment_debug_prints = 'ToggleCommentDebugPrints',
        delete_debug_prints = 'DeleteDebugPrints',
        reset_debug_prints_counter = 'ResetDebugPrintsCounter',
      },
    },
  },
}
