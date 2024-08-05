if not ar or ar.none then return end

local api, opt_l = vim.api, vim.opt_local

ar.stickyNote = {
  loaded = false,
  floatData = {},
}

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
    api.nvim_set_option_value('winhl', table.concat(temp, ','), {
      win = win,
    })
  end
end

local function update_float(win, config)
  api.nvim_win_set_config(win, clean_config(config))
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
    config.relative == 'editor' and api.nvim_list_uis()[1]
    or config.relative == 'win' and {
      width = api.nvim_win_get_width(config.win or 0),
      height = api.nvim_win_get_height(config.win or 0),
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
  local buf = api.nvim_create_buf(false, true)
  -- pass in all the relevant info cus i can't be bother to clean it
  local win = api.nvim_open_win(buf, true, clean_config(config))

  -- change window hl group
  change_win_hl(win, config.highlight)

  -- set the title and id so it easier to go to
  config.ogTitle = config.title
  config.title = config.titleFunc == nil
      and api.nvim_win_get_number(win) .. ': ' .. config.ogTitle
    or config.titleFunc
  update_float(win, config)

  ar.stickyNote.floatData[vim.fn.win_getid()] = config

  return { win = win, buf = buf }
end

local function move_float(win, direction, amount)
  local config = ar.stickyNote.floatData[win]
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
  local config = ar.stickyNote.floatData[win]
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

local function action(key, direction, symbol, amount, desc, resize)
  map('n', key, function()
    local config = api.nvim_win_get_config(0)
    local win = api.nvim_get_current_win()
    if config.relative == '' then
      local feedkey = '<C-w>' .. symbol
      api.nvim_feedkeys(
        api.nvim_replace_termcodes('<C-w>' .. symbol, true, false, true),
        't',
        false
      )
    else
      if resize then
        resize_float(win, { direction = direction, amount = amount })
      else
        move_float(win, direction, amount)
      end
    end
  end, { desc = desc, buffer = 0 })
end

map('n', '<leader><leader>no', function()
  local float = create_float({
    relative = 'editor',
    position = 'center',
    title = 'Sticky',
    width = 20,
    height = 10,
    style = 'minimal',
    border = 'single',
    highlight = {
      Normal = 'NormalFloat',
      FloatTitle = 'FloatTitle',
      FloatBorder = 'FloatBorder',
    },
    moveCount = 5,
    shiftCount = 2,
  })
  api.nvim_set_option_value('filetype', 'sticky', { buf = float.buf })
  api.nvim_set_option_value('winblend', 0, { win = float.win })
  opt_l.wrap = true
  opt_l.linebreak = true
  vim.cmd.startinsert()

  -- Resize mappings
  action('<A-k>', 'up', '-', 5, 'resize [w]indow [up]', true)
  action('<A-j>', 'down', '+', 5, 'resize [w]indow [down]', true)
  action('<A-h>', 'left', '>', 5, 'resize [w]indow [left]', true)
  action('<A-l>', 'right', '<', 5, 'resize [w]indow [right]', true)
  -- Move mappings
  action('<leader>K', 'up', '<Up>', 15, 'switch to up window', false)
  action('<leader>J', 'down', '<Down>', 15, 'switch to down window', false)
  action('<leader>H', 'left', '<Left>', 15, 'switch to left window', false)
  action('<leader>L', 'right', '<Right>', 15, 'switch to right window', false)
end, { desc = 'new [w]indow [s]ticky note' })

-- map('n', '<leader>ww', '<C-w>w', { desc = 'switch [[w]]indow' })

ar.augroup('stickyNote', {
  event = { 'WinNew', 'WinEnter', 'WinClosed' },
  pattern = '*',
  command = function(data)
    if data.event == 'WinClosed' then
      ar.stickyNote.floatData[tonumber(data.match)] = nil
    end
    for win, config in pairs(ar.stickyNote.floatData) do
      config.title = config.titleFunc == nil
          and api.nvim_win_get_number(win) .. ': ' .. config.ogTitle
        or config.titleFunc
      update_float(win, config)
    end
  end,
})
