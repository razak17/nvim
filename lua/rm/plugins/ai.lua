local fn = vim.fn

local function get_openai_key()
  if not fn.executable('pass') then
    vim.notify(
      'Pass not found. Environment variables may not be loaded',
      vim.log.levels.ERROR
    )
    return
  end
  local key = fn.system('pass show api/tokens/openai-work')
  if not key or vim.v.shell_error ~= 0 then
    vim.notify('OpenAI key not found', vim.log.levels.ERROR)
    return
  end
  return vim.trim(key)
end

vim.g.openai_api_key = get_openai_key()

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
    opts = { openai_api_key = vim.g.openai_api_key },
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
        api_key_cmd = vim.g.openai_api_key,
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
    'razak17/wtf.nvim',
    cond = rvim.lsp.enable and rvim.ai.enable,
    event = 'VeryLazy',
    opts = {
      openai_api_key = vim.g.openai_api_key,
      popup_type = 'popup', -- | 'horizontal' | 'vertical',
      language = 'english',
      search_engine = 'google', -- | 'duck_duck_go' | 'stack_overflow' | 'github',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
    },
    keys = {
      {
        '<leader>ao',
        function() require('wtf').ai() end,
        desc = 'wtf: debug diagnostic with AI',
      },
      {
        '<leader>ag',
        function() require('wtf').search() end,
        desc = 'wtf: google search diagnostic',
      },
    },
    dependencies = { 'MunifTanjim/nui.nvim' },
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
    opts = { keymap = '' },
  },
}