local api = vim.api
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

local redraw_buffer = function()
  local Animation = require('animation')
  local fps = 45
  local easing = require('animation.easing')

  local current_buffer = api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(current_buffer, 0, -1, true)

  -- Create a new temporary buffer and set its filetype
  local temp_buffer = api.nvim_create_buf(false, true)
  local original_filetype =
    api.nvim_get_option_value('filetype', { buf = current_buffer })
  api.nvim_set_option_value('filetype', original_filetype, {
    buf = temp_buffer,
  })

  -- Copy the contents of the original buffer to the temporary buffer
  api.nvim_buf_set_lines(temp_buffer, 0, -1, true, lines)

  -- Switch to the temporary buffer
  api.nvim_set_current_buf(temp_buffer)

  -- Close the temporary buffer and return to the original buffer after animation ends
  local function close_temp_buffer()
    api.nvim_buf_delete(temp_buffer, { force = true })
    api.nvim_set_current_buf(current_buffer)
  end

  local len = 0
  local place_holder = {}
  for _, line in ipairs(lines) do
    len = len + string.len(line)
    table.insert(place_holder, '')
  end
  api.nvim_buf_set_lines(temp_buffer, 0, #lines, true, place_holder)

  local duration = math.ceil(len / fps * 1000)

  local i = 1
  local line_nr = 1
  local insertLine = ''

  local function callback()
    if lines[line_nr] == nil then
      close_temp_buffer()
      return true
    end
    local char = string.sub(lines[line_nr], i, i)
    if char == nil then
      line_nr = line_nr + 1
      i = 1
      insertLine = ''
      return true
    end
    insertLine = insertLine .. char
    i = i + 1
    api.nvim_buf_set_lines(
      temp_buffer,
      line_nr - 1,
      line_nr,
      true,
      { insertLine }
    )

    if insertLine == lines[line_nr] then
      line_nr = line_nr + 1
      i = 1
      insertLine = ''
    end
  end

  local animation = Animation(duration, fps, easing.line, callback)
  animation:run()
end

-- vim.defer_fn(redraw_buffer, 0)

return {
  {
    'anuvyklack/animation.nvim',
    cond = not minimal and niceties,
    keys = { { '<leader>Aa', redraw_buffer, desc = 'animation: start' } },
    dependencies = { 'anuvyklack/middleclass' },
  },
  {
    'letieu/hacker.nvim',
    cond = not minimal and niceties,
    event = 'VeryLazy',
    cmd = { 'Hack', 'HackAuto', 'HackFollow' },
  },
  {
    'eandrju/cellular-automaton.nvim',
    cmd = 'CellularAutomaton',
    -- stylua: ignore
    keys = {
      { '<leader>Ag', '<Cmd>CellularAutomaton game_of_life<CR>', desc = 'automaton: game of life', },
      { '<leader>Am', '<Cmd>CellularAutomaton make_it_rain<CR>', desc = 'automaton: make it rain', },
    },
  },
  {
    'razak17/flirt.nvim',
    cond = not minimal and niceties and ar.animation.enable,
    event = 'VeryLazy',
    opts = { speed = 100 },
  },
}
