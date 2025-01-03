-- https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat-v2.lua

local prompts = {
  -- Code related prompts
  Explain = 'Please explain how the following code works.',
  Review = 'Please review the following code and provide suggestions for improvement.',
  Tests = 'Please explain how the selected code works, then generate unit tests for it.',
  Refactor = 'Please refactor the following code to improve its clarity and readability.',
  FixCode = 'Please fix the following code to make it work as intended.',
  FixError = 'Please explain the error in the following text and provide a solution.',
  BetterNamings = 'Please provide better names for the following variables and functions.',
  Documentation = 'Please provide documentation for the following code.',
  SwaggerApiDocs = 'Please provide documentation for the following API using Swagger.',
  SwaggerJsDocs = 'Please write JSDoc for the following API using Swagger.',
  -- Text related prompts
  Summarize = 'Please summarize the following text.',
  Spelling = 'Please correct any grammar and spelling errors in the following text.',
  Wording = 'Please improve the grammar and wording of the following text.',
  Concise = 'Please rewrite the following text to make it more concise.',
}

return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    cond = not ar.plugins.minimal
      and ar.ai.enable
      and ar.completion.enable
      and ar.ai.models.copilot,
    cmd = {
      'CopilotChat',
      'CopilotChatInline',
      'CopilotChatToggle',
      'CopilotChatReset',
    },
    branch = 'canary',
    init = function()
      vim.g.whichkey_add_spec({ '<leader>ac', group = 'CopilotChat' })

      ar.add_to_menu('copilot_chat', {
        ['Clear Buffer and Chat History'] = 'CopilotChatReset',
        ['Toggle Copilot Chat Vsplit'] = 'CopilotChatToggle',
        ['Help Actions'] = "lua require'ar.menus.ai'.help_actions()",
        ['Prompt Actions'] = "lua require'ar.menus.ai'.prompt_actions()",
        ['Save Chat'] = "lua require'ar.menus.ai'.save_chat()",
        ['Explain Code'] = 'CopilotChatExplain',
        ['Generate Tests'] = 'CopilotChatTests',
        ['Review Code'] = 'CopilotChatReview',
        ['Refactor Code'] = 'CopilotChatRefactor',
        ['Better Naming'] = 'CopilotChatBetterNamings',
        ['Quick Chat'] = "lua require'ar.menus.ai'.quick_chat()",
        ['Ask Input'] = "lua require'ar.menus.ai'.ask_input()",
        ['Generate Commit Message'] = 'CopilotChatCommit',
        ['Generate Commit Message For Staged Changes'] = 'CopilotChatCommitStaged',
        ['Debug Info'] = 'CopilotChatDebugInfo',
        ['Fix Diagnostic'] = 'CopilotChatFixDiagnostic',
      })

      ar.add_to_menu('ai', {
        ['Toggle Copilot Chat'] = 'CopilotChatToggle',
        ['Clear Copilot Chat'] = 'CopilotChatReset',
        ['Copilot Chat Inline'] = function() ar.visual_cmd('CopilotChatInline') end,
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
        -- Use tab for completion
        complete = {
          detail = 'Use @<Tab> or /<Tab> for options.',
          insert = '<Tab>',
        },
        -- Close the chat
        close = { normal = 'q', insert = '<C-c>' },
        -- Reset the chat buffer
        reset = { normal = '<C-x>', insert = '<C-x>' },
        -- Submit the prompt to Copilot
        submit_prompt = { normal = '<CR>', insert = '<C-s>' },
        -- Accept the diff
        accept_diff = { normal = '<C-y>', insert = '<C-y>' },
        -- Yank the diff in the response to register
        yank_diff = { normal = 'gmy' },
        -- Show the diff
        show_diff = { normal = 'gmd' },
        -- Show the prompt
        show_system_prompt = { normal = 'gmp' },
        -- Show the user selection
        show_user_selection = { normal = 'gms' },
      },
    },
    config = function(_, opts)
      local chat = require('CopilotChat')
      local select = require('CopilotChat.select')

      -- Use unnamed register for the selection
      opts.selection = select.unnamed

      -- Override the git prompts message
      opts.prompts.Commit = {
        prompt = 'Write commit message for the change with commitizen convention',
        selection = select.gitdiff,
      }
      opts.prompts.CommitStaged = {
        prompt = 'Write commit message for the change with commitizen convention',
        selection = function(source) return select.gitdiff(source, true) end,
      }

      chat.setup(opts)
      -- Setup the CMP integration
      require('CopilotChat.integrations.cmp').setup()

      vim.api.nvim_create_user_command(
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
      {
        '<leader>ach',
        function()
          local actions = require('CopilotChat.actions')
          local integrations = require('CopilotChat.integrations.telescope')
          integrations.pick(actions.help_actions())
        end,
        desc = 'CopilotChat: help actions',
      },
      -- Show prompts actions with telescope
      {
        '<leader>acp',
        function()
          local actions = require('CopilotChat.actions')
          local integrations = require('CopilotChat.integrations.telescope')
          integrations.pick(actions.prompt_actions())
        end,
        desc = 'CopilotChat: prompt actions',
      },
      {
        '<leader>acs',
        function()
          local date = os.date('%Y-%m-%d_%H-%M-%S')
          vim.cmd('CopilotChatSave ' .. date)
        end,
        desc = 'CopilotChat: save prompt',
      },
      { mode = 'x', '<leader>acp', ":lua require('CopilotChat.integrations.telescope').pick(require('CopilotChat.actions').prompt_actions({selection = require('CopilotChat.select').visual}))<CR>", desc = 'CopilotChat: prompt actions' },
      -- Code related commands
      { '<leader>ace', '<Cmd>CopilotChatExplain<CR>', desc = 'CopilotChat: prompt actions' },
      { '<leader>act', '<Cmd>CopilotChatTests<CR>', desc = 'CopilotChat: generate tests' },
      { '<leader>acr', '<Cmd>CopilotChatReview<CR>', desc = 'CopilotChat: review code' },
      { '<leader>acR', '<Cmd>CopilotChatRefactor<CR>', desc = 'CopilotChat: refactor code' },
      { '<leader>acn', '<Cmd>CopilotChatBetterNamings<CR>', desc = 'CopilotChat: better Naming' },
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
      { '<leader>acM', '<Cmd>CopilotChatCommitStaged<CR>', desc = 'CopilotChat: generate commit message for staged changes' },
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
