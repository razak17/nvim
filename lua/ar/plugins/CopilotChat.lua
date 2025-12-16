-- https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat-v2.lua

local prompts = {
  COPILOT_BEAST_MODE = {
    system_prompt = ar.config.ai.prompts.beast_mode,
  },
  FixCode = {
    prompt = 'Please fix the following code to make it work as intended.',
  },
  FixError = {
    prompt = 'Please explain the error in the following text and provide a solution.',
  },
  BetterNaming = {
    prompt = 'Please provide better names for the following variables and functions.',
  },
  SwaggerApiDocs = {
    prompt = 'Please provide documentation for the following API using Swagger.',
  },
  SwaggerJsDocs = {
    prompt = 'Please write JSDoc for the following API using Swagger.',
  },
  Summarize = { prompt = 'Please summarize the following text.' },
  Spelling = {
    prompt = 'Please correct any grammar and spelling errors in the following text.',
  },
  Wording = {
    prompt = 'Please improve the grammar and wording of the following text.',
  },
  Concise = {
    prompt = 'Please rewrite the following text to make it more concise.',
  },
}

local minimal = ar.plugins.minimal

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

return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    cond = function()
      local condition = not minimal
        and ar.ai.enable
        and ar.completion.enable
        and ar.config.ai.models.copilot
      return ar.get_plugin_cond('CopilotChat.nvim', condition)
    end,
    -- stylua: ignore
    cmd = {
      'CopilotChatExplain', 'CopilotChatReview', 'CopilotFixCode', 'CopilotFixEError',
      'CopilotChatBetterNaming', 'CopilotChatDocs', 'CopilotChatSwaggerApiDocs',
      'CopilotChatSwaggerJsDocs', 'CopilotChatSummarize', 'CopilotChatSpelling',
      'CopilotChatWording', 'CopilotChatConcise', 'CopilotChat', 'CopilotChatToggle',
      'CopilotChatReset', 'CopilotChatAgents', 'CopilotChatModels', 'CopilotChatTests',
      'CopilotChatOptimize', 'CopilotChatCommit', 'CopilotChatDebugInfo', 'CopilotChatFixDiagnostic',
    },
    branch = 'main',
    init = function()
      local visual_cmd = ar.visual_cmd
      -- stylua: ignore start
      vim.g.whichkey_add_spec({ '<leader>ac', group = 'CopilotChat', mode = { 'n', 'x' } })
      -- stylua: ignore end
      ar.add_to_select_menu('ai', {
        ['CopilotChat'] = function()
          ar.create_select_menu('CopilotChat', {
            ['Toggle Chat'] = 'CopilotChatToggle',
            ['Agents'] = 'CopilotChatAgents',
            ['Models'] = 'CopilotChatModels',
            ['Prompt Actions'] = prompt_actions,
            ['Save Chat'] = save_chat,
            ['Quick Chat'] = quick_chat,
            ['Ask Input'] = ask_input,
            ['Explain Code'] = function() visual_cmd('CopilotChatExplain') end,
            ['Fix Code'] = function() visual_cmd('CopilotFixCode') end,
            ['Fix Error'] = function() visual_cmd('CopilotFixEError') end,
            ['Generate Tests'] = function() visual_cmd('CopilotChatTests') end,
            ['Summarize'] = function() visual_cmd('CopilotChatSummarize') end,
            ['Spelling'] = function() visual_cmd('CopilotChatSpelling') end,
            ['Wording'] = function() visual_cmd('CopilotChatWording') end,
            ['Concise'] = function() visual_cmd('CopilotChatConcise') end,
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
    ---@type CopilotChat.config.shared
    opts = {
      auto_insert_mode = false,
      model = 'claude-opus-4.5',
      agent = 'copilot',
      prompts = prompts,
      auto_follow_cursor = false,
      show_help = true,
      allow_insecure = false, -- Allow insecure server connections
      window = {
        width = 0.4,
      },
      headers = {
        user = '  me',
        assistant = '  Copilot ',
        tool = '󰊳  Tool ',
      },
      mappings = {
        complete = {
          detail = 'Use @<Tab> or /<Tab> for options.',
          insert = '<C-u>',
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

      if ar.has('VectorCode') then
        opts.contexts = opts.contexts or {}
        local vectorcode_ctx =
          require('vectorcode.integrations.copilotchat').make_context_provider({
            prompt_header = 'Here are relevant files from the repository:', -- Customize header text
            prompt_footer = '\nConsider this context when answering:', -- Customize footer text
            skip_empty = true, -- Skip adding context when no files are retrieved
          })
        opts.contexts.vectorcode = vectorcode_ctx

        opts.prompts = vim
          .iter(opts.prompts or {})
          :fold({}, function(acc, key, prompt)
            prompt.context = { 'selection', 'vectorcode' } -- Add vectorcode to the context
            acc[key] = prompt
            return acc
          end)

        opts.sticky = {
          'Using the model $claude-opus-4.5',
          '#vectorcode', -- Automatically includes repository context in every conversation
        }
      end

      chat.setup(opts)

      local select = require('CopilotChat.select')
      ar.command(
        'CopilotChatBuffer',
        function(args) chat.ask(args.args, { selection = select.buffer }) end,
        { nargs = '*', range = true }
      )

      -- Custom buffer for CopilotChat
      -- ar.augroup('CopilotChat', {
      --   event = 'BufEnter',
      --   pattern = 'copilot-*',
      --   command = function()
      --     vim.opt_local.relativenumber = true
      --     vim.opt_local.number = true
      --
      --     if vim.bo.ft == 'copilot-chat' then vim.bo.filetype = 'markdown' end
      --   end,
      -- })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>aco', '<Cmd>CopilotChatToggle<CR>', desc = 'CopilotChat: toggle' },
      { '<leader>acl', '<Cmd>CopilotChatReset<CR>', desc = 'CopilotChat: clear buffer and chat history' },
      { '<leader>acq', '<Cmd>CopilotChatStop<CR>', desc = 'CopilotChat: stop' },
      { '<leader>aca', prompt_actions, desc = 'CopilotChat: prompt actions' },
      { '<leader>acc', quick_chat, desc = 'CopilotChat: quick chat' },
      { '<leader>aci', ask_input, desc = 'CopilotChat: ask input', },
      { mode = 'x', '<leader>aca', '<Cmd>CopilotChatPrompts<CR>', desc = 'CopilotChat: prompt actions' },
      { mode = 'x', '<leader>acx', '<Cmd>CopilotChatExplain<CR>', desc = 'CopilotChat: explain code' },
      { mode = 'x', '<leader>act', '<Cmd>CopilotChatTests<CR>', desc = 'CopilotChat: generate tests' },
      { mode = 'x', '<leader>acr', '<Cmd>CopilotChatReview<CR>', desc = 'CopilotChat: review code' },
      { mode = 'x', '<leader>acR', '<Cmd>CopilotChatRefactor<CR>', desc = 'CopilotChat: refactor code' },
      { mode = 'x', '<leader>acn', '<Cmd>CopilotChatBetterNaming<CR>', desc = 'CopilotChat: better Naming' },
    },
  },
}
