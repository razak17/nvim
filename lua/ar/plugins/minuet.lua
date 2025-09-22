local models = ar_config.ai.models
local cmp = ar_config.completion.variant
local ai_cmp = ar_config.ai.completion.variant
local ai_suggestions = ar_config.ai.completion.suggestions

local function get_cond()
  local is_minuet = models.gemini and ai_cmp == 'minuet'
  local condition = ar.ai.enable and is_minuet
  return ar.get_plugin_cond('minuet-ai.nvim', condition)
end

return {
  {
    'milanglacier/minuet-ai.nvim',
    cond = function() return get_cond() end,
    cmd = { 'Minuet' },
    event = 'InsertEnter',
    init = function()
      ar.add_to_select_menu('ai', {
        ['Minuet'] = function()
          ar.create_select_menu('Minuet', {
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
          return ai_suggestions == 'completion' and cmp == 'cmp'
        end,
      },
      blink = {
        enable_auto_complete = function()
          return ai_suggestions == 'completion' and cmp == 'blink'
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
        auto_trigger_ft = ai_suggestions == 'ghost-text' and { '*' } or {},
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
    'saghen/blink.cmp',
    optional = true,
    opts = function(_, opts)
      if get_cond() then
        local blink_opts = vim.g.blink_add_source({ 'minuet' }, {
          minuet = {
            enabled = function()
              return not vim.tbl_contains(
                ar_config.ai.ignored_filetypes,
                vim.bo.ft
              )
            end,
            name = '[MINUET]',
            module = 'minuet.blink',
            score_offset = 100,
            transform_items = function(_, items)
              local CompletionItemKind =
                require('blink.cmp.types').CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = 'Minuet'
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
          },
        }, opts)
        blink_opts.keymap =
          vim.tbl_deep_extend('force', blink_opts.keymap or {}, {
            ['<A-y>'] = require('minuet').make_blink_map(),
          })
        return blink_opts
      end
      return opts
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      if not get_cond() then return opts end
      local ai_icons = ar.ui.codicons.ai
      opts = vim.g.cmp_add_source(opts, {
        source = {
          name = 'minuet',
          group_index = 1,
          priority = 100,
        },
        menu = { minuet = '[MINUET]' },
        format = {
          minuet = { icon = ai_icons.minuet, hl = 'CmpItemKindDynamic' },
          claude = { icon = ai_icons.claude },
          codestral = { icon = ai_icons.codestral },
          gemini = { icon = ai_icons.gemini },
          openai = { icon = ai_icons.openai },
          Groq = { icon = ai_icons.groq },
          Openrouter = { icon = ai_icons.open_router },
          Ollama = { icon = ai_icons.ollama },
          ['Llama.cpp'] = { icon = ai_icons.llama },
          Deepseek = { icon = ai_icons.deepseek },
        },
      })
      vim.tbl_extend('force', opts.mapping or {}, {
        ['<A-y>'] = require('minuet').make_cmp_map(),
      })
    end,
  },
}
