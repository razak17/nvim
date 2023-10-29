if not rvim then return end

local M = {}

rvim.stickyNote = {
  loaded = false,
  floatData = {},
}

-- ref: https://github.com/Mouthless-Stoat/Nvim-config/blob/master/lua/helper/float.lua
function math.clamp(val, min, max) return math.max(math.min(max, val), min) end

local function clean_config(config)
  return {
    relative = config.relative,
    win = config.win,
    anchor = config.anchor,
    width = config.width,
    height = config.height,
    bufpos = config.bufpos,
    row = config.row,
    col = config.col,
    focusable = config.focusable,
    external = config.external,
    zindex = config.zindex,
    style = config.style,
    border = config.border,
    title = config.title,
    title_pos = config.title_pos,
  }
end

local function change_win_hl(win, hl)
  -- change the window hl
  if hl ~= nil then
    local temp = {}
    for hn, hs in pairs(hl) do
      table.insert(temp, hn .. ':' .. hs)
    end
    vim.api.nvim_win_set_option(win, 'winhl', table.concat(temp, ','))
  end
end

local function update_float(win, config)
  vim.api.nvim_win_set_config(win, clean_config(config))
end

--[[
config is just normal vim.api.nvim_open_win() opts with a few extra
{
    position = "center" -- auto center when create
    highlight = { -- window hl key is hl name and value is hl to
        "Normal" = "",
        "FloatBorder" = "",
        "FloatTitle" = "",
        -- etc
    }
    titleFunc = function() end -- function to generate title
}
--]]
local function create_float(config)
  local col = 0
  local row = 0

  local container = (
    config.relative == 'editor' and vim.api.nvim_list_uis()[1]
    or config.relative == 'win' and {
      width = vim.api.nvim_win_get_width(config.win or 0),
      height = vim.api.nvim_win_get_height(config.win or 0),
    }
    or {}
  )

  -- postion it if a postion is set
  if config.position == 'center' then
    col = (container.width / 2) - (config.width / 2)
    row = (container.height / 2) - (config.height / 2)
  end

  config.col = col
  config.row = row
  config.container = container

  -- make the window and buffer
  local buf = vim.api.nvim_create_buf(false, true)
  -- pass in all the relevant info cus i can't be bother to clean it
  local win = vim.api.nvim_open_win(buf, true, clean_config(config))

  -- change window hl group
  change_win_hl(win, config.highlight)

  -- set the title and id so it easier to go to
  ---@diagnostic disable-next-line: need-check-nil
  config.ogTitle = config.title
  config.title = config.titleFunc == nil
      and vim.api.nvim_win_get_number(win) .. ': ' .. config.ogTitle
    or config.titleFunc
  update_float(win, config)

  rvim.stickyNote.floatData[vim.fn.win_getid()] = config

  return { win = win, buf = buf }
end

local function move_float(win, direction, amount)
  local config = rvim.stickyNote.floatData[win]
  -- calculate the amount base on which direction and moveCount
  amount = (amount or config.moveCount or 1)
    * (
      (direction == 'up' or direction == 'left') and -1
      or (direction == 'down' or direction == 'right') and 1
      or 0
    )
  -- helper function instead of typing ternary hell
  local function checkDir(ifX, ifY)
    return (direction == 'left' or direction == 'right') and ifX
      or (direction == 'up' or direction == 'down') and ifY
      or ''
  end
  config[checkDir('col', 'row')] = math.clamp(
    config[checkDir('col', 'row')] + amount,
    0,
    config.container[checkDir('width', 'height')]
      - config[checkDir('width', 'height')]
  )
  update_float(win, config)
end

local function resize_float(win, opt)
  local config = rvim.stickyNote.floatData[win]
  if opt.width and opt.height then
    config.width = opt.width
    config.height = opt.height
  else
    local amount = (opt.amount or config.shiftCount or 1)
      * (
        (opt.direction == 'up' or opt.direction == 'left') and -1
        or (opt.direction == 'down' or opt.direction == 'right') and 1
        or 0
      )
    local temp = (
      (opt.direction == 'left' or opt.direction == 'right') and 'width'
      or (opt.direction == 'up' or opt.direction == 'down') and 'height'
      or ''
    )

    config[temp] =
      math.clamp(config[temp] + amount, 1, config.container[temp] - 2)
  end
  update_float(win, config)
end

rvim.augroup('stickyNote', {
  event = { 'WinNew', 'WinEnter', 'WinClosed' },
  pattern = '*',
  command = function(data)
    if data.event == 'WinClosed' then
      rvim.stickyNote.floatData[tonumber(data.match)] = nil
    end
    for win, config in pairs(rvim.stickyNote.floatData) do
      config.title = config.titleFunc == nil
          and vim.api.nvim_win_get_number(win) .. ': ' .. config.ogTitle
        or config.titleFunc
      update_float(win, config)
    end
  end,
})

map('n', '<leader><leader>no', function()
  create_float({
    relative = 'editor',
    position = 'center',
    title = 'Sticky',
    width = 20,
    height = 10,
    style = 'minimal',
    border = 'single',
    highlight = {
      Normal = 'Normal',
      FloatTitle = 'FloatTitle',
      FloatBorder = 'FloatBorder',
    },
    moveCount = 5,
    shiftCount = 2,
  })
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.cmd.startinsert()
end, { desc = 'new [w]indow [s]ticky note' })

map('n', '<Leader>ww', '<C-w>w', { desc = 'switch [[w]]indow' })

map('n', '<leader><leader>nK', function()
  local config = vim.api.nvim_win_get_config(0)
  local win = vim.api.nvim_get_current_win()
  if config.relative == '' then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-w>-', true, false, true),
      't',
      false
    )
  else
    resize_float(win, { direction = 'up', amount = 5 })
  end
end, { desc = 'resize [w]indow [up]' })
map('n', '<leader><leader>nJ', function()
  local config = vim.api.nvim_win_get_config(0)
  local win = vim.api.nvim_get_current_win()
  if config.relative == '' then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-w>+', true, false, true),
      't',
      false
    )
  else
    resize_float(win, { direction = 'down', amount = 5 })
  end
end, { desc = 'resize [w]indow [down]' })
map('n', '<leader><leader>nH', function()
  local config = vim.api.nvim_win_get_config(0)
  local win = vim.api.nvim_get_current_win()
  if config.relative == '' then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-w>>', true, false, true),
      't',
      false
    )
  else
    resize_float(win, { direction = 'left', amount = 5 })
  end
end, { desc = 'resize [w]indow [left]' })
map('n', '<leader><leader>nL', function()
  local config = vim.api.nvim_win_get_config(0)
  local win = vim.api.nvim_get_current_win()
  if config.relative == '' then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-w><', true, false, true),
      't',
      false
    )
  else
    resize_float(win, { direction = 'right', amount = 5 })
  end
end, { desc = 'resize [w]indow [right]' })

map('n', '<leader><leader>nk', function()
  local config = vim.api.nvim_win_get_config(0)
  local win = vim.api.nvim_get_current_win()
  if config.relative == '' then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-w><Up>', true, false, true),
      't',
      false
    )
  else
    move_float(win, 'up', 5)
  end
end, { desc = 'switch to up window' })
map('n', '<leader><leader>nj', function()
  local config = vim.api.nvim_win_get_config(0)
  local win = vim.api.nvim_get_current_win()
  if config.relative == '' then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-w><Down>', true, false, true),
      't',
      false
    )
  else
    move_float(win, 'down', 5)
  end
end, { desc = 'switch to down window' })
map('n', '<leader><leader>nh', function()
  local config = vim.api.nvim_win_get_config(0)
  local win = vim.api.nvim_get_current_win()
  if config.relative == '' then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-w><Left>', true, false, true),
      't',
      false
    )
  else
    move_float(win, 'left', 5)
  end
end, { desc = 'switch to left window' })
map('n', '<leader><leader>nl', function()
  local config = vim.api.nvim_win_get_config(0)
  local win = vim.api.nvim_get_current_win()
  if config.relative == '' then
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-w><Right>', true, false, true),
      't',
      false
    )
  else
    move_float(win, 'right', 5)
  end
end, { desc = 'switch to right window' })

return M
