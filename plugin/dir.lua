if not ar then return end

local enabled = ar.config.explorer.variant == 'dir' or not ar.plugins.enable

if ar.none or not enabled then return end

local fn, api, fmt = vim.fn, vim.api, string.format

local function find_dir_float()
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    if
      api.nvim_win_get_config(win).relative ~= ''
      and vim.bo[buf].filetype == 'directory'
    then
      return win
    end
  end
end

local function open_dir_float(path)
  local win = find_dir_float()
  if win then
    api.nvim_set_current_win(win)
    return
  end

  local origin = api.nvim_get_current_win()
  local buf = fn.bufadd(vim.fs.normalize(path))
  fn.bufload(buf)
  vim.bo[buf].bufhidden = 'wipe'
  win = ar.open_buf_centered_popup(buf, true, {
    title = fmt('Directory: %s', vim.fs.basename(path)),
    title_pos = 'center',
    width = math.ceil(vim.o.columns * 0.45),
  })
  local group = api.nvim_create_augroup('DirFloat' .. win, { clear = true })
  api.nvim_create_autocmd('BufWinEnter', {
    group = group,
    callback = function(args)
      if api.nvim_get_current_win() ~= win then return end
      local selected = args.buf
      if fn.isdirectory(api.nvim_buf_get_name(selected)) == 1 then return end
      vim.schedule(function()
        if
          not api.nvim_win_is_valid(win)
          or api.nvim_win_get_buf(win) ~= selected
        then
          return
        end
        if not api.nvim_win_is_valid(origin) then
          for _, candidate in ipairs(api.nvim_tabpage_list_wins(0)) do
            if api.nvim_win_get_config(candidate).relative == '' then
              origin = candidate
              break
            end
          end
        end
        local ok, err = pcall(api.nvim_win_set_buf, origin, selected)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
          return
        end
        api.nvim_win_close(win, true)
        api.nvim_set_current_win(origin)
      end)
    end,
  })
  api.nvim_create_autocmd('WinClosed', {
    group = group,
    pattern = tostring(win),
    once = true,
    callback = function() api.nvim_del_augroup_by_id(group) end,
  })
end

map(
  'n',
  '<C-n>',
  function() open_dir_float(fn.getcwd()) end,
  { desc = 'dir: root' }
)
map('n', '-', function()
  local path = api.nvim_buf_get_name(0)
  local dir = path == '' and fn.getcwd()
    or fn.fnamemodify(vim.fs.normalize(path), ':h')
  open_dir_float(dir)
end, { desc = 'dir: current' })
