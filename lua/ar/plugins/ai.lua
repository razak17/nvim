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
local find_string = ar.find_string
local minimal = ar.plugins.minimal
local models = ar.ai.models

return {
  {
    'yetone/avante.nvim',
    cond = not minimal and ar.ai.enable,
    init = function()
      require('which-key').add({ { '<leader>av', group = 'Avante' } })
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

      if find_string(models, 'claude') then
        set_provider('claude')
      elseif find_string(models, 'openai') then
        set_provider('openai')
      elseif find_string(models, 'gemini') then
        set_provider('gemini')
      elseif find_string(models, 'copilot') then
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
    init = function()
      require('which-key').add({ { '<leader>ak', group = 'Codecompanion' } })
    end,
    cmd = {
      'CodeCompanion',
      'CodeCompanionAdd',
      'CodeCompanionActions',
      'CodeCompanionToggle',
    },
    opts = function()
      local opts = {
        strategies = {
          chat = {
            roles = { llm = '  CodeCompanion', user = 'razak17' },
            keymaps = {
              close = {
                modes = {
                  n = 'q',
                  i = '<C-c>',
                },
                index = 2,
                callback = 'keymaps.close',
                description = 'Close Chat',
              },
              stop = {
                modes = {
                  n = '<C-c>',
                },
                index = 3,
                callback = 'keymaps.stop',
                description = 'Stop Request',
              },
            },
          },
        },
        display = {
          chat = {
            window = {
              layout = 'vertical', -- float|vertical|horizontal|buffer
            },
          },
          inline = {
            diff = {
              hl_groups = {
                added = 'DiffAdd',
              },
            },
          },
        },
        opts = { log_level = 'DEBUG' },
      }

      local function set_adapter_and_strategy(model_name)
        opts.adapters[model_name] = model_name
        opts.strategies.chat.adapter = model_name
        opts.strategies.chat.inline = model_name
        opts.strategies.chat.agent = model_name
      end

      opts.adapters = {}

      if find_string(models, 'claude') then
        set_adapter_and_strategy('claude')
      elseif find_string(models, 'openai') then
        set_adapter_and_strategy('openai')
      elseif find_string(models, 'gemini') then
        set_adapter_and_strategy('gemini')
      elseif find_string(models, 'copilot') then
        set_adapter_and_strategy('copilot')
      end

      return opts
    end,
    -- stylua: ignore
    keys = {
      { '<leader>akk', '<Cmd>CodeCompanionToggle<CR>', desc = 'codecompanion: toggle' },
      { '<leader>aka', '<Cmd>CodeCompanionActions<CR>', desc = 'codecompanion: actions' },
      { 'ga', '<Cmd>CodeCompanionAdd<CR>', desc = 'codecompanion: add' },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    cond = not minimal and ar.ai.enable and find_string(models, 'copilot'),
    cmd = 'Copilot',
    event = 'InsertEnter',
    init = function()
      require('which-key').add({ { '<leader>ap', group = 'Copilot' } })
    end,
    keys = {
      { '<leader>app', '<Cmd>Copilot panel<CR>', desc = 'copilot: panel' },
      { '<leader>apt', '<Cmd>Copilot toggle<CR>', desc = 'copilot: toggle' },
    },
    opts = {
      -- If copilot-cmp is enabled, set panel & suggestions to false
      panel = { enabled = false },
      suggestion = {
        enabled = true,
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
    init = function()
      require('which-key').add({ { '<leader>aw', group = 'wtf' } })
    end,
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
    cond = not minimal and ar.ai.enable and find_string(models, 'openai'),
    cmd = { 'Backseat', 'BackseatAsk', 'BackseatClear', 'BackseatClearLine' },
    opts = {
      highlight = { icon = '', group = 'DiagnosticVirtualTextInfo' },
      popup_type = 'popup', -- | 'popup' | 'horizontal' | 'vertical',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
    },
  },
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
