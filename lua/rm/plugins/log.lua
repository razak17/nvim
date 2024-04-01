return {
  {
    'chrisgrieser/nvim-chainsaw',
    config = function()
      require('chainsaw').setup({ marker = '[🪲 chainsaw]' })
    end,
    keys = {
      {
        '<leader>pll',
        function() require('chainsaw').messageLog() end,
        desc = 'Message Log',
      },
      {
        '<leader>plo',
        function() require('chainsaw').objectLog() end,
        desc = 'Object Log',
      },
      {
        '<leader>plv',
        function() require('chainsaw').variableLog() end,
        desc = 'Variable Log',
      },
      {
        '<leader>plb',
        function() require('chainsaw').beepLog() end,
        desc = 'Beep Log',
      },
      {
        '<leader>plr',
        function() require('chainsaw').removeLogs() end,
        desc = 'Remove Logs',
      },
    },
  },
  {
    'kungfusheep/randomword.nvim',
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
    cond = rvim.treesitter.enable,
    keys = {
      {
        '<leader>pp',
        function() return require('debugprint').debugprint({ variable = true }) end,
        expr = true,
        desc = 'debugprint: cursor',
      },
      {
        '<leader>pP',
        function()
          return require('debugprint').debugprint({
            above = true,
            variable = true,
          })
        end,
        expr = true,
        desc = 'debugprint: cursor (above)',
      },
      {
        '<leader>pi',
        function()
          return require('debugprint').debugprint({
            ignore_treesitter = true,
            variable = true,
          })
        end,
        expr = true,
        desc = 'debugprint: prompt',
      },
      {
        '<leader>pI',
        function()
          return require('debugprint').debugprint({
            ignore_treesitter = true,
            above = true,
            variable = true,
          })
        end,
        expr = true,
        desc = 'debugprint:prompt (above)',
      },
      {
        '<leader>po',
        function() return require('debugprint').debugprint({ motion = true }) end,
        expr = true,
        desc = 'debugprint: operator',
      },
      {
        '<leader>pO',
        function()
          return require('debugprint').debugprint({
            above = true,
            motion = true,
          })
        end,
        expr = true,
        desc = 'debugprint: operator (above)',
      },
      {
        '<leader>px',
        '<Cmd>DeleteDebugPrints<CR>',
        desc = 'debugprint: clear all',
      },
    },
    opts = { create_keymaps = false },
    config = function(opts)
      require('debugprint').setup(opts)

      local svelte = {
        left = 'console.log("',
        right = '")',
        mid_var = '", ',
        right_var = ')',
      }
      local python = {
        left = 'print(f"',
        right = '"',
        mid_var = '{',
        right_var = '}")',
      }
      local js = {
        left = 'console.log("',
        right = '")',
        mid_var = '", ',
        right_var = ')',
      }
      require('debugprint').add_custom_filetypes({
        python = python,
        svelte = svelte,
        javascript = js,
        javascriptreact = js,
        typescript = js,
        typescriptreact = js,
        tsx = js,
      })
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
}
