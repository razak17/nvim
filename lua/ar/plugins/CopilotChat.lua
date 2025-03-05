-- https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat-v2.lua

local prompts = {
  -- Code related prompts
  Explain = 'Please explain how the following code works.',
  Review = 'Please review the following code and provide suggestions for improvement.',
  Tests = 'Please explain how the selected code works, then generate unit tests for it.',
  Refactor = 'Please refactor the following code to improve its clarity and readability.',
  FixCode = 'Please fix the following code to make it work as intended.',
  FixError = 'Please explain the error in the following text and provide a solution.',
  BetterNaming = 'Please provide better names for the following variables and functions.',
  Documentation = 'Please provide documentation for the following code.',
  SwaggerApiDocs = 'Please provide documentation for the following API using Swagger.',
  SwaggerJsDocs = 'Please write JSDoc for the following API using Swagger.',
  -- Text related prompts
  Summarize = 'Please summarize the following text.',
  Spelling = 'Please correct any grammar and spelling errors in the following text.',
  Wording = 'Please improve the grammar and wording of the following text.',
  Concise = 'Please rewrite the following text to make it more concise.',
}

local minimal = ar.plugins.minimal

return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    cond = not minimal and ar.ai.enable and ar.completion.enable,
    cmd = {
      'CopilotChatExplain',
      'CopilotChatReview',
      'CopilotFixCode',
      'CopilotFixEError',
      'CopilotChatBetterNaming',
      'CopilotChatDocumentation',
      'CopilotChatSwaggerApiDocs',
      'CopilotChatSwaggerJsDocs',
      'CopilotChatSummarize',
      'CopilotChatSpelling',
      'CopilotChatWording',
      'CopilotChatConcise',
      'CopilotChat',
      'CopilotChatToggle',
      'CopilotChatInline',
      'CopilotChatReset',
      'CopilotChatAgents',
      'CopilotChatModels',
      'CopilotChatTests',
      'CopilotChatRefactor',
      'CopilotChatCommit',
      'CopilotChatDebugInfo',
      'CopilotChatFixDiagnostic',
    },
    branch = 'main',
    init = function()
      vim.g.whichkey_add_spec({ '<leader>ac', group = 'CopilotChat' })

      local function prompt_actions() require('CopilotChat').select_prompt() end

      local function save_chat()
        local date = os.date('%Y-%m-%d_%H-%M-%S')
        vim.cmd('CopilotChatSave ' .. date)
      end

      local function quick_chat()
        local input = vim.fn.input('Quick Chat: ')
        if input ~= '' then vim.cmd('CopilotChatBuffer ' .. input) end
      end

      local function ask_input()
        local input = vim.fn.input('Ask Copilot: ')
        if input ~= '' then vim.cmd('CopilotChat ' .. input) end
      end

      ar.add_to_select_menu('ai', {
        ['CopilotChat'] = function()
          ar.create_select_menu('CopilotChat', {
            ['Explain Code'] = 'CopilotChatExplain',
            ['Review Code'] = 'CopilotChatReview',
            ['Fix Code'] = 'CopilotFixCode',
            ['Fix Error'] = 'CopilotFixEError',
            ['Better Naming'] = 'CopilotChatBetterNaming',
            ['Documentation'] = 'CopilotChatDocumentation',
            ['Swagger Api Docs'] = 'CopilotChatSwaggerApiDocs',
            ['Swagger Js Docs'] = 'CopilotChatSwaggerJsDocs',
            ['Summarize'] = 'CopilotChatSummarize',
            ['Spelling'] = 'CopilotChatSpelling',
            ['Wording'] = 'CopilotChatWording',
            ['Concise'] = 'CopilotChatConcise',
            ['Open Chat'] = 'CopilotChat',
            ['Toggle Chat'] = 'CopilotChatToggle',
            ['Inline Chat'] = function() ar.visual_cmd('CopilotChatInline') end,
            ['Clear Buffer and Chat History'] = 'CopilotChatReset',
            ['Agents'] = 'CopilotChatAgents',
            ['Models'] = 'CopilotChatModels',
            ['Generate Tests'] = 'CopilotChatTests',
            ['Refactor Code'] = 'CopilotChatRefactor',
            ['Generate Commit Message'] = 'CopilotChatCommit',
            ['Debug Info'] = 'CopilotChatDebugInfo',
            ['Fix Diagnostic'] = 'CopilotChatFixDiagnostic',
            ['Prompt Actions'] = prompt_actions,
            ['Save Chat'] = save_chat,
            ['Quick Chat'] = quick_chat,
            ['Ask Input'] = ask_input,
          })()
        end,
      })
    end,
    build = function()
      vim.defer_fn(function()
        vim.cmd('UpdateRemotePlugins')
        vim.notify(
          'CopilotChat - Updated remote plugins. Please restart Neovim.'
        )
      end, 3000)
    end,
    opts = {
      prompts = prompts,
      auto_follow_cursor = false, -- Don't follow the cursor after getting response
      show_help = true, -- Show help in virtual text, set to true if that's 1st time using Copilot Chat
      allow_insecure = false, -- Allow insecure server connections
      mappings = {
        complete = {
          detail = 'Use @<Tab> or /<Tab> for options.',
          insert = '<Tab>',
        },
        close = { normal = 'q', insert = '<C-c>' },
        reset = { normal = '<C-x>', insert = '<C-x>' },
        submit_prompt = { normal = '<CR>', insert = '<C-s>' },
        accept_diff = { normal = '<C-y>', insert = '<C-y>' },
        show_help = { normal = 'g?' },
      },
    },
    config = function(_, opts)
      local chat = require('CopilotChat')

      local models = ar_config.ai.models

      local function get_model()
        local model
        if models.claude then
          model = 'claude-3.7-sonnet'
        elseif models.openai then
          model = 'gpt-4o'
        end
        return model
      end

      local fmt = string.format
      local model = get_model()
      if model then opts.model = model end
      opts.answer_header = fmt('## %s', model and model or 'Copilot')

      chat.setup(opts)

      local select = require('CopilotChat.select')

      ar.command(
        'CopilotChatVisual',
        function(args) chat.ask(args.args, { selection = select.visual }) end,
        { nargs = '*', range = true }
      )

      -- Inline chat with Copilot
      ar.command(
        'CopilotChatInline',
        function(args)
          chat.ask(args.args, {
            selection = select.visual,
            window = {
              layout = 'float',
              relative = 'cursor',
              width = 1,
              height = 0.4,
              row = 1,
            },
          })
        end,
        { nargs = '*', range = true }
      )

      -- Restore CopilotChatBuffer
      ar.command(
        'CopilotChatBuffer',
        function(args) chat.ask(args.args, { selection = select.buffer }) end,
        { nargs = '*', range = true }
      )

      -- Custom buffer for CopilotChat
      ar.augroup('CopilotChat', {
        event = 'BufEnter',
        pattern = 'copilot-*',
        command = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true

          if vim.bo.ft == 'copilot-chat' then vim.bo.filetype = 'markdown' end
        end,
      })
    end,
    -- stylua: ignore
    keys = {
      -- Clear buffer and chat history
      { '<leader>acl', '<Cmd>CopilotChatReset<CR>', desc = 'CopilotChat: clear buffer and chat history' },
      -- Toggle Copilot Chat Vsplit
      { '<leader>acv', '<Cmd>CopilotChatToggle<CR>', desc = 'CopilotChat: toggle' },
      -- Show help actions with telescope
      -- Show prompts actions with telescope
      {
        '<leader>acp',
        function() require('CopilotChat').select_prompt() end,
        desc = 'CopilotChat: prompt actions',
      },
      { mode = 'x', '<leader>acp', ":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>", desc = 'CopilotChat: prompt actions' },
      -- Code related commands
      { '<leader>ace', '<Cmd>CopilotChatExplain<CR>', desc = 'CopilotChat: prompt actions' },
      { '<leader>act', '<Cmd>CopilotChatTests<CR>', desc = 'CopilotChat: generate tests' },
      { '<leader>acr', '<Cmd>CopilotChatReview<CR>', desc = 'CopilotChat: review code' },
      { '<leader>acR', '<Cmd>CopilotChatRefactor<CR>', desc = 'CopilotChat: refactor code' },
      { '<leader>acn', '<Cmd>CopilotChatBetterNaming<CR>', desc = 'CopilotChat: better Naming' },
      -- Chat with Copilot in visual mode
      { mode = 'x', '<leader>acv', ':CopilotChatVisual', desc = 'CopilotChat: open in vertical split' },
      { mode = 'x', '<leader>acx', ':CopilotChatInline<CR>', desc = 'CopilotChat: inline chat' },
      -- Custom input for CopilotChat
      {
        '<leader>aci',
        function()
          local input = vim.fn.input('Ask Copilot: ')
          if input ~= '' then vim.cmd('CopilotChat ' .. input) end
        end,
        desc = 'CopilotChat: ask input',
      },
      -- Generate commit message based on the git diff
      { '<leader>acm', '<Cmd>CopilotChatCommit<CR>', desc = 'CopilotChat: generate commit message for all changes' },
      -- Quick chat with Copilot
      {
        '<leader>acq',
        function()
          local input = vim.fn.input('Quick Chat: ')
          if input ~= '' then vim.cmd('CopilotChatBuffer ' .. input) end
        end,
        desc = 'CopilotChat: quick chat',
      },
      -- Debug
      { '<leader>acd', '<Cmd>CopilotChatDebugInfo<CR>', desc = 'CopilotChat: debug Info' },
      -- Fix the issue with diagnostic
      { '<leader>acf', '<Cmd>CopilotChatFixDiagnostic<CR>', desc = 'CopilotChat: fix diagnostic' },
    },
  },
}
