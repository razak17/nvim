-- Helper function to execute git commands and get output
local function git_cmd(dir, cmd)
  local handle =
    io.popen(string.format("cd '%s' && git %s 2>/dev/null", dir, cmd))
  if not handle then return nil end
  local result = handle:read('*a')
  handle:close()
  return result and result:gsub('\n$', '') or nil
end

-- Get last commit date in relative format
local function get_last_update(dir)
  return git_cmd(dir, "log -1 --format='%cr'") or 'Unknown'
end

-- Get last commit timestamp (for sorting)
local function get_last_commit_timestamp(dir)
  local timestamp = git_cmd(dir, "log -1 --format='%ct'")
  return timestamp and tonumber(timestamp) or 0
end

-- Get last commit date and message
local function get_last_commit(dir)
  local date = git_cmd(dir, "log -1 --format='%ci'")
  local message = git_cmd(dir, "log -1 --format='%s'")

  if not date or not message then return 'No commit info' end

  -- Format date as YYYY-MM-DD
  local formatted_date = date:match('(%d%d%d%d%-%d%d%-%d%d)')
  if not formatted_date then formatted_date = 'Unknown date' end

  -- Truncate message if too long
  if #message > 60 then message = message:sub(1, 57) .. '...' end

  return formatted_date .. ': ' .. message
end

-- Create floating window
local function create_floating_window(lines)
  local width = 150
  local height = math.min(#lines + 2, vim.o.lines - 10) -- +2 for borders, max height

  -- Calculate position to center the window
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'plugin-info')

  -- Window options
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Plugin Information ',
    title_pos = 'center',
  }

  -- Create window
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Set window options
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'cursorline', true)

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  -- Add key mappings to close the window
  local function close_window() vim.api.nvim_win_close(win, true) end

  vim.keymap.set('n', 'q', close_window, { buffer = buf, silent = true })
  vim.keymap.set('n', '<ESC>', close_window, { buffer = buf, silent = true })

  return buf, win
end

-- Format plugin data into table
local function format_plugin_table(plugin_data)
  local lines = {}

  -- Header
  table.insert(
    lines,
    string.format(
      '%-32s │ %-23s │ %s',
      'Name',
      'Last Update',
      'Last Commit'
    )
  )
  table.insert(
    lines,
    string.rep('─', 33)
      .. '┼'
      .. string.rep('─', 25)
      .. '┼'
      .. string.rep('─', 78)
  )

  -- Sort plugins by commit timestamp (oldest to latest)
  table.sort(plugin_data, function(a, b)
    -- If timestamps are equal, fall back to name sorting
    if a.timestamp == b.timestamp then return a.name < b.name end
    return a.timestamp < b.timestamp
  end)

  -- Plugin rows
  for _, plugin in ipairs(plugin_data) do
    local line = string.format(
      '%-32s │ %-23s │ %s',
      plugin.name:sub(1, 32),
      plugin.last_update,
      plugin.last_commit
    )
    table.insert(lines, line)
  end

  return lines
end

-- Main function to show plugin info
local function show_plugin_info()
  -- Check if lazy.nvim is available
  local ok, lazy = pcall(require, 'lazy')
  if not ok then
    vim.notify('lazy.nvim not found', vim.log.levels.ERROR)
    return
  end

  -- Show loading message
  vim.notify('Loading plugin information...', vim.log.levels.INFO)

  -- Get plugins from lazy.nvim
  local plugins = vim
    .iter(lazy.plugins())
    :map(function(plugin) return { name = plugin.name, dir = plugin.dir } end)
    :totable()

  if #plugins == 0 then
    vim.notify('No plugins found', vim.log.levels.WARN)
    return
  end

  -- Collect plugin information
  local plugin_data = {}

  for _, plugin in ipairs(plugins) do
    local last_update = get_last_update(plugin.dir)
    local last_commit = get_last_commit(plugin.dir)
    local timestamp = get_last_commit_timestamp(plugin.dir)

    table.insert(plugin_data, {
      name = plugin.name,
      last_update = last_update,
      last_commit = last_commit,
      timestamp = timestamp,
    })
  end

  -- Format and display
  local lines = format_plugin_table(plugin_data)
  create_floating_window(lines)
end

-- Create user command
vim.api.nvim_create_user_command(
  'PluginInfo',
  function() show_plugin_info() end,
  { desc = 'Show plugin information' }
)

vim.keymap.set(
  'n',
  '<leader>pi',
  show_plugin_info,
  { desc = 'Show plugin information' }
)
