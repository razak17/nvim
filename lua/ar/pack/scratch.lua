ar.pack.add({
  {
    src = 'https://github.com/LintaoAmons/scratch.nvim',
    cond = function() return ar.get_plugin_cond('scratch.nvim') end,
    cmd = { 'Scratch', 'ScratchPad', 'ScratchOpen' },
    keys = { { '<c-w>O', ':Scratch<cr>', desc = 'scratch: new' } },
  },
  {
    src = 'https://github.com/carbon-steel/detour.nvim',
    cond = function()
      return ar.get_plugin_cond('detour.nvim', ar.plugins.niceties)
    end,
    cmd = { 'Detour' },
    keys = { { '<c-w><enter>', ':Detour<cr>', desc = 'detour: toggle' } },
  },
  {
    src = 'https://github.com/yarospace/lua-console.nvim',
    cond = function() return ar.get_plugin_cond('lua-console.nvim') end,
    keys = { { '<leader>ok', desc = 'lua-console: toggle' } },
    setup = function()
      require('lua-console').setup({
        buffer = {
          prepend_result_with = '=> ',
          save_path = vim.fn.stdpath('state') .. '/lua-console.lua',
          load_on_start = true, -- load saved session on first entry
          preserve_context = true, -- preserve context between executions
        },
        window = {
          border = vim.o.winborder, -- single|double|rounded
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
      })
    end,
  },
})
