local niceties = ar.plugins.niceties
local get_cond = ar.get_plugin_cond

return {
  ------------------------------------------------------------------------------
  -- Scratch Pads
  ------------------------------------------------------------------------------
  {
    'LintaoAmons/scratch.nvim',
    cmd = { 'Scratch', 'ScratchPad', 'ScratchOpen' },
    keys = { { '<c-w>O', ':Scratch<cr>', desc = 'scratch: new' } },
  },
  {
    'carbon-steel/detour.nvim',
    cond = function() return get_cond('detour.nvim', niceties) end,
    cmd = { 'Detour' },
    keys = { { '<c-w><enter>', ':Detour<cr>', desc = 'detour: toggle' } },
  },
  {
    'yarospace/lua-console.nvim',
    keys = { { '<leader>ok', desc = 'lua-console: toggle' } },
    opts = {
      buffer = {
        prepend_result_with = '=> ',
        save_path = vim.fn.stdpath('state') .. '/lua-console.lua',
        load_on_start = true, -- load saved session on first entry
        preserve_context = true, -- preserve context between executions
      },
      windo = {
        border = 'double', -- single|double|rounded
        height = 0.6, -- percentage of main window
      },
      mappings = {
        toggle = '<leader>ok',
        quit = 'q',
        eval = '<CR>',
        clear = 'C',
        messages = 'M',
        save = 'S',
        load = 'L',
        resize_up = '<C-Up>',
        resize_down = '<C-Down>',
        help = '?',
      },
    },
  },
}
