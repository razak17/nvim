local M = { 'zbirenbaum/copilot.lua', event = 'VeryLazy' }

function M.config()
  require('copilot').setup({
    suggestion = { auto_trigger = true },
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
  })
  local cmp = require('cmp')
  cmp.event:on('menu_opened', function() vim.b.copilot_suggestion_hidden = true end)
  cmp.event:on('menu_closed', function() vim.b.copilot_suggestion_hidden = false end)
end

return M
