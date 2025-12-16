local enabled = ar.config.plugin.custom.yank_ring.enable

if not ar or ar.none or not enabled then return end

-- https://www.reddit.com/r/neovim/comments/1jv03t1/simple_yankring/

local fn = vim.fn

-- store previous content of register 0
local prev_reg0_content = fn.getreg('0')

ar.augroup('YankRing', {
  event = { 'TextYankPost' },
  command = function()
    if vim.v.event.operator == 'y' then
      for i = 9, 2, -1 do
        fn.setreg(tostring(i), fn.getreg(tostring(i - 1)))
      end
      fn.setreg('1', prev_reg0_content)
      prev_reg0_content = fn.getreg('0')
    end
  end,
})
