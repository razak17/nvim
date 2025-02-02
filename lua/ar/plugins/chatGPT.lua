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

      ar.add_to_select_menu('ai', {
        ['chatGPT'] = function()
          ar.create_select_menu('chatGPT', {
            ['Open Prompt'] = 'ChatGPT',
            ['Fix Bugs'] = 'ChatGPTRun fix_bugs',
            ['Explain Code'] = 'ChatGPTRun explain_code',
            ['Optimize Code'] = 'ChatGPTRun optimize_code',
            ['Act As'] = 'ChatGPTActAs',
            ['Add Tests'] = 'ChatGPTRun add_tests',
            ['Complete Code'] = 'ChatGPTRun complete_code',
            ['Docstring'] = 'ChatGPTRun docstring',
            ['Grammar Correction'] = 'ChatGPTRun grammar_correction',
            ['Keywords'] = 'ChatGPTRun keywords',
            ['Code Readability Analysis'] = 'ChatGPTRun code_readability_analysis',
            ['Translate'] = 'ChatGPTRun translate',
          })()
        end,
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
