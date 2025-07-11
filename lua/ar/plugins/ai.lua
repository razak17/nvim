-- local function get_openai_key()
--   if not fn.executable('pass') then
--     vim.notify(
--       'Pass not found. Environment variables may not be loaded',
--       vim.log.levels.ERROR
--     )
--     return
--   end
--   local key = vim.system('pass show api/tokens/openai-work'):wait().stdout
--   if not key or vim.v.shell_error ~= 0 then
--     vim.notify('OpenAI key not found', vim.log.levels.ERROR)
--     return
--   end
--   return vim.trim(key)
-- end
--
-- vim.g.openai_api_key = get_openai_key()

local fmt = string.format
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
    'olimorris/codecompanion.nvim',
    cond = function()
      return ar.get_plugin_cond('codecompanion.nvim', ar.ai.enable)
    end,
    -- stylua: ignore
    keys = {
      { '<leader>akk', '<Cmd>CodeCompanionChat<CR>', desc = 'codecompanion: toggle' },
      { '<leader>aka', '<Cmd>CodeCompanionActions<CR>', desc = 'codecompanion: actions' },
      { 'ga', '<Cmd>CodeCompanionAdd<CR>', desc = 'codecompanion: add' },
    },
    init = function()
      local visual_cmd = ar.visual_cmd
      vim.g.whichkey_add_spec({ '<leader>ak', group = 'Codecompanion' })
      ar.add_to_select_menu('ai', {
        ['Codecompanion'] = function()
          ar.create_select_menu('Codecompanion', {
            ['Toggle Chat'] = 'CodeCompanionChat Toggle',
            ['Actions'] = 'CodeCompanionActions',
            ['Add Selection'] = function() visual_cmd('CodeCompanionChat Add') end,
            ['Explain'] = function() visual_cmd('CodeCompanion /explain') end,
            ['Fix'] = function() visual_cmd('CodeCompanion /fix') end,
            ['Lsp'] = function() visual_cmd('CodeCompanion /lsp') end,
            ['Tests'] = function() visual_cmd('CodeCompanion /tests') end,
            ['Commit'] = function() visual_cmd('CodeCompanion /commit') end,
            ['Workspace'] = 'CodeCompanion /workspace',
            ['Code Workflow'] = 'CodeCompanion /cw',
            ['Edit<->Test workflow'] = 'CodeCompanion /et',
          })()
        end,
      })
    end,
    -- stylua: ignore
    cmd = { 'CodeCompanion', 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanionCmd' },
    opts = function()
      local opts = {
        strategies = {
          chat = {
            roles = {
              llm = function(adapter)
                return fmt('  CodeCompanion (%s)', adapter.formatted_name)
              end,
              user = 'me',
            },
            keymaps = {
              close = {
                modes = { n = 'q', i = '<C-c>' },
                index = 2,
                callback = 'keymaps.close',
                description = 'Close Chat',
              },
              stop = {
                modes = { n = '<C-c>' },
                index = 3,
                callback = 'keymaps.stop',
                description = 'Stop Request',
              },
            },
          },
          inline = {},
        },
        display = {
          action_palette = {
            width = 95,
            height = 10,
            prompt = 'Prompt ', -- Prompt used for interactive LLM calls
            provider = 'default', -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
            opts = {
              show_default_actions = true, -- Show the default actions in the action palette?
              show_default_prompt_library = true, -- Show the default prompt library in the action palette?
            },
          },
          chat = {
            auto_scroll = false,
            show_settings = true,
            window = {
              layout = 'vertical', -- float|vertical|horizontal|buffer
            },
          },
          inline = {
            diff = { hl_groups = { added = 'DiffAdd' } },
          },
        },
        opts = { log_level = 'DEBUG' },
        extensions = {},
        system_prompt = function() return ar_config.ai.prompts.beast_mode end,
      }

      local function set_adapter_and_strategy(model_name)
        opts.adapters[model_name] = model_name
        opts.strategies.chat.adapter = model_name
        opts.strategies.inline.adapter = model_name
      end

      opts.adapters = {}

      if models.claude then
        set_adapter_and_strategy('anthropic')
      elseif models.openai then
        set_adapter_and_strategy('openai')
      elseif models.gemini then
        set_adapter_and_strategy('gemini')
      elseif models.copilot then
        set_adapter_and_strategy('copilot')
      end

      opts.strategies.chat.opts = opts.strategies.chat.opts or {}
      if cmp == 'blink' or cmp == 'cmp' then
        opts.strategies.chat.opts.completion_provider = cmp
      else
        opts.strategies.chat.opts.completion_provider = 'default'
      end

      if ar.is_available('mcphub.nvim') then
        opts.extensions.mcphub = {
          callback = 'mcphub.extensions.codecompanion',
          opts = {
            show_result_in_chat = true, -- Show mcp tool results in chat
            make_vars = true, -- Convert resources to #variables
            make_slash_commands = true, -- Add prompts as /slash commands
          },
        }
      end

      return opts
    end,
    config = function(_, opts)
      ar.highlight.plugin('CodeCompanion', {
        theme = {
          ['onedark'] = {
            {
              CodeCompanionChatAgent = {
                bg = { from = 'Debug', attr = 'fg', alter = -0.1 },
                fg = { from = 'StatusLine', attr = 'bg' },
              },
            },
            {
              CodeCompanionChatTool = {
                bg = { from = 'Special', attr = 'fg', alter = -0.1 },
                fg = { from = 'StatusLine', attr = 'bg' },
              },
            },
            {
              CodeCompanionChatVariable = {
                bg = { from = 'Directory', attr = 'fg', alter = 0.1 },
                fg = { from = 'StatusLine', attr = 'bg' },
              },
            },
          },
        },
      })

      require('codecompanion').setup(opts)
    end,
    dependencies = {
      {
        'franco-ruggeri/codecompanion-spinner.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {},
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
            ['Toggle Copilot Auto Trigger'] = 'lua require("copilot.suggestion").toggle_auto_trigger()',
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
        auto_trigger = ar_config.ai.completion.auto_trigger,
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
