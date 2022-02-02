function _G.DelAllExceptCurrent()
  vim.api.nvim_exec(
    [[
      wall
      silent execute 'bdelete ' . join(utils#buf_filt(1))
    ]],
    false
  )
end
