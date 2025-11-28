local M = {}

function M.colorscheme_menu()
  local api = vim.api
  local schemes = {
    'golden',
    'silver',
    'bronze',
    'frank',
    'nolan',
    'arkham',
    'rebirth',
    'classic',
    'joker_day',
    'joker_night',
    'future',
    'future_red',
    'classic_yellow',
    'riddler',
    'twoface',
    'penguin',
    'catwoman',
    'bane',
    'scarecrow',
    'poisonivy',
    'mrfreeze',
    'harley',
  }

  -- local original_scheme = 'catwoman'
  local original_scheme = require('batman').read_persisted_theme()
  local buf = api.nvim_create_buf(false, true)

  local width = math.ceil(vim.o.columns * 0.4)
  local height = math.ceil(vim.o.lines * 0.7)
  local col = math.ceil((vim.o.columns - width) / 2)
  local row = math.ceil((vim.o.lines - height) / 2)

  local metalines = {
    'Available colorschemes: ' .. tostring(#schemes),
    'Press <Enter> to set, <Esc> to cancel (preview will revert)',
    'current colorscheme:',
    original_scheme,
    '',
  }

  vim.bo[buf].filetype = 'batman_colorschemes'
  vim.bo[buf].bufhidden = 'wipe'

  api.nvim_buf_set_lines(buf, 0, -1, false, metalines)
  for i, s in ipairs(schemes) do
    api.nvim_buf_set_lines(buf, #metalines + i, -1, false, { s })
  end

  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
  })

  vim.bo[buf].modifiable = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].cursorline = true
  vim.wo[win].scrolloff = 3
  vim.wo[win].winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder'

  -- create namespace for highlights
  local ns = api.nvim_create_namespace('batman_colorschemes_highlights')

  -- highlight header lines
  for i = 0, #metalines - 1 do
    pcall(api.nvim_buf_set_extmark, buf, ns, i, 0, {
      end_row = i + 1,
      end_col = 0,
      hl_group = 'Title',
    })
  end

  -- highlight the current scheme in the list (if present)
  local current_index = nil
  for i, s in ipairs(schemes) do
    if s == original_scheme then
      current_index = i
      break
    end
  end
  if current_index then
    local line = #metalines + (current_index - 1)
    pcall(api.nvim_buf_set_extmark, buf, ns, line, 0, {
      end_row = line + 1,
      end_col = 0,
      hl_group = 'DiffAdd',
    })
    -- move cursor to current scheme
    api.nvim_win_set_cursor(win, { line + 1, 0 })
  end

  local function close_menu()
    if api.nvim_win_is_valid(win) then api.nvim_win_close(win, true) end
    if api.nvim_buf_is_valid(buf) then
      api.nvim_buf_delete(buf, { force = true })
    end
  end

  local function on_line_change()
    local scheme_index, _ = unpack(api.nvim_win_get_cursor(win))
    scheme_index = scheme_index - #metalines
    if scheme_index >= 1 and scheme_index <= #schemes then
      vim.schedule(function() vim.cmd('Batman ' .. schemes[scheme_index]) end)
    end
  end

  local function on_esc()
    -- revert to original scheme and close
    if original_scheme and original_scheme ~= '' then
      vim.cmd('Batman ' .. original_scheme)
    end
    close_menu()
  end

  api.nvim_create_autocmd(
    'CursorMoved',
    { buffer = buf, callback = on_line_change }
  )

  map('n', '<Esc>', on_esc, { buffer = buf })
  map('n', 'q', on_esc, { buffer = buf })
end

return M
