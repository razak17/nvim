local minimal = ar.plugins.minimal

local function f(which)
  return function() require('flash')[which]() end
end

return {
  {
    'folke/flash.nvim',
    cond = not minimal,
    keys = {
      { mode = { 'n', 'x' }, 's', f('jump') },
      { 'S', f('treesitter') },
      { mode = { 'o' }, 'r', f('remote') },
      { mode = { 'x' }, '<c-s>', f('toggle') },
      { mode = { 'o', 'x' }, 'R', f('treesitter_search') },
    },
    opts = {
      modes = {
        char = {
          char_actions = function()
            return {
              [';'] = 'next',
              ['F'] = 'left',
              ['f'] = 'right',
            }
          end,
          enabled = true,
          keys = { 'f', 'F', 't', 'T', ';' }, -- remove "," from keys
          highlight = { backdrop = false },
          jump_labels = false,
          multi_line = true,
        },
        search = {
          enabled = true,
          highlight = { backdrop = false },
          jump = { autojump = false },
        },
      },
      jump = { autojump = true, nohlsearch = true },
      highlight = { backdrop = false },
      labels = 'asdfqwerzxcv', -- Limit labels to left side of the keyboard
      prompt = { win_config = { border = 'none' } },
      search = { wrap = true },
    },
    init = function()
      ar.highlight.plugin('flash', {
        theme = {
          ['onedark'] = {
            { FlashMatch = { link = 'Debug' } },
          },
        },
      })
    end,
    config = function(_, opts) require('flash').setup(opts) end,
  },
  {
    'ysmb-wtsg/in-and-out.nvim',
    cond = not minimal,
    -- stylua: ignore
    keys = {
      { mode = 'i', '<C-\\>', function() require('in-and-out').in_and_out() end },
    },
  },
}
