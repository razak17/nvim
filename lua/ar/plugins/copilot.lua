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
    },
  },
  {
    'saghen/blink.cmp',
    optional = true,
    dependencies = { 'fang2hou/blink-copilot', cond = get_cond },
    opts = function(_, opts)
      if not get_cond() then return opts end
      opts = opts or {}
      opts.sources = opts.sources or {}
      local sources = vim.list_extend(opts.sources.default or {}, { 'copilot' })
      opts.sources.default = function() return sources end
      opts.sources.providers =
        vim.tbl_deep_extend('force', opts.sources.providers or {}, {
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
        })
      return opts
    end,
  },
}
