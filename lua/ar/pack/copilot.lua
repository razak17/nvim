local models = ar.config.ai.models
local ai_cmp = ar.config.ai.completion.variant
local ai_suggestions = ar.config.ai.completion.suggestions

local function get_cond(plugin)
  local is_copilot = models.copilot and ai_cmp == 'copilot'
  local condition = ar.ai.enable and is_copilot
  if not plugin then return condition end
  return ar.get_plugin_cond(plugin, condition)
end

if not get_cond('copilot.lua') then return end

local load

ar.pack.add({
  src = 'https://github.com/zbirenbaum/copilot.lua',
  cmd = { 'Copilot' },
  event = 'InsertEnter',
  dependencies = {
    { src = 'https://github.com/copilotlsp-nvim/copilot-lsp' },
    { src = 'https://github.com/samiulsami/copilot-eldritch.nvim' },
  },
  init = function()
    vim.g.copilot_nes_debounce = 500
    if vim.g.whichkey_add_spec then
      vim.g.whichkey_add_spec({ '<leader>ap', group = 'Copilot' })
    end
    ar.add_to_select('ai', {
      ['Copilot'] = function()
        load()
        ar.create_select_menu('Copilot', {
          ['Toggle Auto Trigger'] = 'lua require("copilot.suggestion").toggle_auto_trigger()',
          ['Disable'] = function() vim.cmd('Copilot disable') end,
          ['Enable'] = function() vim.cmd('Copilot enable') end,
          ['Toggle'] = function() vim.cmd('Copilot toggle') end,
          ['Attach'] = function() vim.cmd('Copilot attach') end,
          ['Detach'] = function() vim.cmd('Copilot detach') end,
          ['Panel'] = function() vim.cmd('Copilot panel') end,
          ['Status'] = function() vim.cmd('Copilot status') end,
        })()
      end,
    })
  end,
  keys = function(loader)
    load = loader
    return {
      { '<leader>app', '<Cmd>Copilot panel<CR>', desc = 'copilot: panel' },
      { '<leader>apt', '<Cmd>Copilot toggle<CR>', desc = 'copilot: toggle' },
    }
  end,
  setup = function()
    require('copilot').setup({
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
        enabled = false,
        keymap = {
          accept_and_goto = '<leader>aP',
          accept = false,
          dismiss = '<Esc>',
        },
      },
    })
    require('copilot-eldritch').setup({})
  end,
})

ar.pack.copilot = {
  blink = function(opts)
    load()
    ar.pack.add({
      src = 'https://github.com/fang2hou/blink-copilot',
      lazy = false,
    })
    return vim.g.blink_add_source({ 'copilot' }, {
      copilot = {
        name = '[CPL]',
        module = 'blink-copilot',
        score_offset = 100,
        async = true,
        transform_items = function(_, items)
          local kinds = require('blink.cmp.types').CompletionItemKind
          local kind = kinds.Copilot
          if not kind then
            kind = #kinds + 1
            kinds[kind] = 'Copilot'
            kinds.Copilot = kind
          end
          for _, item in ipairs(items) do
            item.kind = kind
          end
          return items
        end,
      },
    }, opts)
  end,
  cmp = function(opts)
    load()
    ar.pack.add({
      src = 'https://github.com/zbirenbaum/copilot-cmp',
      lazy = false,
      setup = function()
        local copilot_cmp = require('copilot_cmp')
        copilot_cmp.setup({})
        vim.api.nvim_create_autocmd('LspAttach', {
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == 'copilot' then
              copilot_cmp._on_insert_enter(client, args.buf)
            end
          end,
        })
      end,
    })
    opts = vim.g.cmp_add_source(opts, {
      source = { name = 'copilot', group_index = 1, priority = 100 },
      menu = { copilot = '[CPL]' },
      format = {
        copilot = {
          icon = ar.ui.codicons.misc.octoface,
          hl = 'CmpItemKindCopilot',
        },
      },
    })
    opts.mapping = vim.tbl_extend('force', opts.mapping or {}, {
      ['<C-]>'] = require('cmp').mapping(function()
        local suggestion = require('copilot.suggestion')
        if suggestion.is_visible() then return suggestion.accept() end
        vim.api.nvim_feedkeys(vim.keycode('<Tab>'), 'n', false)
      end),
    })
    return opts
  end,
}
