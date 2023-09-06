-- https://www.reddit.com/r/neovim/comments/16b0n3a/whats_your_new_favorite_functions_share_em/
-- TODO: use xdg-open
local augroup = vim.api.nvim_create_augroup('user-autocmds', { clear = true })
local intercept_file_open = true
vim.api.nvim_create_user_command('InterceptToggle', function()
  intercept_file_open = not intercept_file_open
  local intercept_state = '`Enabled`'
  if not intercept_file_open then intercept_state = '`Disabled`' end
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

-- NOTE: Add "BufReadPre" to the autocmd events to also intercept files given on the command line, e.g.
-- `nvim myfile.txt`
vim.api.nvim_create_autocmd({ 'BufNew', 'BufReadPre' }, {
  group = augroup,
  callback = function(args)
    ---@type string
    local path = args.match
    ---@type integer
    local bufnr = args.buf

    ---@type string? The file extension if detected
    local extension = vim.fn.fnamemodify(path, ':e')
    ---@type string? The filename if detected
    local filename = vim.fn.fnamemodify(path, ':t')

    ---Open a given file path in a given program and remove the buffer for the file.
    ---@param buf integer The buffer handle for the opening buffer
    ---@param fpath string The file path given to the program
    ---@param fname string The file name used in notifications
    ---@param prog string The program to execute against the file path
    local function open_in_prog(buf, fpath, fname, prog)
      vim.notify(
        string.format('Opening `%s` in `%s`', fname, prog),
        vim.log.levels.INFO,
        {
          title = 'Open File in External Program',
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
      vim.system({ prog, fpath }, { detach = true })
      -- WARN: If you are not on nightly (<0.10), remove the line above and uncomment the line below
      -- vim.fn.jobstart("prog " .. fpath, { detach = true })
      vim.api.nvim_buf_delete(buf, { force = true })
    end

    local extension_callbacks = {
      ['pdf'] = function(buf, fpath, fname)
        open_in_prog(buf, fpath, fname, 'zathura')
      end,
      ['png'] = function(buf, fpath, fname)
        open_in_prog(buf, fpath, fname, 'sxiv')
      end,
      ['jpg'] = 'png',
      ['mp4'] = function(buf, fpath, fname)
        open_in_prog(buf, fpath, fname, 'mpv')
      end,
      ['gif'] = 'mp4',
    }

    ---Get the extension callback for a given extension. Will do a recursive lookup if an extension callback is actually
    ---of type string to get the correct extension
    ---@param ext string A file extension. Example: `png`.
    ---@return fun(bufnr: integer, path: string, filename: string?) extension_callback The extension callback to invoke, expects a buffer handle, file path, and filename.
    local function extension_lookup(ext)
      local callback = extension_callbacks[ext]
      if type(callback) == 'string' then
        callback = extension_lookup(callback)
      end
      return callback
    end

    if
      extension ~= nil
      and not extension:match('^%s*$')
      and intercept_file_open
    then
      local callback = extension_lookup(extension)
      if type(callback) == 'function' then callback(bufnr, path, filename) end
    end
  end,
})
