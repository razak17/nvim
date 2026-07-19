if not ar then return end

local enabled = ar.config.terminal.variant == 'custom'

if ar.none or not enabled then return end

local api, fn, bo, o = vim.api, vim.fn, vim.bo, vim.o

-- https://github.com/theopn/dotfiles/blob/27952026aa8ee8b9a1cff3741eb5150e9468c493/nvim/.config/nvim/lua/theovim/keymaps.lua#L2

-- Toggle-able floating terminal based on TJ DeVries's video
local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(o.columns * 0.9)
  local height = opts.height or math.floor(o.lines * 0.8)
  -- Calculate the position to center the window
  local col = math.floor((o.columns - width) / 2)
  local row = math.floor((o.lines - height) / 2)
  -- Create a buffer
  local buf = nil
  if api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = api.nvim_create_buf(false, true) -- No file, scratch buffer
  end
  -- Create the floating window
  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = o.winborder,
  }
  local win = api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window({ buf = state.floating.buf })
    if bo[state.floating.buf].buftype ~= 'terminal' then vim.cmd.terminal() end
    vim.cmd.startinsert()
  else
    api.nvim_win_hide(state.floating.win)
  end
end

api.nvim_create_user_command('Floaterminal', toggle_terminal, {})
map(
  { 'n', 't' },
  '<C-\\>',
  toggle_terminal,
  { desc = '[T]oggle floating [T]erminal' }
)

--           | :top sp |
-- |:top vs| |:abo| cu | |:bot vs |
-- |       | |:bel| rr | |        |
--           | :bot sp |
-- botright == bot
map(
  'n',
  '<leader>tb',
  function()
    vim.cmd('botright ' .. math.ceil(fn.winheight(0) * 0.3) .. 'sp | term')
  end,
  { desc = 'Launch a [T]erminal in the [B]ottom' }
)

map(
  'n',
  '<leader>tr',
  function() vim.cmd('bot ' .. math.ceil(fn.winwidth(0) * 0.3) .. 'vs | term') end,
  { desc = 'Launch a [T]erminal to the [R]ight' }
)
