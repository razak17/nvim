---@diagnostic disable: missing-fields
local minimal = ar.plugins.minimal
local niceties = ar.plugins.niceties

return {
  {
    'Goose97/timber.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('timber.nvim', condition)
    end,
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
    ft = 'lua', -- in lua, load directly for `Chainsaw` global
    cond = not minimal,
    opts = {
      marker = '🪲',
      visuals = { icon = '' },
    },
    init = function()
      vim.g.whichkey_add_spec({ '<leader>pl', group = 'Chainsaw' })
    end,
    keys = {
      -- stylua: ignore start
      { "<leader>pll", function() require("chainsaw").variableLog() end, mode = { "n", "x" }, desc = "󰀫 variable" },
      { "<leader>plo", function() require("chainsaw").objectLog() end, mode = { "n", "x" }, desc = "⬟ object" },
      { "<leader>pla", function() require("chainsaw").assertLog() end, mode = { "n", "x" }, desc = "󱈸 assert" },
      { "<leader>plt", function() require("chainsaw").typeLog() end, mode = { "n", "x" }, desc = "󰜀 type" },
      { "<leader>plm", function() require("chainsaw").messageLog() end, desc = "󰍩 message" },
      { "<leader>ple", function() require("chainsaw").emojiLog() end, desc = "󰞅 emoji" },
      { "<leader>pls", function() require("chainsaw").sound() end, desc = "󰂚 sound" },
      { "<leader>plp", function() require("chainsaw").timeLog() end, desc = "󱎫 performance" },
      { "<leader>pld", function() require("chainsaw").debugLog() end, desc = "󰃤 debugger" },
      { "<leader>plS", function() require("chainsaw").stacktraceLog() end, desc = " stacktrace" },
      { "<leader>plc", function() require("chainsaw").clearLog() end, desc = "󰃢 clear console" },
      { "<leader>plr", function() require("chainsaw").removeLogs() end, desc = "󰅗 remove logs" },
      -- stylua: ignore end
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
    cond = function() return ar.get_plugin_cond('debugprint.nvim') end,
    -- stylua: ignore
    keys = {
      'g?a', 'g?A',
      'g?o', 'g?O',
      'g?p', 'g?P',
      'g?sp', 'g?sv',
      'g?u', 'g?U',
      'g?v', 'g?V',
      'g?x',
    },
    opts = {
      keymaps = {
        normal = {
          plain_below = 'g?p',
          plain_above = 'g?P',
          variable_below = 'g?v',
          variable_above = 'g?V',
          variable_below_alwaysprompt = 'g?a',
          variable_above_alwaysprompt = 'g?A',
          surround_plain = 'g?sp',
          surround_variable = 'g?sv',
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
