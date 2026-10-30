local api = vim.api
local model = require('ar.core.pack.ui.model')
local actions = require('ar.core.pack.ui.actions')
local style = require('ar.core.pack.ui.highlights')
local M, Session = {}, {}
Session.__index = Session
local current

local function quiet(run)
  local ignored = vim.o.eventignore
  vim.o.eventignore = 'all'
  local ok, result = xpcall(run, debug.traceback)
  vim.o.eventignore = ignored
  if not ok then error(result, 0) end
  return result
end

local function valid(win) return win ~= nil and api.nvim_win_is_valid(win) end

local function write(buf, lines)
  vim.bo[buf].modifiable = true
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable, vim.bo[buf].modified = false, false
end

local function fit(text, width)
  text = text:gsub('[\r\n]', ' ')
  while vim.fn.strdisplaywidth(text) > width do
    text = vim.fn.strcharpart(text, 0, vim.fn.strchars(text) - 1)
  end
  return text .. string.rep(' ', width - vim.fn.strdisplaywidth(text))
end

local function filter_name(id)
  for _, filter in ipairs(model.filters) do
    if filter.id == id then return filter.label end
  end
  error('Unknown package filter: ' .. tostring(id))
end

local function geometry()
  local width =
    math.max(1, math.min(vim.o.columns - 4, math.floor(vim.o.columns * 0.9)))
  local height =
    math.max(1, math.min(vim.o.lines - 4, math.floor(vim.o.lines * 0.8)))
  local row = math.max(0, math.floor((vim.o.lines - height - 2) / 2))
  local col = math.max(0, math.floor((vim.o.columns - width - 2) / 2))
  local function pane(x, y, w, h, title, footer)
    return {
      relative = 'editor',
      row = y,
      col = x,
      width = w,
      height = h,
      style = 'minimal',
      border = vim.o.winborder,
      title = title,
      title_pos = 'left',
      footer = w >= 30 and style.footer(footer) or '',
      footer_pos = 'left',
      zindex = 60,
      noautocmd = true,
    }
  end
  local left, right
  if width >= 90 and height >= 8 then
    local list_width = math.floor((width - 3) * 0.42)
    left = pane(
      col,
      row,
      list_width,
      height,
      ' Packages ',
      ' c/C Check  u Update  / Search  f Filter '
    )
    right = pane(
      col + list_width + 3,
      row,
      width - list_width - 3,
      height,
      ' Details ',
      ' l Load  b Build  o Dir  r Refresh  q Close '
    )
  elseif height >= 12 then
    local list_height = math.floor((height - 3) / 2)
    left = pane(
      col,
      row,
      width,
      list_height,
      ' Packages ',
      ' c/C Check  u Update  / Search  f Filter '
    )
    right = pane(
      col,
      row + list_height + 3,
      width,
      height - list_height - 3,
      ' Details ',
      ' l Load  b Build  o Dir  r Refresh  q Close '
    )
  else
    left = pane(
      col,
      row,
      width,
      height,
      ' Packages ',
      ' / Search  f Filter  Tab Details  q Close '
    )
  end
  return { list = left, detail = right }
end

function Session:valid()
  return not self.closing
    and valid(self.windows.list)
    and api.nvim_buf_is_valid(self.buffers.list)
    and api.nvim_buf_is_valid(self.buffers.detail)
    and (not self.geometry.detail or valid(self.windows.detail))
end

function Session:close()
  if self.closing then return end
  self.closing = true
  if self.action_timer and not self.action_timer:is_closing() then
    self.action_timer:stop()
    self.action_timer:close()
  end
  self.action_timer = nil
  local focus = api.nvim_get_current_win()
  local owned = focus == self.windows.list or focus == self.windows.detail
  if self.group then pcall(api.nvim_del_augroup_by_id, self.group) end
  quiet(function()
    for _, win in pairs(self.windows) do
      if valid(win) then api.nvim_win_close(win, true) end
    end
    for _, buf in pairs(self.buffers) do
      if api.nvim_buf_is_valid(buf) then
        api.nvim_buf_delete(buf, { force = true })
      end
    end
    if owned and valid(self.previous) then
      api.nvim_set_current_win(self.previous)
    end
  end)
  if current == self then current = nil end
end

function Session:layout()
  self.changing = true
  local ok, err = pcall(quiet, function()
    self.geometry = geometry()
    for _, name in ipairs({ 'list', 'detail' }) do
      local config = self.geometry[name]
      if config then
        if valid(self.windows[name]) then
          api.nvim_win_set_config(self.windows[name], config)
        else
          self.windows[name] =
            api.nvim_open_win(self.buffers[name], false, config)
        end
        style.window(self.windows[name])
        vim.wo[self.windows[name]].wrap = false
      elseif valid(self.windows[name]) then
        api.nvim_win_close(self.windows[name], true)
        self.windows[name] = nil
      end
    end
    local buf = not self.geometry.detail
        and self.page == 'detail'
        and self.buffers.detail
      or self.buffers.list
    api.nvim_win_set_buf(self.windows.list, buf)
    vim.wo[self.windows.list].cursorline = buf == self.buffers.list
  end)
  self.changing = false
  if not ok then error(err, 0) end
end

function Session:render()
  self.rendering = true
  quiet(function()
    local entry = self.visible[self.index]
    local config = self.geometry.list
    self.offset = config.height >= 5 and 3 or (config.height >= 3 and 1 or 0)
    local lines, rows = {}, {}
    if self.offset > 0 then
      lines[1] = ('%s  %d / %d packages'):format(
        filter_name(self.filter),
        #self.visible,
        #self.snapshot.entries
      )
    end
    if self.offset == 3 then
      lines[2] = 'Search: '
        .. (self.query ~= '' and self.query or 'all packages')
      lines[3] = self.notice
        or (
          #self.snapshot.errors > 0 and 'Inventory unavailable; r retries'
          or 'l load  b rebuild  o directory'
        )
    end
    for _, item in ipairs(self.visible) do
      local status = model.failed(item)
          and (item.status == 'failed' and 'failed' or 'build error')
        or item.status
      local build = item.info and item.info.build
      if build and (build.status == 'queued' or build.status == 'running') then
        status = build.status == 'queued' and 'queued' or 'building'
      elseif item.update then
        local update = item.update.status
        if update == 'checking' or update == 'updating' then
          status = update
        elseif update == 'error' then
          status = 'update err'
        elseif update == 'available' and not model.failed(item) then
          status = 'update'
        end
      end
      local name = fit(item.name, math.max(1, config.width - 13))
      local line = config.width >= 16 and (' ' .. name .. ' ' .. status)
        or fit(item.name, config.width)
      lines[#lines + 1] = line
      rows[#rows + 1] = {
        row = #lines - 1,
        first = config.width >= 16 and 1 or 0,
        last = config.width >= 16 and #name + 1 or #line,
        status_first = config.width >= 16 and #name + 2 or nil,
        status = status,
      }
    end
    if #self.visible == 0 then lines[#lines + 1] = 'No matching packages' end
    write(self.buffers.list, lines)
    style.list(self.buffers.list, lines, rows, {
      offset = self.offset,
      query = self.query,
      notice = self.notice or #self.snapshot.errors > 0,
      level = self.notice_level,
    })
    local details = model.details(entry, self.snapshot.errors)
    write(self.buffers.detail, details)
    style.details(self.buffers.detail, details)
    if self.geometry.detail or self.page == 'list' then
      api.nvim_win_set_cursor(
        self.windows.list,
        { self.offset + math.max(1, self.index), 0 }
      )
    end
    local detail_win = self.geometry.detail and self.windows.detail
      or (self.page == 'detail' and self.windows.list)
    if detail_win and self.detail_id ~= self.selected then
      api.nvim_win_set_cursor(detail_win, { 1, 0 })
    end
    self.detail_id = self.selected
    local title = (' Packages / %s '):format(filter_name(self.filter))
    if not self.geometry.detail and self.page == 'detail' then
      title = ' Package details '
    end
    api.nvim_win_set_config(self.windows.list, { title = title })
    if self.geometry.detail then
      api.nvim_win_set_config(
        self.windows.detail,
        { title = ' Details: ' .. (entry and entry.name or 'none') .. ' ' }
      )
    end
  end)
  self.rendering = false
end

function Session:update()
  self.visible = model.filter(self.snapshot.entries, self.query, self.filter)
  local index = math.max(1, math.min(self.index or 1, #self.visible))
  for i, entry in ipairs(self.visible) do
    if entry.id == self.selected then
      index = i
      break
    end
  end
  self.index = #self.visible > 0 and index or 0
  self.selected = self.visible[self.index] and self.visible[self.index].id
    or nil
  self:render()
end

function Session:refresh()
  self.snapshot = model.snapshot()
  self:update()
end

function Session:set_query(query)
  self.query = query
  self:update()
end

function Session:set_filter(filter)
  filter_name(filter)
  self.filter = filter
  self:update()
end

function Session:select(index)
  if #self.visible == 0 then return end
  self.index = math.max(1, math.min(index, #self.visible))
  self.selected = self.visible[self.index].id
  self:render()
end

function Session:poll_builds()
  if current ~= self or not self:valid() then return end
  local builds = package.loaded['ar.core.pack.build']
  local pending, changed = false, false
  for src, watch in pairs(self.watched_builds or {}) do
    local job = builds and builds.jobs[src]
    if job then
      if job.status ~= watch.status then
        changed = true
        watch.status = job.status
      end
      if job.status == 'queued' or job.status == 'running' then
        pending = true
      else
        self.watched_builds[src] = nil
        if watch.context == 'update' then
          self.notice = 'Updated '
            .. watch.name
            .. (job.error and '; build failed' or '')
        else
          self.notice = job.error and ('Build failed for ' .. watch.name)
            or ('Rebuilt ' .. watch.name)
        end
        if not job.error and watch.needs_restart then
          self.notice = self.notice
            .. (
              watch.context == 'update'
                and '; restart Neovim to use the new code'
              or '; restart Neovim to retry failed setup'
            )
        end
        self.notice_level = job.error and vim.log.levels.ERROR
          or vim.log.levels.INFO
        changed = true
      end
    else
      self.watched_builds[src] = nil
    end
  end
  if changed then self:refresh() end
  if pending and not self.action_timer then
    self.action_timer = vim.defer_fn(function()
      self.action_timer = nil
      if current == self and self:valid() then self:poll_builds() end
    end, 100)
  end
end

function Session:act(action)
  if current ~= self or not self:valid() then return end
  if self.busy then
    vim.notify('Another package action is running', vim.log.levels.WARN)
    return
  end
  if
    api.nvim_get_current_win() == self.windows.list
    and api.nvim_win_get_buf(self.windows.list) == self.buffers.list
    and #self.visible > 0
  then
    local row = api.nvim_win_get_cursor(self.windows.list)[1]
    self.index = math.max(1, math.min(row - self.offset, #self.visible))
    self.selected = self.visible[self.index].id
  end
  local selected, target = self.selected, nil
  self.busy = true
  local ok, result, reason = pcall(function()
    local snapshot = model.snapshot()
    if action == 'check_all' then
      self.notice, self.notice_level =
        'Checking installed packages', vim.log.levels.INFO
      self:render()
      vim.cmd('redraw')
      return actions.check_all(snapshot.entries)
    end
    for _, entry in ipairs(snapshot.entries) do
      if entry.id == selected then
        target = entry
        break
      end
    end
    self.snapshot = snapshot
    if not target then
      return nil, 'The selected package is no longer available'
    end
    self.notice = ({
      load = 'Loading ',
      rebuild = 'Building ',
      directory = 'Opening ',
      check = 'Checking ',
      update = 'Updating ',
    })[action] .. target.name
    self.notice_level = vim.log.levels.INFO
    self:render()
    vim.cmd('redraw')
    return actions.run(action, target)
  end)
  self.busy = false
  if not ok or not result then
    local message = tostring(ok and reason or result)
    self.notice = vim.split(message, '\n', { plain = true })[1]
    self.notice_level = ok and vim.log.levels.WARN or vim.log.levels.ERROR
    vim.notify(message, self.notice_level)
    if self:valid() then self:refresh() end
    return
  end
  if result.directory then
    self:close()
    local opened, err = pcall(api.nvim_cmd, {
      cmd = 'split',
      args = { result.directory },
      magic = { file = false, bar = false },
    }, {})
    if not opened then vim.notify(tostring(err), vim.log.levels.ERROR) end
    return
  end
  if not self:valid() then return end
  self.notice, self.notice_level =
    result.message,
    result.level
      or (result.changed and vim.log.levels.WARN or vim.log.levels.INFO)
  if result.job then
    self.watched_builds = self.watched_builds or {}
    self.watched_builds[target.src] = {
      name = target.name,
      needs_restart = result.needs_restart,
      context = result.context,
    }
    self:poll_builds()
  else
    self:refresh()
  end
end

function Session:switch()
  quiet(function()
    if self.geometry.detail then
      local target = api.nvim_get_current_win() == self.windows.list
          and self.windows.detail
        or self.windows.list
      api.nvim_set_current_win(target)
    else
      self.page = self.page == 'list' and 'detail' or 'list'
      self:layout()
      self:render()
    end
  end)
end

function Session:attach()
  local function still_open() return current == self and self:valid() end
  for _, buf in pairs(self.buffers) do
    local function map(key, action, desc)
      vim.keymap.set(
        'n',
        key,
        action,
        { buffer = buf, silent = true, nowait = true, desc = desc }
      )
    end
    map('q', function() self:close() end, 'Close packages')
    map('<Esc>', function() self:close() end, 'Close packages')
    map('r', function() self:refresh() end, 'Refresh local package inventory')
    map('l', function() self:act('load') end, 'Load selected package')
    map('b', function() self:act('rebuild') end, 'Rebuild selected package')
    map(
      'c',
      function() self:act('check') end,
      'Fetch and check selected package updates'
    )
    map(
      'C',
      function() self:act('check_all') end,
      'Fetch and check installed package updates'
    )
    map(
      'u',
      function() self:act('update') end,
      'Apply the checked package revision'
    )
    map(
      'o',
      function() self:act('directory') end,
      'Open selected package directory'
    )
    map('<Tab>', function() self:switch() end, 'Switch package pane')
    map('<CR>', function() self:switch() end, 'Switch package pane')
    map('<C-l>', function() self:set_query('') end, 'Clear package search')
    map('/', function()
      vim.ui.input(
        { prompt = 'Search packages: ', default = self.query },
        function(query)
          if still_open() and query ~= nil then self:set_query(query) end
        end
      )
    end, 'Search packages')
    map('f', function()
      vim.ui.select(model.filters, {
        prompt = 'Package filter',
        format_item = function(item) return item.label end,
      }, function(filter)
        if still_open() and filter then self:set_filter(filter.id) end
      end)
    end, 'Filter packages')
    if buf == self.buffers.list then
      map('j', function() self:select(self.index + 1) end, 'Next package')
      map('<Down>', function() self:select(self.index + 1) end, 'Next package')
      map('k', function() self:select(self.index - 1) end, 'Previous package')
      map(
        '<Up>',
        function() self:select(self.index - 1) end,
        'Previous package'
      )
      map('gg', function() self:select(1) end, 'First package')
      map('G', function() self:select(#self.visible) end, 'Last package')
    end
  end
  self.group =
    api.nvim_create_augroup('ArPackUI' .. self.buffers.list, { clear = true })
  api.nvim_create_autocmd('User', {
    group = self.group,
    pattern = 'ArPackUpdatesChecked',
    callback = function()
      if still_open() and not self.busy then self:refresh() end
    end,
  })
  api.nvim_create_autocmd('CursorMoved', {
    group = self.group,
    buffer = self.buffers.list,
    callback = function()
      if
        not still_open()
        or self.rendering
        or (not self.geometry.detail and self.page ~= 'list')
      then
        return
      end
      local line = api.nvim_win_get_cursor(self.windows.list)[1]
      local index = math.max(1, math.min(line - self.offset, #self.visible))
      if #self.visible > 0 and index ~= self.index then self:select(index) end
    end,
  })
  api.nvim_create_autocmd('VimResized', {
    group = self.group,
    callback = function()
      if still_open() then
        self:layout()
        self:render()
      end
    end,
  })
  local function orphaned()
    if self.changing or self.closing then return end
    vim.schedule(function()
      if current == self then self:close() end
    end)
  end
  api.nvim_create_autocmd('WinClosed', {
    group = self.group,
    callback = function(event)
      local win = tonumber(event.match)
      if win == self.windows.list or win == self.windows.detail then
        orphaned()
      end
    end,
  })
  api.nvim_create_autocmd({ 'BufWipeout', 'BufWinLeave' }, {
    group = self.group,
    callback = function(event)
      if event.buf == self.buffers.list or event.buf == self.buffers.detail then
        orphaned()
      end
    end,
  })
end

function M.open(opts)
  style.setup()
  opts = opts or {}
  assert(
    opts.query == nil or type(opts.query) == 'string',
    'Package search must be a string'
  )
  if opts.filter then filter_name(opts.filter) end
  if current and current:valid() then
    current.query, current.filter =
      opts.query or current.query, opts.filter or current.filter
    current:refresh()
    quiet(function() api.nvim_set_current_win(current.windows.list) end)
    return current
  end
  if current then current:close() end
  local session = setmetatable({
    query = opts.query or '',
    filter = opts.filter or 'loaded',
    index = 1,
    page = 'list',
    windows = {},
    buffers = {},
    previous = api.nvim_get_current_win(),
  }, Session)
  current = session
  local ok, err = xpcall(function()
    quiet(function()
      for _, name in ipairs({ 'list', 'detail' }) do
        local buf = api.nvim_create_buf(false, true)
        session.buffers[name] = buf
        api.nvim_buf_set_name(buf, 'ar-pack://' .. name .. '/' .. buf)
        vim.bo[buf].buftype, vim.bo[buf].bufhidden = 'nofile', 'hide'
        vim.bo[buf].swapfile, vim.bo[buf].filetype = false, 'arpack'
      end
      session:layout()
      session:refresh()
      session:attach()
      api.nvim_set_current_win(session.windows.list)
    end)
  end, debug.traceback)
  if not ok then
    session:close()
    error(err, 0)
  end
  return session
end

return M
