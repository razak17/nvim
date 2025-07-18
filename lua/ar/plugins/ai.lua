local models = ar_config.ai.models
local cmp = ar_config.completion.variant
local ai_cmp = ar_config.ai.completion.variant
local is_ai_cmp = ar_config.ai.completion.enable

return {
  {
    'kylesnowschwartz/prompt-tower.nvim',
    cond = function()
      return ar.get_plugin_cond('prompt-tower.nvim', ar.ai.enable)
    end,
    init = function()
      ar.add_to_select_menu('ai', {
        ['Prompt Tower'] = function()
          ar.create_select_menu('Prompt Tower', {
            ['UI'] = 'PromptTower ui',
            ['Clear'] = 'PromptTower clear',
            ['Select'] = 'PromptTower select',
            ['Format'] = 'PromptTower format',
            ['Generate'] = 'PromptTower generate',
          })()
        end,
      })
    end,
    cmd = { 'PromptTower' },
    config = function()
      require('prompt-tower').setup({
        output_format = {
          default_format = 'markdown', -- Options: 'xml', 'markdown', 'minimal'
        },
      })
    end,
  },
  {
    'ravitemer/mcphub.nvim',
    cond = function() return ar.get_plugin_cond('mcphub.nvim', ar.ai.enable) end,
    cmd = { 'MCPHub' },
    keys = { { '<leader>am', '<Cmd>MCPHub<CR>', desc = 'mcphub: toggle' } },
    build = 'bundled_build.lua',
    opts = {
      port = 37373,
      config = vim.fn.expand('~/.config/mcphub/servers.json'),
      use_bundled_binary = true, -- Use local `mcp-hub` binary (set this to true when using build = "bundled_build.lua"
      extensions = {
        avante = { make_slash_commands = true },
      },
      ui = { window = { border = 'single' } },
      log = {
        level = vim.log.levels.INFO,
        to_file = true,
        file_path = vim.fn.stdpath('state') .. '/mcphub.log',
        prefix = 'MCPHub',
      },
    },
  },
  {
    'milanglacier/minuet-ai.nvim',
    cond = function()
      local is_minuet = models.gemini and ai_cmp == 'minuet'
      local condition = ar.ai.enable and is_minuet
      return ar.get_plugin_cond('minuet-ai.nvim', condition)
    end,
    cmd = { 'Minuet' },
    event = 'InsertEnter',
    init = function()
      ar.add_to_select_menu('ai', {
        ['Minuet'] = function()
          ar.create_select_menu('Copilot', {
            ['Toggle Minuet Completion'] = function()
              if cmp == 'blink' then vim.cmd('Minuet blink toggle') end
              if cmp == 'cmp' then vim.cmd('Minuet cmp toggle') end
            end,
            ['Toggle Minuet Virtual Text'] = function()
              vim.cmd('Minuet virtualtext toggle')
            end,
          })()
        end,
      })
    end,
    opts = {
      request_timeout = 4,
      throttle = 2000,
      notify = 'error',
      cmp = {
        enable_auto_complete = function() return is_ai_cmp and cmp == 'cmp' end,
      },
      blink = {
        enable_auto_complete = function() return is_ai_cmp and cmp == 'blink' end,
      },
      provider_options = {
        gemini = {
          optional = {
            generationConfig = {
              maxOutputTokens = 256,
              topP = 0.9,
            },
            safetySettings = {
              {
                category = 'HARM_CATEGORY_DANGEROUS_CONTENT',
                threshold = 'BLOCK_NONE',
              },
              {
                category = 'HARM_CATEGORY_HATE_SPEECH',
                threshold = 'BLOCK_NONE',
              },
              {
                category = 'HARM_CATEGORY_HARASSMENT',
                threshold = 'BLOCK_NONE',
              },
              {
                category = 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                threshold = 'BLOCK_NONE',
              },
            },
          },
        },
        claude = {
          max_tokens = 512,
          model = 'claude-3-5-sonnet-20241022',
        },
        openai = {
          optional = {
            max_tokens = 256,
            top_p = 0.9,
          },
        },
      },
      virtualtext = {
        auto_trigger_ft = { '*' },
        auto_trigger_ignore_ft = ar_config.ai.ignored_filetypes,
        keymap = {
          accept = '<A-u>',
          accept_line = '<A-l>',
          -- accept n lines (prompts for number)
          -- e.g. "A-z 2 CR" will accept 2 lines
          accept_n_lines = '<A-n>',
          prev = '<A-[>',
          next = '<A-]>',
          dismiss = '<A-\\>',
        },
        show_on_completion_menu = true,
      },
    },
    config = function(_, opts)
      if models.gemini then
        opts.provider = 'gemini'
      elseif models.claude then
        opts.provider = 'claude'
      elseif models.openai then
        opts.provider = 'openai'
      end
      require('minuet').setup(opts)
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'zbirenbaum/copilot.lua',
    cond = function()
      local is_copilot = models.copilot and ai_cmp == 'copilot'
      local condition = ar.ai.enable and is_copilot
      return ar.get_plugin_cond('minuet-ai.nvim', condition)
    end,
    cmd = 'Copilot',
    event = 'InsertEnter',
    init = function()
      vim.g.whichkey_add_spec({ '<leader>ap', group = 'Copilot' })

      ar.add_to_select_menu('ai', {
        ['Copilot'] = function()
          ar.create_select_menu('Copilot', {
            ['Toggle Auto Trigger'] = 'lua require("copilot.suggestion").toggle_auto_trigger()',
            ['Disable'] = function() vim.cmd('Copilot disable') end,
            ['Enable'] = function() vim.cmd('Copilot enable') end,
            ['Toggle'] = function() vim.cmd('Copiot toggle') end,
            ['Attach'] = function() vim.cmd('Copiot attach') end,
            ['Detach'] = function() vim.cmd('Copiot detach') end,
            ['Panel'] = function() vim.cmd('Copilot panel') end,
            ['Status'] = function() vim.cmd('Copiot status') end,
          })()
        end,
      })
    end,
    keys = {
      { '<leader>app', '<Cmd>Copilot panel<CR>', desc = 'copilot: panel' },
      { '<leader>apt', '<Cmd>Copilot toggle<CR>', desc = 'copilot: toggle' },
    },
    opts = {
      -- If copilot-cmp is enabled, set panel & suggestions to false
      panel = { enabled = not is_ai_cmp },
      suggestion = {
        enabled = not is_ai_cmp,
        auto_trigger = true,
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
    'piersolenski/wtf.nvim',
    cond = function()
      local condition = ar.lsp.enable and ar.ai.enable and models.openai
      return ar.get_plugin_cond('wtf.nvim', condition)
    end,
    init = function() vim.g.whichkey_add_spec({ '<leader>aw', group = 'wtf' }) end,
    -- stylua: ignore
    keys = {
      { '<leader>awo', function() require('wtf').ai() end, desc = 'wtf: debug diagnostic with AI', },
      { '<leader>awg', function() require('wtf').search() end, desc = 'wtf: google search diagnostic', },
    },
    opts = {
      popup_type = 'horizontal', -- | 'popup' | 'horizontal' | 'vertical',
      language = 'english',
      search_engine = 'google', -- 'google' | 'duck_duck_go' | 'stack_overflow' | 'github',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
    },
  },
}
