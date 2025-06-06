local fn, api, env, fmt = vim.fn, vim.api, vim.env, string.format
local falsy, icons, codicons = ar.falsy, ar.ui.icons, ar.ui.codicons
local separator = icons.separators.dotted_thin_block
local spinners = ar.ui.spinners.common

local conditions = require('heirline.conditions')

local M = {}

M.is_dots_repo = false

M.git_status = { ahead = 0, behind = 0, status = nil }

function M.block() return icons.separators.bar end

function M.list_branches()
  local branches = fn.systemlist([[git branch 2>/dev/null]])
  local new_branch_prompt = 'Create new branch'
  ---@diagnostic disable-next-line: param-type-mismatch
  table.insert(branches, 1, new_branch_prompt)

  vim.ui.select(branches, {
    prompt = 'Git branches',
  }, function(choice)
    if choice == nil then return end

    if choice == new_branch_prompt then
      vim.ui.input({ prompt = 'New branch name:' }, function(branch)
        if branch ~= nil then fn.systemlist('git checkout -b ' .. branch) end
      end)
    else
      fn.systemlist('git checkout ' .. choice)
    end
  end)
end

function M.git_remote_sync()
  local cmd = 'git'
  local fetch_args = { 'fetch' }
  local upstream_args =
    { 'rev-list', '--left-right', '--count', 'HEAD...@{upstream}' }

  if ar.falsy(fn.executable(cmd)) then
    vim.notify('Git is not installed or not in PATH', vim.log.levels.ERROR)
    return
  end

  -- Fetch the remote repository
  ar.run_command(
    cmd,
    fetch_args,
    function() M.git_status.status = 'done' end,
    function() M.git_status.status = 'pending' end
  )

  local function on_status_change()
    vim.schedule(
      function()
        api.nvim_exec_autocmds('User', { pattern = 'git_statusChanged' })
      end
    )
  end

  -- Compare local repository to upstream
  local function on_exit(job)
    local res = job:result()[1]
    if type(res) ~= 'string' then
      M.git_status = { ahead = 0, behind = 0, status = 'error' }
      return
    end
    local _, ahead, behind = pcall(string.match, res, '(%d+)%s*(%d+)')
    M.git_status =
      { ahead = tonumber(ahead), behind = tonumber(behind), status = 'done' }
    on_status_change()
  end
  local function on_start()
    M.git_status.status = 'pending'
    on_status_change()
  end
  ar.run_command(cmd, upstream_args, on_exit, on_start)
end
ar.command('GitRemoteSync', M.git_remote_sync)

local buffer_repo_cache = {}
local repo_branch_cache = {}

local function git_branch_from_path(git_path)
  local head_path =
    fmt('%s/HEAD', M.is_dots_repo and git_path or git_path .. '/.git')
  local f_head = io.open(head_path)
  if f_head == nil then return '' end
  local head = f_head:read()
  local branch = head:match('ref: refs/heads/(.+)$')
  if not branch then branch = head:sub(1, 6) end
  f_head:close()
  return branch
end

local function git_branch_changed(git_path)
  local prev_watcher = repo_branch_cache[git_path]
    and repo_branch_cache[git_path][2]
  if prev_watcher then prev_watcher:close() end

  local branch = git_branch_from_path(git_path)
  local watcher = vim.uv.new_fs_event()
  repo_branch_cache[git_path] = { branch, watcher }

  ---@diagnostic disable-next-line: need-check-nil
  watcher:start(
    git_path .. fmt('%s', M.is_dots_repo and '/HEAD' or '/.git/HEAD'),
    {},
    vim.schedule_wrap(function(_, _, evts)
      if evts.change then git_branch_changed(git_path) end
    end)
  )

  return branch
end

-- Ref: https://github.com/emmanueltouzery/nvim_config/blob/907a491617f2506963dc5158def46e597a5e1d45/lua/plugins/lualine.lua?plain=1#L170
-- made my own git_branch lualine component as the official one didn't properly
-- update for non-focused buffers on branch change for me.
function M.git_branch()
  local bufnr = api.nvim_get_current_buf()
  local cached_repo = buffer_repo_cache[bufnr]
  if cached_repo then return repo_branch_cache[cached_repo][1] end
  local path = fn.expand('%:p')
  local dir = vim.fs.dirname(path)
  local git_path = vim.fs.root(dir, '.git')
  if git_path == nil then
    local dots_repo = fmt('%s/dotfiles', vim.g.dotfiles)
    if fn.isdirectory(dots_repo) then
      git_path = dots_repo
      M.is_dots_repo = true
    else
      return ''
    end
  end
  buffer_repo_cache[bufnr] = git_path
  if repo_branch_cache[git_path] then return repo_branch_cache[git_path][1] end
  return git_branch_changed(git_path)
end

local function git_push_pull(action, _)
  local branch = fn.systemlist('git rev-parse --abbrev-ref HEAD')[1]

  vim.ui.select({ 'Yes', 'No' }, {
    prompt = action:gsub('^%l', string.upper)
      .. ' commits to/from '
      .. "'origin/"
      .. branch
      .. "'?",
  }, function(choice)
    if choice == 'Yes' then
      ar.run_command(
        'git',
        { action, 'origin', branch },
        function() ar.GitRemoteSync() end
      )
    end
  end)
end

function M.git_pull() git_push_pull('pull', 'from') end

function M.git_push() git_push_pull('push', 'to') end

function M.pretty_branch()
  local branch = M.git_branch()
  if branch:len() < 15 then return branch end
  local prefix, rest = branch:match('^([^/]+)/(.+)$')
  if prefix then return prefix .. '/' .. ar.abbreviate(rest) end
  return ar.abbreviate(branch)
end

M.mode_colors = {
  n = 'blue',
  i = 'yellowgreen',
  v = 'magenta',
  [''] = 'pale_blue',
  V = 'pink',
  c = 'yellow',
  no = 'pale_red',
  s = 'orange',
  S = 'orange',
  [''] = 'orange',
  ic = 'yellowgreen',
  R = 'violet',
  Rv = 'violet',
  cv = 'pale_red',
  ce = 'pale_red',
  r = 'cyan',
  rm = 'cyan',
  ['r?'] = 'cyan',
  ['!'] = 'pale_red',
  t = 'red',
}

---Return the filename of the current buffer
M.file_block = {
  init = function(self) self.filename = api.nvim_buf_get_name(0) end,
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    })
  end,
}

M.file_name = {
  provider = function(self)
    local filename = fn.fnamemodify(self.filename, ':t')
    if filename == '' then return '[No Name]' end
    return ' ' .. filename
  end,
  on_click = {
    callback = function()
      vim.defer_fn(function() ar.pick('files')() end, 100)
    end,
    name = 'find_files',
  },
}

M.pretty_path = {
  provider = function(self)
    local filename = fn.fnamemodify(self.filename, ':p:h')
    if filename == '' then return '[No Name]' end
    local pretty_path = require('ar.pretty_path')
    return ' ' .. pretty_path.pretty_path()
  end,
  on_click = {
    callback = function()
      vim.defer_fn(function() ar.pick('files')() end, 100)
    end,
    name = 'find_files',
  },
}

M.file_size = {
  provider = function()
    local bufnr = api.nvim_get_current_buf()
    local buf = api.nvim_buf_get_name(bufnr)

    if vim.bo[bufnr].readonly then return '' end

    if string.len(buf) == 0 then return '' end

    local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
    local fsize = fn.getfsize(buf)
    fsize = (fsize < 0 and 0) or fsize
    if fsize < 1024 then return ' ' .. fsize .. suffix[1] end
    local i = math.floor((math.log(fsize) / math.log(1024)))

    return string.format(' %.1f%s', fsize / math.pow(1024, i), suffix[i + 1])
  end,
}

M.file_flags = {
  {
    condition = function() return vim.bo.modified end,
    provider = ' [+]',
  },
  {
    condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
    provider = codicons.shaded_lock,
  },
}

M.file_icon = {
  init = function(self)
    if ar.is_available('nvim-web-devicons') then
      self.icon, self.icon_color =
        require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'))
    end
    if falsy(self.icon) or falsy(self.icon_color) then
      self.icon, self.icon_color =
        codicons.documents.default_file, 'DevIconDefault'
    end
  end,
  provider = function(self) return self.icon and (' ' .. self.icon) end,
  on_click = {
    callback = function() ar.change_filetype() end,
    name = 'change_ft',
  },
  hl = function(self) return { fg = ar.highlight.get(self.icon_color, 'fg') } end,
}

M.file_type = {
  provider = function() return ' ' .. string.lower(vim.bo.filetype) end,
  on_click = {
    callback = function() ar.change_filetype() end,
    name = 'change_ft',
  },
}

function M.progress()
  local cur = fn.line('.')
  local total = fn.line('$')
  if cur == 1 then
    return 'Top'
  elseif cur == total then
    return 'Bot'
  else
    return string.format('%2d%%%%', math.floor(cur / total * 100))
  end
end

function M.ts_active()
  local b = api.nvim_get_current_buf()
  if next(vim.treesitter.highlighter.active[b]) then
    return codicons.misc.tree
  end
  return ''
end

local function is_pipfile_root()
  return not vim.tbl_isempty(vim.fs.find({ 'Pipfile', 'Pipfile.lock' }, {
    path = fn.expand('%:p'),
    upward = true,
  }))
end

local function env_cleanup(venv)
  local final_venv = venv
  if string.find(venv, '/') then
    for w in venv:gmatch('([^/]+)') do
      final_venv = w
    end
  end
  if is_pipfile_root() then return final_venv:match('^([^%-]*)') end
  return final_venv
end

function M.python_env()
  local venv
  if env.CONDA_DEFAULT_ENV then
    venv = env.CONDA_DEFAULT_ENV
  elseif env.VIRTUAL_ENV then
    venv = env.VIRTUAL_ENV
  end
  if venv == nil then return '' end
  return string.format('[%s]', env_cleanup(venv))
end

function M.lazy_updates()
  local lazy_ok, lazy = pcall(require, 'lazy.status')
  local pending_updates = lazy_ok and lazy.updates() or nil
  local has_pending_updates = lazy_ok and lazy.has_updates() or false
  if has_pending_updates then return ' ' .. pending_updates end
  return ''
end

function M.package_info()
  local ok, pkg_info = pcall(require, 'package-info')
  if not ok then return '' end
  return pkg_info.get_status()
end

function M.format_servers(servers)
  if #servers == 0 then return '' end
  if #servers > 1 then
    return fmt('%s +%d %s', servers[1], #servers - 1, separator)
  end
  local names = table.concat(servers, fmt(' %s ', separator))
  -- return table.concat(servers, ', ') .. ' ' .. separator
  return fmt('%s ', names) .. separator
end

-- Get linters (from null-ls)
function M.get_null_ls_linters(filetype)
  local s = require('null-ls.sources')
  local linters = vim
    .iter(s.get_available(filetype))
    :filter(function(l) return l.methods.NULL_LS_FORMATTING end)
    :map(function(l) return l.name end)
    :totable()
  table.sort(linters)
  return M.format_servers(linters)
end

-- Get formatters (from null-ls)
function M.get_null_ls_formatters(filetype)
  local s = require('null-ls.sources')
  local formatters = vim
    .iter(s.get_available(filetype))
    :filter(function(f) return f.methods.NULL_LS_DIAGNOSTICS end)
    :map(function(l) return l.name end)
    :totable()
  table.sort(formatters)
  return M.format_servers(formatters)
end

-- Add linters (from nvim-lint)
function M.get_linters()
  local ft = vim.bo.filetype
  local lint_ok, lint = pcall(require, 'lint')
  if not lint_ok or ar.falsy(lint.linters_by_ft[ft]) then return false end
  local linters = vim
    .iter(pairs(lint.linters_by_ft[ft]))
    :map(function(_, l) return l end)
    :totable()
  return M.format_servers(linters)
end

-- Add formatters (from conform.nvim)
function M.get_formatters(curbuf)
  local conform_ok, conform = pcall(require, 'conform')
  if not conform_ok or ar.falsy(conform.list_formatters(curbuf)) then
    return false
  end
  local formatters = vim
    .iter(ipairs(conform.list_formatters(curbuf)))
    :map(function(_, f) return f.name end)
    :totable()
  return M.format_servers(formatters)
end

function M.copilot_indicator()
  local client = vim.lsp.get_clients({ name = 'copilot', bufnr = 0 })[1]
  if client == nil then return 'inactive' end
  return vim.tbl_isempty(client.requests) and 'idle' or 'pending'
end

function M.copilot_status()
  local clients = vim.lsp.get_clients({ name = 'copilot', bufnr = 0 })
  if clients and #clients > 0 then
    local status = require('copilot.status').data.status
    return (status == 'InProgress' and 'pending')
      or (status == 'Warning' and 'error')
      or 'ok'
  end
  return ''
end

M.lsp_progress = ''
M.lsp_pending = ''
function M.autocmds()
  -- Ref: https://github.com/NvChad/ui/blob/v3.0/lua/nvchad/stl/utils.lua?plain=1#L161
  ar.augroup('stl_lsp_autocmds', {
    event = { 'LspProgress' },
    once = true,
    desc = 'LSP Progress',
    pattern = { 'begin', 'report', 'end' },
    command = function(args)
      local data = args.data.params.value
      local progress = ''

      if data.percentage then
        local idx = math.max(1, math.floor(data.percentage / 10))
        progress = spinners[idx] .. ' ' .. data.percentage .. '%% '
      end

      local kind, msg, title = data.kind, data.message, data.title
      local loaded_count = msg and string.match(msg, '^(%d+/%d+)') or ''
      local str = progress .. (title or '') .. ' ' .. (loaded_count or '')
      M.lsp_progress = kind == 'end' and '' or str
      vim.cmd.redrawstatus()
    end,
  }, {
    -- Ref: https://github.com/emmanueltouzery/nvim_config/blame/5c3d184b2ab62aa0cd3e8861ecc23c5f51931d33/lua/plugins/lualine.lua#L240
    event = { 'LspRequest' },
    once = true,
    desc = 'LSP Pendingg Request',
    command = function(args)
      local active_lsp_requests = {}
      local request = args.data.request
      local request_id = args.data.request_id
      if request.type == 'pending' then
        active_lsp_requests[request_id] = true
      elseif request.type == 'cancel' then
        active_lsp_requests[request_id] = nil
      elseif request.type == 'complete' then
        active_lsp_requests[request_id] = nil
      else
        vim.notify({ 'Unknown LSP request type: ' .. request.type })
      end
      local active_requests_count = vim.tbl_count(active_lsp_requests)
      if active_requests_count > 0 then
        M.lsp_pending = '󰘦 Pending LSP requests: ' .. active_requests_count
      else
        M.lsp_pending = ''
      end
      vim.cmd.redrawstatus()
    end,
  })
end

function M.word_count() return ' ' .. tostring(fn.wordcount().words) .. ' words' end

return M
