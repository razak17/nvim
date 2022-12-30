local M = { 'windwp/nvim-autopairs', event = 'InsertEnter' }

function M.config()
  require('nvim-autopairs').setup({
    close_triple_quotes = true,
    check_ts = true,
    fast_wrap = { map = '<c-e>' },
    enable_check_bracket_line = false,
    disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
    ts_config = {
      java = false,
      lua = { 'string', 'source' },
      javascript = { 'string', 'template_string' },
    },
  })

  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
end

return M
