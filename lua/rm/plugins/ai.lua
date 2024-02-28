-- local function get_openai_key()
--   if not fn.executable('pass') then
--     vim.notify(
--       'Pass not found. Environment variables may not be loaded',
--       vim.log.levels.ERROR
--     )
--     return
--   end
--   local key = fn.system('pass show api/tokens/openai-work')
--   if not key or vim.v.shell_error ~= 0 then
--     vim.notify('OpenAI key not found', vim.log.levels.ERROR)
--     return
--   end
--   return vim.trim(key)
-- end
--
-- vim.g.openai_api_key = get_openai_key()

return {
  {
    'razak17/copilot.lua',
    cond = rvim.ai.enable and not rvim.plugins.minimal,
    event = 'InsertEnter',
    -- stylua: ignore
    keys = {
      { '<leader>ap', '<Cmd>Copilot panel<CR>', desc = 'copilot: toggle panel', },
      { '<leader>at', '<Cmd>Copilot toggle<CR>', desc = 'copilot: toggle' },
    },
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = not rvim.plugins.overrides.copilot_cmp.enable,
        keymap = {
          accept_word = '<M-w>',
          accept_line = '<M-l>',
          accept = '<M-u>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-\\>',
        },
      },
      filetypes = {
        gitcommit = false,
        NeogitCommitMessage = false,
        DressingInput = false,
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      },
      server_opts_overrides = {
        settings = {
          advanced = { inlineSuggestCount = 3 },
        },
      },
    },
  },
  {
    'jellydn/CopilotChat.nvim',
    cmd = {
      'CopilotChat',
      'CopilotChatExplain',
      'CopilotChatRefactor',
      'CopilotChatReview',
      'CopilotChatTests',
    },
    build = function()
      vim.defer_fn(function()
        vim.cmd('UpdateRemotePlugins')
        vim.notify(
          'CopilotChat - Updated remote plugins. Please restart Neovim.'
        )
      end, 3000)
    end,
    opts = {
      mode = 'split',
      prompts = {
        Explain = 'What does this code do?',
        Review = 'Review the following code and provide concise suggestions.',
        Tests = 'Briefly explain how the selected code works, then generate unit tests.',
        Refactor = 'Refactor the code to improve clarity and readability.',
      },
    },
  },
  {
    'piersolenski/wtf.nvim',
    cond = rvim.lsp.enable and rvim.ai.enable,
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      { '<leader>ao', function() require('wtf').ai() end, desc = 'wtf: debug diagnostic with AI', },
      { '<leader>ag', function() require('wtf').search() end, desc = 'wtf: google search diagnostic', },
    },
    opts = {
      popup_type = 'horizontal', -- | 'popup' | 'horizontal' | 'vertical',
      language = 'english',
      search_engine = 'google', -- 'google' | 'duck_duck_go' | 'stack_overflow' | 'github',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
    },
    dependencies = { 'MunifTanjim/nui.nvim' },
  },
  {
    'razak17/backseat.nvim',
    cmd = { 'Backseat', 'BackseatAsk', 'BackseatClear', 'BackseatClearLine' },
    opts = {
      highlight = { icon = '', group = 'DiagnosticVirtualTextInfo' },
      popup_type = 'popup', -- | 'popup' | 'horizontal' | 'vertical',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
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
  {
    'David-Kunz/gen.nvim',
    cond = not rvim.plugins.minimal and rvim.ai.enable and false,
    cmd = { 'Gen' },
  },
}
