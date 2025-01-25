return {
  {
    'jackMort/ChatGPT.nvim',
    cond = not ar.plugins.minimal
      and ar.ai.enable
      and ar_config.ai.models.openai,
    cmd = {
      'ChatGPT',
      'ChatGPTActAs',
      'ChatGPTRun',
      'ChatGPTEditWithInstructions',
    },
    init = function()
      vim.g.whichkey_add_spec({ '<leader>ag', group = 'chatGPT' })

      ar.add_to_menu('ai', {
        ['ChatGPT Prompt'] = 'ChatGPT',
        ['ChatGPT Fix Bugs'] = 'ChatGPTRun fix_bugs',
        ['ChatGPT Explain Code'] = 'ChatGPTRun explain_code',
        ['ChatGPT Optimize Code'] = 'ChatGPTRun optimize_code',
      })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>aga', '<cmd>ChatGPTActAs<CR>', desc = 'chatgpt: act as' },
      { '<leader>age', '<cmd>ChatGPTEditWithInstructions<CR>', desc = 'chatgpt: edit', },
      { '<leader>agn', '<cmd>ChatGPT<CR>', desc = 'chatgpt: open' },
    },
    opts = function()
      local border = {
        style = ar.ui.border.rectangle,
        highlight = 'FloatBorder',
      }

      return {
        edit_with_instructions = {
          keymaps = { close = '<Esc>' },
        },
        popup_window = {
          border = border,
          win_options = {
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
          },
        },
        popup_input = {
          border = border,
          prompt = ' > ',
          submit = '<C-s>',
          win_options = {
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
          },
        },
        settings_window = {
          border = border,
          win_options = {
            winhighlight = 'Normal:Normal,FloatTitle:FloatTitle',
          },
        },
        chat = {
          loading_text = 'Cooking ...',
          keymaps = { close = { '<Esc>' } },
          sessions_window = {
            border = border,
            win_options = {
              winhighlight = 'Normal:Normal,FloatTitle:FloatTitle',
            },
          },
        },
      }
    end,
    config = function(_, opts)
      ar.highlight.plugin('ChatGPT.nvim', {
        theme = {
          ['onedark'] = {
            { ChatGPTSelectedMessage = { link = 'FloatTitle' } },
            -- { ChatGPTTotalTokensBorder = { link = 'FloatTitle' } },
            { ChatGPTCompletion = { link = 'FloatTitle' } },
          },
        },
      })

      require('chatgpt').setup(opts)
    end,
  },
}
