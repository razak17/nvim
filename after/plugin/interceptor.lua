if not rvim then return end

-- ref: https://www.reddit.com/r/neovim/comments/16b0n3a/whats_your_new_favorite_functions_share_em/

---Open a given file path in a given program and remove the buffer for the file.
---@param buf integer The buffer handle for the opening buffer
---@param fpath string The file path given to the program
---@param fname string The file name used in notifications
-- TODO: when disabled then enabled again, causes errors with deleting buffer
local function open_in_prog(buf, fpath, fname)
  vim.notify(string.format('Opening `%s`', fname), vim.log.levels.INFO, {
    title = 'Open File in External Program',
    ---@param win integer The window handle
    on_open = function(win)
      vim.api.nvim_buf_set_option(
        vim.api.nvim_win_get_buf(win),
        'filetype',
        'markdown'
      )
    end,
  })
  vim.system({ rvim.open_command, fpath }, { detach = true })
  print('DEBUGPRINT[1]: interceptor.lua:54: buf=' .. vim.inspect(buf))
  vim.api.nvim_buf_delete(buf, { force = true })
end

rvim.command('InterceptToggle', function()
  rvim.interceptor.enable = not rvim.interceptor.enable
  local intercept_state = '`Enabled`'
  if not rvim.interceptor.enable then intercept_state = '`Disabled`' end
  vim.notify(
    'Intercept file open set to ' .. intercept_state,
    vim.log.levels.INFO,
    {
      title = 'Intercept File Open',
      ---@param win integer The window handle
      on_open = function(win)
        vim.api.nvim_buf_set_option(
          vim.api.nvim_win_get_buf(win),
          'filetype',
          'markdown'
        )
      end,
    }
  )
end, { desc = 'Toggles intercepting BufNew to open files in custom programs' })

rvim.augroup('InterceptToggle', {
  event = { 'BufNew', 'BufReadPre' },
  pattern = { '*.jpg', '*.png', '*.pdf', '*.mp3', '*.mp4', '*.gif' },
  command = function(args)
    if not rvim.interceptor.enable then return end

    local path = args.match
    local bufnr = args.buf
    local extension = vim.fn.fnamemodify(path, ':e')
    local filename = vim.fn.fnamemodify(path, ':t')

    if
      filename
      and type(path) == 'string'
      and extension ~= nil
      and not extension:match('^%s*$')
    then
      open_in_prog(bufnr, path, filename)
    end
  end,
})
