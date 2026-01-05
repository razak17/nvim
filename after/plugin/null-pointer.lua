local enabled = ar.config.plugin.custom.null_pointer.enable

if not ar or ar.none or not enabled then return end

local api, fn = vim.api, vim.fn

---> Share the file or a range of lines over https://0x0.st .
function ar.null_pointer()
  local from = api.nvim_buf_get_mark(0, '<')[1]
  local to = api.nvim_buf_get_mark(0, '>')[1]
  local file = fn.tempname()
  vim.cmd(
    ':silent! ' .. (from == to and '' or from .. ',' .. to) .. 'w ' .. file
  )

  fn.jobstart({ 'curl', '-sF', 'file=@' .. file .. '', 'https://0x0.st' }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      ar.copy_to_clipboard(data[1])
      vim.notify('Copied ' .. data[1] .. ' to clipboard!')
    end,
    on_stderr = function(_, data)
      if data then print(table.concat(data)) end
    end,
  })
end

map('n', '<leader>up', ar.null_pointer, { desc = 'share code url' })
map(
  'x',
  '<localleader>pp',
  ':lua ar.null_pointer()<CR>gv<Esc>',
  { desc = 'share code url' }
)

ar.command('NullPointer', ar.null_pointer)
ar.add_to_select_menu('command_palette', { ['Share Code URL'] = 'NullPointer' })
