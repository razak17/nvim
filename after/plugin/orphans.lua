local enabled = ar_config.plugin.custom.orphans.enable

if not ar or ar.none or not enabled then return end

local api, fn = vim.api, vim.fn
local L = vim.log.levels

local M = {}

local config = {
  date_format = '%Y-%m-%d',
  analyzing_timeout = 2000,
  ignored = {},
}

local state = {
  win_id = nil,
  buf_id = nil,
  loading_win = nil,
  loading_buf = nil,
}

local function is_ignored(plugin_name)
  for _, ignored in ipairs(config.ignored) do
    if plugin_name == ignored then return true end
  end
  return false
end

local function get_plugin_dirs()
  local lazy_path = fn.stdpath('data') .. '/lazy'
  local plugin_dirs = {}

  local dirs = fn.glob(lazy_path .. '/*', false, true)

  for _, dir in ipairs(dirs) do
    if fn.isdirectory(dir) == 1 then
      local name = fn.fnamemodify(dir, ':t')
      if not is_ignored(name) then table.insert(plugin_dirs, dir) end
    end
  end

  return plugin_dirs
end

local function format_time_delta(timestamp)
  local now = os.time()
  local diff = now - timestamp
  local days = math.floor(diff / 86400)

  if days == 0 then
    return 'today'
  elseif days == 1 then
    return '1 day ago'
  elseif days < 30 then
    return days .. ' days ago'
  elseif days < 365 then
    local months = math.floor(days / 30)
    return months == 1 and '1 month ago' or months .. ' months ago'
  else
    local years = math.floor(days / 365)
    return years == 1 and '1 year ago' or years .. ' years ago'
  end
end

local function show_loading()
  if state.loading_win and api.nvim_win_is_valid(state.loading_win) then
    return
  end

  local width = 50
  local height = 3
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  state.loading_buf = api.nvim_create_buf(false, true)
  state.loading_win = api.nvim_open_win(state.loading_buf, false, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    border = 'single',
    title = 'Analyzing plugins...',
    title_pos = 'center',
    style = 'minimal',
  })
end

local function update_loading(percent)
  if not state.loading_buf or not api.nvim_buf_is_valid(state.loading_buf) then
    return
  end

  local bar_width = 40
  local filled = math.floor(bar_width * percent / 100)
  local bar = string.rep('█', filled) .. string.rep('░', bar_width - filled)

  api.nvim_buf_set_lines(state.loading_buf, 0, -1, false, {
    '┌' .. string.rep('─', bar_width + 8) .. '┐',
    '│ ' .. bar .. string.format(' %3d%%  │', percent),
    '└' .. string.rep('─', bar_width + 8) .. '┘',
  })
end

local function close_loading()
  if state.loading_win and api.nvim_win_is_valid(state.loading_win) then
    api.nvim_win_close(state.loading_win, true)
  end
  if state.loading_buf and api.nvim_buf_is_valid(state.loading_buf) then
    api.nvim_buf_delete(state.loading_buf, { force = true })
  end
  state.loading_win = nil
  state.loading_buf = nil
end

local function close_main_window()
  if state.win_id and api.nvim_win_is_valid(state.win_id) then
    api.nvim_win_close(state.win_id, true)
  end
  if state.buf_id and api.nvim_buf_is_valid(state.buf_id) then
    api.nvim_buf_delete(state.buf_id, { force = true })
  end
  state.win_id = nil
  state.buf_id = nil
end

local function show_plugins(plugins)
  close_loading()

  if state.win_id and api.nvim_win_is_valid(state.win_id) then
    close_main_window()
  end

  local width = math.min(140, vim.o.columns - 4)
  local height = math.min(40, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  state.buf_id = api.nvim_create_buf(false, true)

  -- Set filetype to cheatsheet
  vim.bo[state.buf_id].filetype = 'cheatsheet'

  state.win_id = api.nvim_open_win(state.buf_id, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    border = 'single',
    title = string.format('Orphaned Plugins (%d found)', #plugins),
    title_pos = 'center',
    style = 'minimal',
  })

  local lines = {
    '',
    " Press 'q' to close, 'r' to refresh",
    '',
    string.format(
      '%-30s │ %-20s │ %-12s │ %s',
      'Plugin',
      'Last Update',
      'Date',
      'Last Commit'
    ),
    string.rep('─', 31)
      .. '┼'
      .. string.rep('─', 22)
      .. '┼'
      .. string.rep('─', 14)
      .. '┼'
      .. string.rep('─', 60),
  }

  for _, plugin in ipairs(plugins) do
    local name = plugin.name
    if #name > 30 then name = name:sub(1, 27) .. '...' end

    local msg = plugin.last_commit_msg or ''
    if #msg > 63 then msg = msg:sub(1, 60) .. '...' end

    table.insert(
      lines,
      string.format(
        '%-30s │ %-20s │ %-12s │ %s',
        name,
        plugin.time_delta,
        plugin.date_str,
        msg
      )
    )
  end

  if #plugins == 0 then
    table.insert(lines, '')
    table.insert(lines, ' No orphaned plugins found! 🎉')
  end

  api.nvim_buf_set_lines(state.buf_id, 0, -1, false, lines)
  vim.bo[state.buf_id].modifiable = false
  vim.bo[state.buf_id].buftype = 'nofile'
  vim.wo[state.win_id].cursorline = true
  vim.wo[state.win_id].wrap = false

  map('n', 'q', close_main_window, { buffer = state.buf_id })
  map('n', 'r', function()
    close_main_window()
    M.show_orphans()
  end, { buffer = state.buf_id })
end

function M.show_orphans(opts)
  opts = opts or {}

  local plugin_dirs = {}

  if opts.all then plugin_dirs = get_plugin_dirs() end

  if opts.all_lazy then
    plugin_dirs = vim
      .iter(require('lazy.core.config').plugins)
      :map(function(_, plugin) return plugin.dir end)
      :totable()
  end

  if opts.loaded then
    plugin_dirs = vim
      .iter(require('lazy').plugins())
      :filter(function(plugin) return plugin._.loaded ~= nil end)
      :map(function(plugin) return plugin.dir end)
      :totable()
  end

  if #plugin_dirs == 0 then
    vim.notify('No plugins found', L.INFO, { title = 'Orphans' })
    return
  end

  -- Get first 10 (for testing purposes)
  -- plugin_dirs = vim.list_slice(plugin_dirs, 1, 10)

  show_loading()
  update_loading(0)

  local plugins = {}
  local completed = 0
  local total = #plugin_dirs

  local function check_completion()
    completed = completed + 1
    local percent = math.floor((completed / total) * 100)
    update_loading(percent)

    if completed == total then
      table.sort(
        plugins,
        function(a, b) return a.last_commit_time < b.last_commit_time end
      )
      show_plugins(plugins)
    end
  end

  for _, dir in ipairs(plugin_dirs) do
    local name = fn.fnamemodify(dir, ':t')

    vim.system(
      { 'git', 'log', '-1', '--format=%ct%n%s', '.' },
      { cwd = dir },
      function(result)
        if result.code == 0 and result.stdout then
          local lines = vim.split(result.stdout, '\n')
          local timestamp = tonumber(lines[1])
          local commit_msg = lines[2] or ''

          if timestamp then
            table.insert(plugins, {
              name = name,
              path = dir,
              last_commit_time = timestamp,
              date_str = os.date(config.date_format, timestamp),
              time_delta = format_time_delta(timestamp),
              last_commit_msg = commit_msg:gsub('^%s+', ''):gsub('%s+$', ''),
            })
          end
        end
        vim.schedule(check_completion)
      end
    )
  end
end

api.nvim_create_user_command('OrphansLazy', function(args)
  local cmd = vim.trim(args.args or '')
  local opts = {}
  if cmd == 'all' then
    opts.all = true
  elseif cmd == 'all_lazy' then
    opts.all_lazy = true
  elseif cmd == 'loaded' then
    opts.loaded = true
  elseif cmd ~= '' then
    vim.notify('Invalid argument.', L.ERROR, { title = 'Orphans' })
    return
  end
  M.show_orphans(opts)
end, {
  nargs = '?',
  desc = 'Show orphaned plugins in lazy.nvim',
  complete = function() return { 'all', 'all_lazy', 'loaded' } end,
})
