local api = vim.api
local M = {}
local namespace = api.nvim_create_namespace('ar.pack.highlights')
local applied = {}

local function get(name, link)
  return api.nvim_get_hl(
    0,
    { name = name, link = link == true, create = false }
  ) or {}
end

local function accent(names, attrs)
  local normal = get('Normal').fg
  local color
  for _, name in ipairs(names) do
    local candidate = get(name)
    if candidate.fg and (candidate.fg ~= normal or not color) then
      color = candidate
    end
    if candidate.fg and candidate.fg ~= normal then break end
  end
  return vim.tbl_extend('force', {
    fg = color and color.fg or normal,
    ctermfg = color and color.ctermfg or nil,
  }, attrs or {})
end

local function define()
  local groups = {
    ArPackNormal = { link = 'NormalFloat' },
    ArPackBorder = { link = 'FloatBorder' },
    ArPackSelection = { link = 'CursorLine' },
    ArPackMuted = { link = 'Comment' },
    ArPackLabel = accent({ 'Comment' }),
    ArPackName = accent({ 'Normal' }),
    ArPackTitle = accent({ 'DiagnosticInfo', 'Function' }, { bold = true }),
    ArPackSection = accent({ 'Function', 'DiagnosticInfo' }, { bold = true }),
    ArPackKey = accent({ 'Special', 'DiagnosticInfo' }, { bold = true }),
    ArPackEvent = accent({ '@keyword', 'Statement', 'DiagnosticError' }),
    ArPackCommand = accent({ 'Function', 'DiagnosticInfo' }),
    ArPackType = accent({ 'Type', 'DiagnosticWarn' }),
    ArPackValue = accent({ 'String', 'DiagnosticOk' }),
    ArPackNumber = accent({ 'Number', 'DiagnosticInfo' }),
    ArPackSource = accent({ 'Directory', 'Function' }),
    ArPackCommit = accent({ 'DiagnosticInfo', 'Identifier' }),
    ArPackTarget = accent({ 'DiagnosticInfo', 'Identifier' }, { bold = true }),
    ArPackCommitType = accent({ 'Comment' }, { italic = true }),
    ArPackSuccess = accent({ 'DiagnosticOk', 'String' }),
    ArPackProgress = accent({ 'DiagnosticWarn' }),
    ArPackUpdate = accent({ 'DiagnosticInfo' }, { bold = true }),
    ArPackWarning = accent({ 'DiagnosticWarn' }),
    ArPackBreaking = accent({ 'DiagnosticWarn' }, { bold = true }),
    ArPackError = accent({ 'DiagnosticError' }, { bold = true }),
    ArPackMatch = accent(
      { 'DiagnosticInfo' },
      { bold = true, underline = true }
    ),
  }
  for name, attrs in pairs(groups) do
    local existing = get(name, true)
    -- Refresh our derived colors after theme changes, while preserving overrides.
    if not next(existing) or vim.deep_equal(existing, applied[name]) then
      api.nvim_set_hl(0, name, attrs)
      applied[name] = get(name, true)
    end
  end
end

function M.setup()
  define()
  local group = api.nvim_create_augroup('ArPackHighlights', { clear = true })
  api.nvim_create_autocmd('ColorScheme', { group = group, callback = define })
end

function M.window(win)
  vim.wo[win].winhighlight = 'Normal:ArPackNormal,NormalNC:ArPackNormal,NormalFloat:ArPackNormal,'
    .. 'FloatBorder:ArPackBorder,FloatTitle:ArPackTitle,FloatFooter:ArPackMuted,CursorLine:ArPackSelection'
end

local keys = {
  ['c/C'] = true,
  c = true,
  C = true,
  u = true,
  l = true,
  b = true,
  o = true,
  r = true,
  q = true,
  f = true,
  ['/'] = true,
  Tab = true,
  ['Ctrl-L'] = true,
}

function M.footer(text)
  if text == '' then return '' end
  local chunks, first = {}, 1
  for start, token, finish in text:gmatch('()(%S+)()') do
    if start > first then
      chunks[#chunks + 1] = { text:sub(first, start - 1), 'ArPackMuted' }
    end
    chunks[#chunks + 1] =
      { token, keys[token] and 'ArPackKey' or 'ArPackMuted' }
    first = finish
  end
  if first <= #text then
    chunks[#chunks + 1] = { text:sub(first), 'ArPackMuted' }
  end
  return chunks
end

function M.clear(buf) api.nvim_buf_clear_namespace(buf, namespace, 0, -1) end

function M.span(buf, row, first, last, group, priority)
  if last <= first then return end
  api.nvim_buf_set_extmark(buf, namespace, row, first, {
    end_col = last,
    hl_group = group,
    priority = priority or 120,
  })
end

function M.status(value)
  if
    value == 'failed'
    or value == 'error'
    or value == 'update err'
    or value == 'build error'
    or value == 'missing'
  then
    return 'ArPackError'
  elseif
    value == 'success'
    or value == 'loaded'
    or value == 'active'
    or value == 'current'
    or value == 'updated'
  then
    return 'ArPackSuccess'
  elseif value == 'available' or value == 'update' then
    return 'ArPackUpdate'
  elseif
    value == 'queued'
    or value == 'running'
    or value == 'building'
    or value == 'checking'
    or value == 'updating'
    or value == 'loading'
  then
    return 'ArPackProgress'
  end
  return 'ArPackMuted'
end

local function numbers(buf, row, line)
  for first, value in line:gmatch('()(%d+%.?%d*)') do
    M.span(buf, row, first - 1, first - 1 + #value, 'ArPackNumber')
  end
end

function M.list(buf, lines, rows, opts)
  M.clear(buf)
  if opts.offset > 0 then
    M.span(buf, 0, 0, #lines[1], 'ArPackTitle', 100)
    numbers(buf, 0, lines[1])
  end
  if opts.offset == 3 then
    M.span(buf, 1, 0, 7, 'ArPackLabel')
    M.span(
      buf,
      1,
      8,
      #lines[2],
      opts.query ~= '' and 'ArPackSource' or 'ArPackMuted'
    )
    local group = opts.level == vim.log.levels.ERROR and 'ArPackError'
      or (opts.level == vim.log.levels.INFO and 'ArPackSuccess')
      or (opts.notice and 'ArPackWarning' or 'ArPackMuted')
    M.span(buf, 2, 0, #lines[3], group, 100)
  end
  for _, item in ipairs(rows) do
    local line = lines[item.row + 1]
    M.span(buf, item.row, item.first, item.last, 'ArPackName', 100)
    if item.status_first then
      M.span(buf, item.row, item.status_first, #line, M.status(item.status))
    end
    local name = line:sub(item.first + 1, item.last):lower()
    for term in opts.query:lower():gmatch('%S+') do
      local start = 1
      while true do
        local first, last = name:find(term, start, true)
        if not first then break end
        M.span(
          buf,
          item.row,
          item.first + first - 1,
          item.first + last,
          'ArPackMatch'
        )
        start = last + 1
      end
    end
  end
end

function M.details(buf, lines)
  M.clear(buf)
  local section
  for row, line in ipairs(lines) do
    row = row - 1
    local label, value = line:match('^([%a][%w ,%-]*):%s*(.*)$')
    if line:match('^%S') then section = label end
    if label then
      M.span(
        buf,
        row,
        0,
        #label + 1,
        value == '' and 'ArPackSection' or 'ArPackLabel'
      )
      local first = #line - #value
      local group
      if label == 'Plugin' then
        group = 'ArPackName'
      elseif label == 'State' or label == 'Updates' or label == 'Build' then
        group = M.status(value)
      elseif label:find('revision', 1, true) or label == 'Revision' then
        group = label == 'Target revision' and 'ArPackTarget' or 'ArPackCommit'
      elseif label == 'Source' or label == 'Package directory' then
        group = 'ArPackSource'
      elseif label:find('time', 1, true) then
        numbers(buf, row, line)
      elseif label == 'Exit code' then
        group = value == '0' and 'ArPackSuccess' or 'ArPackError'
      elseif value == 'true' or value == 'yes' then
        group = 'ArPackValue'
      elseif
        value == 'false'
        or value == 'no'
        or value == 'unknown'
        or label == 'Last checked'
      then
        group = 'ArPackMuted'
      end
      if group then M.span(buf, row, first, #line, group) end
      if label == 'Load cause' then
        local kind, trigger = value:match('^(%S+)%s+(.+)$')
        if kind and trigger then
          local group = kind == 'event' and 'ArPackEvent'
            or (kind == 'key' and 'ArPackKey' or 'ArPackCommand')
          M.span(buf, row, first + #kind + 1, #line, group)
        end
      end
    elseif line:match('^%s+%S') then
      local first = #line:match('^%s*')
      local group = ({
        Events = 'ArPackEvent',
        Commands = 'ArPackCommand',
        Filetypes = 'ArPackType',
        Dependencies = 'ArPackSource',
        Directory = 'ArPackSource',
        Revision = 'ArPackCommit',
        Command = 'ArPackCommand',
        stderr = 'ArPackError',
        ['Load error'] = 'ArPackError',
        ['Build error'] = 'ArPackError',
        ['Inventory error'] = 'ArPackError',
      })[section]
      if group then M.span(buf, row, first, #line, group) end
      if section == 'Actions' then
        local key = line:match('^%s+(%S+)')
        local disabled = line:find(': ', first + 1, true)
        M.span(
          buf,
          row,
          first,
          #line,
          disabled and 'ArPackMuted' or 'ArPackCommand',
          100
        )
        if key then
          M.span(
            buf,
            row,
            first,
            first + #key,
            disabled and 'ArPackMuted' or 'ArPackKey'
          )
        end
      elseif section == 'Keys' then
        local mode = line:match('^%s+(%S+)%s+')
        M.span(buf, row, first, #line, 'ArPackKey')
        if mode then
          M.span(buf, row, first, first + #mode, 'ArPackMuted', 130)
        end
      elseif
        section
        and (
          section:match('^Commits toward target')
          or section:match('^Applied commits')
        )
      then
        local hash, subject = line:match('^%s+(%x+)%s+(.+)$')
        if hash then
          M.span(buf, row, first, first + #hash, 'ArPackCommit')
          local kind = subject:match('^([%w_-]+%b()!?):')
            or subject:match('^([%w_-]+!?):')
          if kind then
            M.span(
              buf,
              row,
              first + #hash + 1,
              first + #hash + 1 + #kind,
              'ArPackCommitType'
            )
          end
          if
            (kind and kind:sub(-1) == '!')
            or subject:find('BREAKING CHANGE', 1, true)
            or subject:find('BREAKING-CHANGE', 1, true)
          then
            api.nvim_buf_set_extmark(buf, namespace, row, 0, {
              virt_text = { { '  ! Breaking change', 'ArPackBreaking' } },
              priority = 130,
            })
          end
        end
      end
    elseif line:match('^Restart Neovim') or line:match('^No new commits') then
      M.span(buf, row, 0, #line, 'ArPackWarning')
    elseif
      line:match('^Load time includes')
      or line:match('^This package has no')
      or line:match('^c checks')
    then
      M.span(buf, row, 0, #line, 'ArPackMuted')
    end
  end
end

return M
