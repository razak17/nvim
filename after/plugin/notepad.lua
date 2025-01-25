local enabled = ar_config.plugin.custom.notepad.enable

if not ar or ar.none or not enabled then return end

local api = vim.api

ar.notepad = {
  loaded = false,
  buf = nil,
  win = nil,
}

--[[ launch_notepad()
-- Checks if notepad window is active first
-- then checks if notepad buffer has been initialized. If so, reuse the buffer, else, create a new scratch buffer
-- If window is not active, display a small floating window with the scratch buffer
--]]
function ar.notepad.toggle()
  if not ar.notepad.loaded or not api.nvim_win_is_valid(ar.notepad.win) then
    if not ar.notepad.buf or not api.nvim_buf_is_valid(ar.notepad.buf) then
      -- Create a buffer if it none existed
      ar.notepad.buf = api.nvim_create_buf(false, true)
      api.nvim_set_option_value('bufhidden', 'hide', {
        buf = ar.notepad.buf,
      })
      api.nvim_set_option_value('filetype', 'markdown', {
        buf = ar.notepad.buf,
      })
      api.nvim_buf_set_lines(ar.notepad.buf, 0, 1, false, {
        '# Warning',
        '',
        '> Notepad clears when the current Neovim session closes',
      })
    end
    -- Create a window
    ar.notepad.win = api.nvim_open_win(ar.notepad.buf, true, {
      title = 'Notepad',
      title_pos = 'center',
      border = 'single',
      relative = 'editor',
      style = 'minimal',
      height = math.ceil(vim.o.lines * 0.5),
      width = math.ceil(vim.o.columns * 0.5),
      row = 1, --> Top of the window
      col = math.ceil(vim.o.columns * 0.5), --> Far right; should add up to 1 with win_width
    })

    api.nvim_set_option_value('winblend', 0, { win = ar.notepad.win })

    -- Keymaps
    local keymaps_opts = { silent = true, buffer = ar.notepad.buf }
    -- map('n', '<ESC>', ar.notepad.toggle, keymaps_opts)
    map('n', 'q', ar.notepad.toggle, keymaps_opts)
  else
    api.nvim_win_hide(ar.notepad.win)
  end
  ar.notepad.loaded = not ar.notepad.loaded
end

-- Creates an autocommand to launch the notepad
ar.command('Notepad', ar.notepad.toggle, { nargs = 0 })
map('n', '<localleader>no', ar.notepad.toggle, { desc = 'toggle notepad' })
