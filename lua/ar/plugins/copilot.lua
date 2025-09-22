local models = ar_config.ai.models
local ai_cmp = ar_config.ai.completion.variant
local ai_suggestions = ar_config.ai.completion.suggestions

local function get_cond(plugin)
  local is_copilot = models.copilot and ai_cmp == 'copilot'
  local condition = ar.ai.enable and is_copilot
  if not plugin then return condition end
  return ar.get_plugin_cond(plugin, condition)
end

return {
  {
    'zbirenbaum/copilot.lua',
    cond = function() return get_cond('copilot.lua') end,
    cmd = { 'Copilot' },
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
      require('ar.copilot_indicator')()
    end,
    keys = {
      { '<leader>app', '<Cmd>Copilot panel<CR>', desc = 'copilot: panel' },
      { '<leader>apt', '<Cmd>Copilot toggle<CR>', desc = 'copilot: toggle' },
    },
    opts = {
      -- If copilot-cmp is enabled, set panel & suggestions to false
      panel = { enabled = ai_suggestions == 'ghost-text' },
      suggestion = {
        enabled = ai_suggestions == 'ghost-text',
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
        settings = { advanced = { inlineSuggestCount = 3 } },
      },
      nes = {
        enabled = true,
        keymap = {
          accept_and_goto = '<leader>aP',
          accept = false,
          dismiss = '<Esc>',
        },
      },
    },
    dependencies = {
      'copilotlsp-nvim/copilot-lsp',
      init = function() vim.g.copilot_nes_debounce = 500 end,
    },
  },
  {
    'saghen/blink.cmp',
    optional = true,
    dependencies = { 'fang2hou/blink-copilot', cond = get_cond },
    opts = function(_, opts)
      return get_cond()
          and vim.g.blink_add_source({ 'copilot' }, {
            copilot = {
              name = '[CPL]',
              module = 'blink-copilot',
              score_offset = 100,
              async = true,
              transform_items = function(_, items)
                local CompletionItemKind =
                  require('blink.cmp.types').CompletionItemKind
                local kind_idx = #CompletionItemKind + 1
                CompletionItemKind[kind_idx] = 'Copilot'
                for _, item in ipairs(items) do
                  item.kind = kind_idx
                end
                return items
              end,
            },
          }, opts)
        or opts
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    dependencies = { -- this will only be evaluated if nvim-cmp is enabled
      {
        'zbirenbaum/copilot-cmp',
        cond = get_cond,
        opts = {},
        config = function(_, opts)
          local copilot_cmp = require('copilot_cmp')
          copilot_cmp.setup(opts)
          -- attach cmp source whenever copilot attaches
          -- fixes lazy-loading issues with the copilot cmp source
          vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
              local buffer = args.buf ---@type number
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and (client.name == 'copilot') then
                return copilot_cmp._on_insert_enter(client, buffer)
              end
            end,
          })
        end,
        specs = {
          {
            'hrsh7th/nvim-cmp',
            optional = true,
            ---@param opts cmp.ConfigSchema
            opts = function(_, opts)
              local cmp = require('cmp')

              local function copilot()
                local suggestion = require('copilot.suggestion')
                if suggestion.is_visible() then return suggestion.accept() end
                vim.api.nvim_feedkeys(vim.keycode('<Tab>'), 'n', false)
              end
              opts = vim.g.cmp_add_source(opts, {
                source = {
                  name = 'minuet',
                  group_index = 1,
                  priority = 100,
                },
                menu = { copilot = '[CPL]' },
                format = {
                  copilot = {
                    icon = ar.ui.codicons.misc.octoface,
                    hl = 'CmpItemKindCopilot',
                  },
                },
              })
              vim.tbl_extend('force', opts.mapping or {}, {
                ['<C-]>'] = cmp.mapping(copilot),
              })
            end,
          },
        },
      },
    },
  },
}
