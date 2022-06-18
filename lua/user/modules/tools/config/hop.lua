return function()
  local hop = require("hop")
  -- remove h,j,k,l from hops list of keys
  hop.setup({ keys = "etovxqpdygfbzcisuran" })
  rvim.nnoremap("s", hop.hint_char1)
  rvim.nnoremap("s", function()
    hop.hint_char1({ multi_windows = false })
  end)
  -- NOTE: override F/f using hop motions
  vim.keymap.set({ "x", "n" }, "F", function()
    hop.hint_char1({
      direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
      current_line_only = false,
      inclusive_jump = false,
    })
  end)
  vim.keymap.set({ "x", "n" }, "f", function()
    hop.hint_char1({
      direction = require("hop.hint").HintDirection.AFTER_CURSOR,
      current_line_only = false,
      inclusive_jump = false,
    })
  end)
  rvim.onoremap("F", function()
    hop.hint_char1({
      direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
      current_line_only = false,
      inclusive_jump = false,
    })
  end)
  rvim.onoremap("f", function()
    hop.hint_char1({
      direction = require("hop.hint").HintDirection.AFTER_CURSOR,
      current_line_only = false,
      inclusive_jump = false,
    })
  end)
end
