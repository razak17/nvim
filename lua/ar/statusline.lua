local fn, api, env, fmt = vim.fn, vim.api, vim.env, string.format
local falsy, icons, codicons = ar.falsy, ar.ui.icons, ar.ui.codicons
local separator = icons.separators.dotted_thin_block

local conditions = require('heirline.conditions')
local Job = require('plenary.job')

local M = {}

function M.block() return icons.separators.bar end

function M.list_branches()
  local branches = vim.fn.systemlist([[git branch 2>/dev/null]])
  local new_branch_prompt = 'Create new branch'
  ---@diagnostic disable-next-line: param-type-mismatch
  table.insert(branches, 1, new_branch_prompt)

  vim.ui.select(branches, {
    prompt = 'Git branches',
  }, function(choice)
    if choice == nil then return end

    if choice == new_branch_prompt then
      vim.ui.input({ prompt = 'New branch name:' }, function(branch)
        if branch ~= nil then
          vim.fn.systemlist('git checkout -b ' .. branch)
        end
      end)
    else
      vim.fn.systemlist('git checkout ' .. choice)
    end
  end)
end

local function git_remote_sync()
  if not _G.GitStatus then
    _G.GitStatus = { ahead = 0, behind = 0, status = nil }
  end

  -- Fetch the remote repository
  local git_fetch = Job:new({
    command = 'git',
    args = { 'fetch' },
    on_start = function() _G.GitStatus.status = 'pending' end,
    on_exit = function() _G.GitStatus.status = 'done' end,
  })

  -- Compare local repository to upstream
  local git_upstream = Job:new({
    command = 'git',
    args = { 'rev-list', '--left-right', '--count', 'HEAD...@{upstream}' },
    on_start = function()
      GitStatus.status = 'pending'
      vim.schedule(
        function()
          vim.api.nvim_exec_autocmds('User', { pattern = 'GitStatusChanged' })
        end
      )
    end,
    on_exit = function(job, _)
      local res = job:result()[1]
      if type(res) ~= 'string' then
        GitStatus = { ahead = 0, behind = 0, status = 'error' }
        return
      end
      local _, ahead, behind = pcall(string.match, res, '(%d+)%s*(%d+)')

      GitStatus =
        { ahead = tonumber(ahead), behind = tonumber(behind), status = 'done' }
      vim.schedule(
        function()
          vim.api.nvim_exec_autocmds('User', { pattern = 'GitStatusChanged' })
        end
      )
    end,
  })

  git_fetch:start()
  git_upstream:start()
end
ar.command('GitRemoteSync', git_remote_sync)

local function git_push_pull(action, _)
  local branch = vim.fn.systemlist('git rev-parse --abbrev-ref HEAD')[1]

  vim.ui.select({ 'Yes', 'No' }, {
    prompt = action:gsub('^%l', string.upper)
      .. ' commits to/from '
      .. "'origin/"
      .. branch
      .. "'?",
  }, function(choice)
    if choice == 'Yes' then
      Job:new({
        command = 'git',
        args = { action },
        on_exit = function() ar.GitRemoteSync() end,
      }):start()
    end
  end)
end

function M.git_pull() git_push_pull('pull', 'from') end

function M.git_push() git_push_pull('push', 'to') end

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
  init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    })
  end,
}

M.file_name = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ':t')
    if filename == '' then return '[No Name]' end
    return ' ' .. filename
  end,
  on_click = {
    callback = function() vim.cmd('Telescope find_files') end,
    name = 'find_files',
  },
}

M.file_size = {
  provider = function()
    local bufnr = api.nvim_get_current_buf()
    local buf = api.nvim_buf_get_name(bufnr)

    if string.len(buf) == 0 then return '' end

    local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
    local fsize = vim.fn.getfsize(buf)
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
  local cur = vim.fn.line('.')
  local total = vim.fn.line('$')
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

local function stl_lsp_clients(bufnum)
  local clients = vim.lsp.get_clients({ bufnr = bufnum })
  clients = vim.tbl_filter(
    function(client) return client.name ~= 'copilot' end,
    clients
  )
  -- local lsp_clients = vim.tbl_filter(function(client) return client.name ~= 'null-ls' end, clients)
  if falsy(clients) then return { { name = 'No Active LSP' } } end

  table.sort(clients, function(a, b)
    if a.name == 'null-ls' then return false end
    if b.name == 'null-ls' then return true end
    return a.name < b.name
  end)

  return vim.tbl_map(function(client)
    if client.name:match('null') then
      local sources =
        require('null-ls.sources').get_available(vim.bo[bufnum].filetype)
      local source_names = vim.tbl_map(function(s) return s.name end, sources)
      return {
        name = codicons.misc.null_ls .. table.concat(source_names, ', '),
        priority = 7,
      }
    end
    return { name = client.name, priority = 4 }
  end, clients)
end

function M.lsp_client_names()
  local curwin = api.nvim_get_current_win()
  local curbuf = api.nvim_win_get_buf(curwin)
  local client_names = vim
    .iter(ipairs(stl_lsp_clients(curbuf)))
    :map(function(_, c) return c.name end)
    :totable()

  -- No LSP client but null-ls sources
  if
    client_names[1]
    -- check string is not alphabetic
    and string.match(string.sub(client_names[1], 2, 2), '[^%a]')
  then
    return 'No Active LSP '
      .. table.concat(client_names, fmt(' %s ', separator))
      .. separator
  end
  return codicons.misc.disconnect
    .. ' '
    .. table.concat(client_names, fmt('%s ', separator))
    .. separator
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
  return table.concat(linters, ', ') .. separator
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
  return table.concat(formatters, ', ') .. separator
end

function M.copilot_indicator()
  local client = vim.lsp.get_clients({ name = 'copilot' })[1]
  if client == nil then return 'inactive' end
  if vim.tbl_isempty(client.requests) then return 'idle' end
  return 'working'
end

function M.word_count() return ' ' .. tostring(fn.wordcount().words) .. ' words' end

return M
