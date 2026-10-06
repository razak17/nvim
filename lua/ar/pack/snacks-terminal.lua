if not ar.has('snacks.nvim') then return end

if ar.config.terminal.variant ~= 'snacks' then return end

ar.augroup('SnacksTerminalResize', {
  event = { 'VimResized' },
  command = function()
    vim.schedule(function()
      for _, terminal in ipairs(Snacks.terminal.list()) do
        local width = terminal.opts.width
        if
          terminal.opts.position == 'right'
          and terminal:win_valid()
          and type(width) == 'number'
          and width > 0
          and width < 1
        then
          pcall(
            vim.api.nvim_win_resize,
            terminal.win,
            math.floor(vim.o.columns * width),
            -1
          )
        end
      end
    end)
  end,
})

ar.add_to_select('toggle', {
  ['Toggle Terminal'] = function() Snacks.terminal.focus() end,
})

ar.snacks_opts = vim.tbl_deep_extend('force', ar.snacks_opts or {}, {
  terminal = {
    enabled = true,
    win = {
      wo = { winbar = '' },
      position = 'right',
      width = 0.4,
    },
  },
})

-- stylua: ignore start
map({ 'n', 't' }, '<C-\\>', function() Snacks.terminal.focus() end, { desc = 'snacks: toggle terminal' })
-- stylua: ignore end
