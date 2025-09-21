local models = ar_config.ai.models
local cmp = ar_config.completion.variant
local ai_cmp = ar_config.ai.completion.variant
local ai_suggestions = ar_config.ai.completion.suggestions == 'ghost-text'

return {
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
        enable_auto_complete = function()
          return ai_suggestions and cmp == 'cmp'
        end,
      },
      blink = {
        enable_auto_complete = function()
          return ai_suggestions and cmp == 'blink'
        end,
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
}
