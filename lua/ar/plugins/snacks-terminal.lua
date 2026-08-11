return {
  desc = 'snacks terminal',
  recommended = true,
  'folke/snacks.nvim',
  init = function()
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
                vim.api.nvim_win_set_width,
                terminal.win,
                math.floor(vim.o.columns * width)
              )
            end
          end
        end)
      end,
    })
  end,
  -- stylua: ignore
  keys = function(_, keys)
    keys = keys or {}
    if ar.config.terminal.variant == 'snacks' then
      ar.list_insert(keys, {
        { mode = { 'n', 't' }, '<C-\\>', function() Snacks.terminal.focus() end, desc = 'snacks: toggle terminal' },
      })
    end
  end,
  opts = function(_, opts)
    ar.add_to_select('toggle', {
      ['Toggle Terminal'] = function() Snacks.terminal.focus() end,
    })

    return vim.tbl_deep_extend('force', opts or {}, {
      terminal = {
        enabled = true,
        win = {
          wo = { winbar = '' },
          position = 'right',
          width = 0.4,
        },
      },
    })
  end,
}
