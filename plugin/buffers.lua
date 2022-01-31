function _G.DelThisBuffer()
  vim.api.nvim_exec(
    [[
      update
      "bprevious | split | bnext | bdelete
      split | bdelete
    ]],
    false
  )
end

function _G.DelToLeft()
  vim.api.nvim_exec(
    [[
      silent execute 'bdelete' join(range(1, bufnr() - 1))
    ]],
    false
  )
end

function _G.DelAllBuffers()
  vim.api.nvim_exec(
    [[
      wall
      silent execute 'bdelete ' . join(utils#buf_filt(0))
    ]],
    false
  )
end

function _G.DelAllExceptCurrent()
  vim.api.nvim_exec(
    [[
      wall
      silent execute 'bdelete ' . join(utils#buf_filt(1))
    ]],
    false
  )
end
