return {
  {
    'robitx/gp.nvim',
    cond = rvim.ai.enable and not rvim.plugins.minimal,
    keys = {
      -- Chat commands
      {
        '<c-g>n',
        '<Cmd>GpChatNew<CR>',
        desc = 'gp: new chat',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>f',
        '<Cmd>GpChatFinder<CR>',
        desc = 'gp: find chat',
        mode = { 'n', 'i' },
      },
      {
        '<c-g><c-g>',
        '<Cmd>GpChatRespond<CR>',
        desc = 'gp: respond',
        mode = { 'n', 'i' },
      },
      {
        '<c-g>d',
        '<Cmd>GpChatDeleteCR>',
        desc = 'gp: delete chat',
        mode = { 'n', 'i' },
      },
      -- Prompt commands
      {
        '<c-g>i',
        '<Cmd>GpInline<CR>',
        desc = 'gp: inline',
        mode = { 'n', 'i' },
      },
      {
        '<c-g>r',
        '<Cmd>GpRewrite<CR>',
        desc = 'gp: rewrite',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>a',
        '<Cmd>GpAppend<CR>',
        desc = 'gp: append',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>b',
        '<Cmd>GpPrepend<CR>',
        desc = 'gp: prepend',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>e',
        '<Cmd>GpEnew<CR>',
        desc = 'gp: enew',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>p',
        '<Cmd>GpPopup<CR>',
        desc = 'gp: popup',
        mode = { 'n', 'i', 'v' },
      },
    },
    opts = {},
  },
  {
    'jackMort/ChatGPT.nvim',
    cond = rvim.ai.enable and not rvim.plugins.minimal,
    cmd = { 'ChatGPT', 'ChatGPTActAs', 'ChatGPTEditWithInstructions' },
    keys = {
      { '<leader>aa', '<cmd>ChatGPTActAs<CR>', desc = 'chatgpt: act as' },
      {
        '<leader>ae',
        '<cmd>ChatGPTEditWithInstructions<CR>',
        desc = 'chatgpt: edit',
      },
      { '<leader>an', '<cmd>ChatGPT<CR>', desc = 'chatgpt: open' },
    },
    config = function()
      rvim.highlight.plugin('ChatGPT.nvim', {
        theme = {
          ['onedark'] = {
            { ChatGPTSelectedMessage = { link = 'FloatTitle' } },
            -- { ChatGPTTotalTokensBorder = { link = 'FloatTitle' } },
            { ChatGPTCompletion = { link = 'FloatTitle' } },
          },
        },
      })

      local border = {
        style = rvim.ui.border.rectangle,
        highlight = 'FloatBorder',
      }
      require('chatgpt').setup({
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
      })
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
  },
  {
    'moozd/aidoc.nvim',
    cond = not rvim.plugins.minimal,
    keys = {
      {
        mode = 'x',
        '<leader>do',
        '<cmd>lua require("aidoc.api").generate({width = 65})<CR>',
        desc = 'aidoc: generate',
      },
    },
    opts = {},
  },
}
