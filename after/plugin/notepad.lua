if not rvim then return end

local api = vim.api

rvim.notepad = {
  loaded = false,
  buf = nil,
  win = nil,
}

--[[ launch_notepad()
-- Checks if notepad window is active first
-- then checks if notepad buffer has been initialized. If so, reuse the buffer, else, create a new scratch buffer
-- If window is not active, display a small floating window with the scratch buffer
--]]
-- ref: https://github.com/theopn/theovim/blob/main/lua/ui/notepad.lua#L28
function rvim.toggle_notepad()
  if not rvim.notepad.loaded or not api.nvim_win_is_valid(rvim.notepad.win) then
    if not rvim.notepad.buf or not api.nvim_buf_is_valid(rvim.notepad.buf) then
      -- Create a buffer if it none existed
      rvim.notepad.buf = api.nvim_create_buf(false, true)
      api.nvim_buf_set_option(rvim.notepad.buf, 'bufhidden', 'hide')
      api.nvim_buf_set_option(rvim.notepad.buf, 'filetype', 'markdown')
    end
    -- Create a window
    rvim.notepad.win = api.nvim_open_win(rvim.notepad.buf, true, {
      title = 'Notepad',
      title_pos = 'center',
      border = rvim.ui.current.border,
      relative = 'editor',
      style = 'minimal',
      height = math.ceil(vim.o.lines * 0.5),
      width = math.ceil(vim.o.columns * 0.5),
      row = 1, --> Top of the window
      col = math.ceil(vim.o.columns * 0.5), --> Far right; should add up to 1 with win_width
    })
    api.nvim_win_set_option(rvim.notepad.win, 'winblend', 30) --> Semi transparent buffer

    -- Keymaps
    local keymaps_opts = { silent = true, buffer = rvim.notepad.buf }
    map('n', '<ESC>', rvim.toggle_notepad, keymaps_opts)
    map('n', 'q', rvim.toggle_notepad, keymaps_opts)
  else
    api.nvim_win_hide(rvim.notepad.win)
  end
  rvim.notepad.loaded = not rvim.notepad.loaded
end

-- Creates an autocommand to launch the notepad
rvim.command('Notepad', rvim.toggle_notepad, { nargs = 0 })
map('n', '<localleader>no', rvim.toggle_notepad, { desc = 'toggle notepad' })