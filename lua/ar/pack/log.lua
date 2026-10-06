if not ar.get_plugin_cond('debugprint.nvim') then return end

local function load()
  vim.pack.add({
    'https://github.com/nvim-mini/mini.hipatterns',
    'https://github.com/andrewferrier/debugprint.nvim',
  }, { confirm = false })

  require('debugprint').setup({
    highlight_lines = true, -- Only works when plugin is not lazy-loaded
    keymaps = {
      normal = {
        plain_below = 'g?p',
        plain_above = 'g?P',
        variable_below = 'g?v',
        variable_above = 'g?V',
        variable_below_alwaysprompt = 'g?a',
        variable_above_alwaysprompt = 'g?A',
        surround_plain = 'g?sp',
        surround_variable = 'g?sv',
        textobj_below = 'g?o',
        textobj_above = 'g?O',
        toggle_comment_debug_prints = 'g?u',
        delete_debug_prints = 'g?x',
      },
      insert = {
        plain = '<C-g>p',
        variable = '<C-g>v',
      },
      visual = {
        variable_below = 'g?v',
        variable_above = 'g?V',
      },
    },
  })

  local function jump(o)
    local debugprint = require('debugprint.printtag_operations')
    return ar.jump(function(opts)
      if opts.forward then debugprint.jump_next_debug_print() end
      if not opts.forward then debugprint.jump_prev_debug_print() end
    end, o)
  end
  map('n', ']g', jump({ forward = true }), { desc = 'next debugprint' })
  map('n', '[g', jump({ forward = false }), { desc = 'prev debugprint' })
end

if vim.v.vim_did_enter == 1 then
  load()
else
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = load,
  })
end
