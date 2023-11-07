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
      local border =
        { style = rvim.ui.border.rectangle, highlight = 'FloatBorder' }
      require('chatgpt').setup({
        popup_window = { border = border },
        popup_input = { border = border, submit = '<C-s>' },
        settings_window = { border = border },
        chat = {
          keymaps = { close = { '<Esc>' } },
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
