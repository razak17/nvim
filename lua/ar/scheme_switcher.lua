-- https://github.com/amanbabuhemant/nvim/blob/733feb90c75364708367c4e088c7e8d23c3d7ef7/lua/scheme-switcher.lua#L1--[[ color scheme switcher ]]

--[[ color scheme switcher ]]
--

local api, fn = vim.api, vim.fn
local set_colorscheme_file_path = vim.fn.stdpath('data') .. '/.set_colorscheme'

local M = {}

function M.get_current_colorscheme()
  if ar.plugins.minimal then return 'default' end
  if not ar.plugins.niceties then return ar_config.colorscheme end
  local file = io.open(set_colorscheme_file_path, 'r')
  if not file then
    -- create a default file and return default
    if M and M.save_current_colorscheme then
      M.save_current_colorscheme(ar_config.colorscheme)
    else
      -- fallback to writing directly
      local f = io.open(set_colorscheme_file_path, 'w')
      if f then
        f:write('default')
        f:close()
      end
    end
    return 'default'
  else
    local ccs = file:read('*l')
    file:close()
    if not ccs or ccs == '' then return 'default' end
    return ccs
  end
end

function M.save_current_colorscheme(colorscheme)
  local file = io.open(set_colorscheme_file_path, 'w')
  if not file then
    print(
      'Error: could not open file for writing: ' .. set_colorscheme_file_path
    )
    return false
  end
  file:write(colorscheme)
  file:close()
  return true
end

-- backward compatible name (preserve existing calls)
M.save_current_colorscheme = M.save_current_colorscheme

function M.get_colorschemes() return fn.getcompletion('', 'color') end

function M.set_colorscheme(colorscheme) ar.load_colorscheme(colorscheme) end

function M.colorscheme_menu()
  local schemes = M.get_colorschemes()
  local original_scheme = M.get_current_colorscheme()
  local buf = api.nvim_create_buf(false, true)

  local win_w, win_h = api.nvim_win_get_width(0), api.nvim_win_get_height(0)

  -- compute width based on longest scheme name and cap it
  local max_name = 0
  for _, s in ipairs(schemes) do
    if #s > max_name then max_name = #s end
  end

  local min_w = 30
  local pane_w =
    math.min(math.max(max_name + 6, min_w), math.floor(win_w * 0.6))
  local pane_h = math.min(#schemes + 6, math.max(10, win_h - 20))

  local row = math.floor((win_h - pane_h) / 2)
  local col = math.floor((win_w - pane_w) / 2)

  local metalines = {
    'Available colorschemes: ' .. tostring(#schemes),
    'Press <Enter> to set, <Esc> to cancel (preview will revert)',
    'current colorscheme:',
    original_scheme,
    '',
  }

  api.nvim_buf_set_lines(buf, 0, -1, false, metalines)
  for i, s in ipairs(schemes) do
    api.nvim_buf_set_lines(buf, #metalines + i, -1, false, { s })
  end

  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = pane_w,
    height = math.min(pane_h, win_h - 2),
    border = 'single',
  })

  -- buffer/window appearance
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'scheme_switcher'
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].cursorline = true
  vim.wo[win].scrolloff = 3
  vim.wo[win].winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder'

  -- create namespace for highlights
  local ns = api.nvim_create_namespace('scheme_switcher_highlights')

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

  local function on_enter()
    local scheme_index, _ = unpack(api.nvim_win_get_cursor(win))
    scheme_index = scheme_index - #metalines
    if scheme_index < 1 or scheme_index > #schemes then
      print('invalid scheme selection')
      return
    end
    local choice = schemes[scheme_index]
    M.set_colorscheme(choice)
    M.save_current_colorscheme(choice)
    print('colorscheme set: ' .. choice)
    close_menu()
  end

  local function on_line_change()
    local scheme_index, _ = unpack(api.nvim_win_get_cursor(win))
    scheme_index = scheme_index - #metalines
    if scheme_index >= 1 and scheme_index <= #schemes then
      vim.schedule(function() M.set_colorscheme(schemes[scheme_index]) end)
    end
  end

  local function on_esc()
    -- revert to original scheme and close
    if original_scheme and original_scheme ~= '' then
      M.set_colorscheme(original_scheme)
    end
    close_menu()
  end

  api.nvim_create_autocmd(
    'CursorMoved',
    { buffer = buf, callback = on_line_change }
  )

  map('n', '<CR>', on_enter, { buffer = buf })
  map('n', '<Esc>', on_esc, { buffer = buf })
  -- map('n', 'P', on_line_change, { buffer = buf })
  map('n', 'q', on_esc, { buffer = buf })
end

ar.command('SwitchColorScheme', M.colorscheme_menu, {})
ar.command('SwitchColor', M.colorscheme_menu, {})

ar.add_to_select_menu(
  'command_palette',
  { ['Color Switcher'] = M.colorscheme_menu }
)

return M
