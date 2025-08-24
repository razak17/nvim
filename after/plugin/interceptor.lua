local enabled = ar_config.plugin.custom.interceptor.enable

if not ar or ar.none or not enabled then return end

local api, fn = vim.api, vim.fn

local config = { enable = true }

if not config then return end

-- ref: https://www.reddit.com/r/neovim/comments/16b0n3a/whats_your_new_favorite_functions_share_em/

---@param msg string The notification message
---@param title string The notification title
local function notify(msg, title)
  vim.notify(msg, vim.lsp.log_levels.INFO, {
    title = title,
    ---@param win integer The window handle
    on_open = function(win)
      api.nvim_set_option_value('filetype', 'markdown', {
        buf = api.nvim_win_get_buf(win),
      })
    end,
  })
end

---Open a given file path in a given program and remove the buffer for the file.
---@param buf integer The buffer handle for the opening buffer
---@param fpath string The file path given to the program
---@param fname string The file name used in notifications
---@param prog string? The program to execute against the file path
-- TODO: when disabled then enabled again, causes errors with deleting buffer
local function open_in_prog(buf, fpath, fname, prog)
  notify(string.format('Opening `%s`', fname), 'Open File in External Program')
  if prog == nil then ar.open_media(fpath) end
  if prog ~= nil then vim.system({ prog, fpath }, { detach = true }) end
  vim.schedule(function() api.nvim_buf_delete(buf, { force = true }) end)
end

ar.command('InterceptToggle', function()
  config.enable = not config.enable
  local state = '`Enabled`'
  if not config.enable then state = '`Disabled`' end
  notify('Intercept file open set to ' .. state, 'Intercept File Open')
end, { desc = 'Toggles intercepting BufNew to open files in custom programs' })
ar.add_to_select_menu(
  'command_palette',
  { ['Toggle Interceptor'] = 'InterceptToggle' }
)

ar.augroup('InterceptToggle', {
  event = { 'BufNew', 'BufReadPre' },
  pattern = {
    '*.png',
    '*.jpg',
    '*.ico',
    '*.avif',
    '*.webp',
    '*.pdf',
    '*.mp3',
    '*.mp4',
    '*.gif',
  },
  command = function(args)
    if not config.enable then return end
    local path, bufnr = args.match, args.buf
    local extension = fn.fnamemodify(path, ':e')
    local filename = fn.fnamemodify(path, ':t')
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
