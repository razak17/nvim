return function()
  if not rvim.plugin_installed('hop.nvim') then return end

  local hop = require('hop')
  local map = vim.keymap.set

  -- remove h,j,k,l from hops list of keys
  hop.setup({ keys = 'etovxqpdygfbzcisuran' })
  rvim.nnoremap('s', hop.hint_char1)
  rvim.nnoremap('s', function()
    -- TODO: Multi window mode is currently not working in nvim 0.8
    hop.hint_char1({ multi_windows = false })
  end)
  -- NOTE: override F/f using hop motions
  map(
    { 'x', 'n', 'o' },
    'F',
    function()
      hop.hint_char1({
        direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
        current_line_only = true,
        inclusive_jump = false,
      })
    end
  )

  map(
    { 'x', 'n', 'o' },
    'f',
    function()
      hop.hint_char1({
        direction = require('hop.hint').HintDirection.AFTER_CURSOR,
        current_line_only = true,
        inclusive_jump = false,
      })
    end
  )

  map(
    { 'x', 'n' },
    't',
    function()
      hop.hint_char1({
        direction = require('hop.hint').HintDirection.AFTER_CURSOR,
        current_line_only = true,
        hint_offset = -1,
      })
    end
  )

  map(
    { 'x', 'n' },
    'T',
    function()
      hop.hint_char1({
        direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
        current_line_only = true,
        hint_offset = 1,
      })
    end
  )
end
