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
    'olimorris/codecompanion.nvim',
    cond = ar.ai.enable and not ar.plugins.minimal,
    init = function()
      require('which-key').add({ { '<leader>ak', group = 'Codecompanion' } })
    end,
    cmd = {
      'CodeCompanion',
      'CodeCompanionAdd',
      'CodeCompanionActions',
      'CodeCompanionToggle',
    },
    opts = {
      adapters = {
        gemini = function()
          return require('codecompanion.adapters').extend('gemini', {
            env = { api_key = vim.env.GEMINI_API_KEY },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = 'gemini',
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
        inline = { adapter = 'gemini' },
        agent = { adapter = 'gemini' },
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
    },
    config = function(_, opts) require('codecompanion').setup(opts) end,
    -- stylua: ignore
    keys = {
      { '<leader>akk', '<Cmd>CodeCompanionToggle<CR>', desc = 'codecompanion: toggle' },
      { '<leader>aka', '<Cmd>CodeCompanionActions<CR>', desc = 'codecompanion: actions' },
      { 'ga', '<Cmd>CodeCompanionAdd<CR>', desc = 'codecompanion: add' },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    cond = ar.ai.enable and not ar.plugins.minimal,
    cmd = 'Copilot',
    event = 'InsertEnter',
    keys = {
      { '<leader>ap', '<Cmd>Copilot panel<CR>', desc = 'copilot: panel' },
      { '<leader>at', '<Cmd>Copilot toggle<CR>', desc = 'copilot: toggle' },
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
    cond = ar.lsp.enable and ar.ai.enable,
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
  },
  {
    'razak17/backseat.nvim',
    cmd = { 'Backseat', 'BackseatAsk', 'BackseatClear', 'BackseatClearLine' },
    opts = {
      highlight = { icon = '', group = 'DiagnosticVirtualTextInfo' },
      popup_type = 'popup', -- | 'popup' | 'horizontal' | 'vertical',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
    },
  },
  {
    'moozd/aidoc.nvim',
    cond = not ar.plugins.minimal,
    keys = {
      {
        mode = 'x',
        '<localleader>do',
        '<cmd>lua require("aidoc.api").generate({width = 65})<CR>',
        desc = 'aidoc: generate',
      },
    },
    opts = { keymap = '' },
  },
  {
    'David-Kunz/gen.nvim',
    enabled = false,
    cond = not ar.plugins.minimal and ar.ai.enable and false,
    cmd = { 'Gen' },
  },
}
