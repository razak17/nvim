local M = {}
local buffer

local function reason(info)
  local trigger = info.reason
  if not trigger then return 'not loaded' end
  if trigger.kind == 'dependency' then
    return 'dependency of ' .. (trigger.parent or '?')
  end
  local value = trigger.value and (' ' .. trigger.value) or ''
  if trigger.match and trigger.match ~= '' then
    value = value .. ' [' .. trigger.match .. ']'
  end
  return trigger.kind .. value
end

local function append(lines, label, value)
  if value == nil or value == '' then return end
  lines[#lines + 1] = label
  for _, line in ipairs(vim.split(tostring(value), '\n', { plain = true })) do
    lines[#lines + 1] = '  ' .. line
  end
end

local function details(info)
  local lines = {
    'Plugin: ' .. info.name,
    'Source: ' .. info.src,
    'State: ' .. info.status,
    'Lazy: ' .. tostring(info.lazy),
    'Local checkout: ' .. tostring(info.dev),
    'Load cause: ' .. reason(info),
  }
  if info.load_ms then
    lines[#lines + 1] = ('Load time: %.3f ms'):format(info.load_ms)
  end
  lines[#lines + 1] = 'Load time includes dependencies and waited builds.'
  lines[#lines + 1] = ''
  append(lines, 'Dependencies:', table.concat(info.dependencies, '\n'))
  for _, entry in ipairs({
    { 'events', 'Events:' },
    { 'commands', 'Commands:' },
    { 'filetypes', 'Filetypes:' },
    { 'keys', 'Keys:' },
  }) do
    append(lines, entry[2], table.concat(info.triggers[entry[1]], '\n'))
  end
  if info.keys_callback then
    lines[#lines + 1] =
      'Keys callback: yes, manual triggers are caller-managed.'
  end
  append(lines, 'Load error:', info.error)
  if info.build then
    local build = info.build
    lines[#lines + 1] = ''
    lines[#lines + 1] = 'Build: ' .. build.status
    append(
      lines,
      'Command:',
      type(build.command) == 'table' and vim.inspect(build.command)
        or build.command
    )
    append(lines, 'Directory:', build.path)
    append(lines, 'Revision:', build.revision)
    if build.duration_ms then
      lines[#lines + 1] = ('Build time: %.3f ms'):format(build.duration_ms)
    end
    if build.code then lines[#lines + 1] = 'Exit code: ' .. build.code end
    append(lines, 'Build error:', build.error)
    append(lines, 'stdout:', build.stdout)
    append(lines, 'stderr:', build.stderr)
  end
  return lines
end

local function render(snapshot)
  local lines
  if snapshot.src then
    lines = details(snapshot)
  else
    local loaded, failed = 0, 0
    for _, info in ipairs(snapshot) do
      if info.status == 'loaded' then loaded = loaded + 1 end
      if info.status == 'failed' then failed = failed + 1 end
    end
    lines = {
      ('ar.pack: %d plugins, %d loaded, %d failed'):format(
        #snapshot,
        loaded,
        failed
      ),
      'Load times include dependencies and waited builds.',
      'Use :ArPackInfo <plugin> for dependencies, errors and build output.',
      '',
      ('%-28s %-10s %10s  %-12s %s'):format(
        'Plugin',
        'State',
        'Load ms',
        'Build',
        'Loaded by'
      ),
    }
    for _, info in ipairs(snapshot) do
      lines[#lines + 1] = ('%-28s %-10s %10s  %-12s %s'):format(
        info.name,
        info.status,
        info.load_ms and ('%.3f'):format(info.load_ms) or '-',
        info.build and info.build.status or '-',
        reason(info)
      )
    end
    if #snapshot == 0 then
      lines[#lines + 1] = 'No plugins registered through ar.pack.add().'
    end
  end
  lines[#lines + 1] = ''
  lines[#lines + 1] = 'r refresh    q close'
  return lines
end

function M.open(snapshot)
  -- Validate the selection before creating a window.
  local lines = render(snapshot())
  local window
  if buffer and vim.api.nvim_buf_is_valid(buffer) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == buffer then
        window = win
        break
      end
    end
  end
  if window then
    vim.api.nvim_set_current_win(window)
  else
    vim.cmd('noautocmd botright new')
    buffer = vim.api.nvim_get_current_buf()
    vim.cmd(
      'noautocmd setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile filetype=arpackinfo'
    )
    vim.cmd('noautocmd setlocal nonumber norelativenumber nowrap')
    vim.cmd('noautocmd file ar-pack://info/' .. buffer)
  end
  local buf = buffer
  local function write(content)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
  end
  write(lines)
  vim.keymap.set('n', 'r', function()
    local ok, content = pcall(function() return render(snapshot()) end)
    if ok then
      write(content)
    else
      vim.notify(tostring(content), vim.log.levels.ERROR)
    end
  end, { buffer = buf, silent = true, desc = 'Refresh plugin diagnostics' })
  vim.keymap.set(
    'n',
    'q',
    function() vim.api.nvim_win_close(0, false) end,
    { buffer = buf, silent = true, desc = 'Close plugin diagnostics' }
  )
  return buf
end

return M
