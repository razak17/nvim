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
local minimal = ar.plugins.minimal
local models = ar_config.ai.models
local cmp = ar_config.completion.variant
local ai_cmp = ar_config.ai.completion.variant
local is_ai_cmp = ar_config.ai.completion.enable

return {
  {
    'napisani/context-nvim',
    cond = not minimal and ar.ai.enable and false,
    cmd = { 'ContextNvim' },
    opts = {},
    config = function(_, opts) require('context_nvim').setup(opts) end,
  },
  {
    'yetone/avante.nvim',
    cond = not minimal and ar.ai.enable and false,
    init = function()
      vim.g.whichkey_add_spec({ '<leader>av', group = 'Avante' })

      ar.add_to_select_menu('ai', {
        ['Avante'] = function()
          ar.create_select_menu('Avante', {
            ['Toggle Chat'] = 'AvanteToggle',
            ['Clear Chat'] = 'AvanteClear',
            ['Switch Provider'] = 'AvanteSwitchProvider',
            ['Refresh Chat'] = 'AvanteRefresh',
          })()
        end,
      })
    end,
    keys = { '<leader>ava', '<leader>avr', '<leader>avs' },
    cmd = {
      'Avante',
      'AvanteAsk',
      'AvanteBuild',
      'AvanteChat',
      'AvanteClear',
      'AvanteEdit',
      'AvanteRefresh',
      'AvanteSwitchProvider',
      'AvanteToggle',
    },
    opts = function()
      local opts = {
        behaviour = { auto_set_keymaps = true },
        mappings = {
          ask = '<leader>ava',
          edit = '<leader>ave',
          refresh = '<leader>avr',
          toggle = {
            default = '<leader>avt',
            debug = '<leader>avd',
            hint = '<leader>avh',
            suggestion = '<leader>avs',
          },
        },
      }

      local function set_provider(model_name)
        opts.provider = model_name
        opts.auto_suggestions_provider = model_name
      end

      if models.claude then
        set_provider('claude')
      elseif models.openai then
        set_provider('openai')
      elseif models.gemini then
        set_provider('gemini')
      elseif models.copilot then
        set_provider('copilot')
      end

      return opts
    end,
    build = 'make',
    dependencies = {
      {
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    cond = not minimal and ar.ai.enable,
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
            roles = { llm = '  CodeCompanion', user = 'me' },
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
          chat = {
            window = {
              layout = 'vertical', -- float|vertical|horizontal|buffer
            },
          },
          inline = {
            diff = { hl_groups = { added = 'DiffAdd' } },
          },
        },
        opts = { log_level = 'DEBUG' },
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
  },
  {
    'milanglacier/minuet-ai.nvim',
    cond = function()
      local is_minuet = models.gemini and ai_cmp == 'minuet'
      return not minimal and ar.ai.enable and is_minuet
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
      return not minimal and ar.ai.enable and is_copilot
    end,
    cmd = 'Copilot',
    event = 'InsertEnter',
    init = function()
      vim.g.whichkey_add_spec({ '<leader>ap', group = 'Copilot' })

      ar.add_to_select_menu('ai', {
        ['Copilot'] = function()
          ar.create_select_menu('Copilot', {
            ['Toggle Copilot Auto Trigger'] = 'lua require("copilot.suggestion").toggle_auto_trigger()',
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
    cond = not minimal and ar.lsp.enable and ar.ai.enable,
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
  {
    'razak17/backseat.nvim',
    cond = not minimal and ar.ai.enable and models.copilot,
    cmd = { 'Backseat', 'BackseatAsk', 'BackseatClear', 'BackseatClearLine' },
    opts = {
      highlight = { icon = '', group = 'DiagnosticVirtualTextInfo' },
      popup_type = 'popup', -- | 'popup' | 'horizontal' | 'vertical',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
    },
  },
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'moozd/aidoc.nvim',
    cond = not minimal and ar.ai.enable and false,
    keys = {
      {
        mode = 'x',
        '<leader>ad',
        '<cmd>lua require("aidoc.api").generate({width = 65})<CR>',
        desc = 'aidoc: generate',
      },
    },
    opts = { keymap = '' },
  },
  {
    'David-Kunz/gen.nvim',
    enabled = false,
    cond = not minimal and ar.ai.enable and false,
    cmd = { 'Gen' },
  },
}
