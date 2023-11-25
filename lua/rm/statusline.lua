local fn, api, env, fmt = vim.fn, vim.api, vim.env, string.format
local falsy, icons, codicons = rvim.falsy, rvim.ui.icons, rvim.ui.codicons
local separator = icons.separators.dotted_thin_block

local conditions = require('heirline.conditions')
local utils = require('heirline.utils')
local Job = require('plenary.job')

local colors = require('onedark.palette')
local bg = rvim.highlight.tint(colors.bg_dark, 0.1)
local fg = colors.base8

local function block() return icons.separators.bar end

local function listBranches()
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
rvim.command('GitRemoteSync', git_remote_sync)

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
        on_exit = function() rvim.GitRemoteSync() end,
      }):start()
    end
  end)
end

local function git_pull() git_push_pull('pull', 'from') end

local function git_push() git_push_pull('push', 'to') end

local mode_colors = {
  n = colors.blue,
  i = colors.yellowgreen,
  v = colors.magenta,
  [''] = colors.pale_blue,
  V = colors.pink,
  c = colors.yellow,
  no = colors.pale_red,
  s = colors.orange,
  S = colors.orange,
  [''] = colors.orange,
  ic = colors.yellowgreen,
  R = colors.violet,
  Rv = colors.violet,
  cv = colors.pale_red,
  ce = colors.pale_red,
  r = colors.cyan,
  rm = colors.cyan,
  ['r?'] = colors.cyan,
  ['!'] = colors.pale_red,
  t = colors.red,
}

---Return the filename of the current buffer
local file_block = {
  init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
  condition = function(self)
    return not conditions.buffer_matches({
      filetype = self.filetypes,
    })
  end,
}

local file_name = {
  provider = function(self)
    local filename = vim.fn.fnamemodify(self.filename, ':t')
    if filename == '' then return '[No Name]' end
    return filename .. ' '
  end,
  on_click = {
    callback = function() vim.cmd('Telescope find_files') end,
    name = 'find_files',
  },
  hl = { fg = fg, bg = bg },
}

local file_flags = {
  {
    condition = function() return vim.bo.modified end,
    provider = '[+] ',
    hl = { fg = fg },
  },
  {
    condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
    provider = '  ',
    hl = { fg = fg },
  },
}

local file_icon = {
  init = function(self)
    self.icon, self.icon_color =
      require('nvim-web-devicons').get_icon(vim.fn.expand('%:t'))
    if falsy(self.icon) or falsy(self.icon_color) then
      self.icon, self.icon_color =
        codicons.documents.default_file, 'DevIconDefault'
    end
  end,
  provider = function(self) return self.icon and (' ' .. self.icon) end,
  on_click = {
    callback = function() rvim.change_filetype() end,
    name = 'change_ft',
  },
  hl = function(self)
    return { fg = rvim.highlight.get(self.icon_color, 'fg'), bg = bg }
  end,
}

local file_type = {
  provider = function() return ' ' .. string.lower(vim.bo.filetype) end,
  on_click = {
    callback = function() rvim.change_filetype() end,
    name = 'change_ft',
  },
  hl = { fg = fg, bg = bg },
}

local function progress()
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

local function ts_active()
  local b = api.nvim_get_current_buf()
  if next(vim.treesitter.highlighter.active[b]) then return ' ' end
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

local function python_env()
  local venv
  if env.CONDA_DEFAULT_ENV then
    venv = env.CONDA_DEFAULT_ENV
  elseif env.VIRTUAL_ENV then
    venv = env.VIRTUAL_ENV
  end
  if venv == nil then return '' end
  return string.format('[%s]', env_cleanup(venv))
end

local function lazy_updates()
  local lazy_ok, lazy = pcall(require, 'lazy.status')
  local pending_updates = lazy_ok and lazy.updates() or nil
  local has_pending_updates = lazy_ok and lazy.has_updates() or false
  if has_pending_updates then return ' ' .. pending_updates end
  return ''
end

local function stl_package_info()
  local ok, package_info = pcall(require, 'package-info')
  if not ok then return '' end
  return package_info.get_status()
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
        name = '␀ ' .. table.concat(source_names, ', '),
        priority = 7,
      }
    end
    return { name = client.name, priority = 4 }
  end, clients)
end

local function lsp_client_names()
  local curwin = api.nvim_get_current_win()
  local curbuf = api.nvim_win_get_buf(curwin)
  local client_names = vim
    .iter(ipairs(stl_lsp_clients(curbuf)))
    :map(function(_, c) return c.name end)
    :totable()

  -- No LSP client but null-ls sources
  if client_names[1] and string.sub(client_names[1], 2, 2) == '�' then
    return 'No Active LSP '
      .. table.concat(client_names, fmt(' %s ', separator))
      .. ' '
      .. separator
  end
  return ' '
    .. table.concat(client_names, fmt(' %s ', separator))
    .. ' '
    .. separator
end

-- Add linters (from nvim-lint)
local function get_linters()
  local ft = vim.bo.filetype
  local lint_ok, lint = pcall(require, 'lint')
  if not lint_ok or rvim.falsy(lint.linters_by_ft[ft]) then return false end
  local linters = vim
    .iter(pairs(lint.linters_by_ft[ft]))
    :map(function(_, l) return l end)
    :totable()
  return table.concat(linters, ', ') .. ' ' .. separator
end

-- Add formatters (from conform.nvim)
local function get_formatters(curbuf)
  local conform_ok, conform = pcall(require, 'conform')
  if not conform_ok or rvim.falsy(conform.list_formatters(curbuf)) then
    return false
  end
  local formatters = vim
    .iter(ipairs(conform.list_formatters(curbuf)))
    :map(function(_, f) return f.name end)
    :totable()
  return table.concat(formatters, ', ') .. ' ' .. separator
end

local function stl_copilot_indicator()
  local client = vim.lsp.get_clients({ name = 'copilot' })[1]
  if client == nil then return fmt('inactive %s', separator) end
  if vim.tbl_isempty(client.requests) then return fmt('idle %s', separator) end
  return fmt('working %s', separator)
end

return {
  vim_mode = {
    init = function(self)
      self.mode = vim.fn.mode(1)
      self.mode_color = mode_colors[self.mode:sub(1, 1)]
    end,
    update = {
      'ModeChanged',
      pattern = '*:*',
      callback = vim.schedule_wrap(function() vim.cmd('redrawstatus') end),
    },
    {
      provider = function() return block() .. ' ' end,
      hl = function(self) return { fg = self.mode_color, bg = bg } end,
    },
  },
  git_branch = {
    condition = function() return conditions.is_git_repo() end,
    init = function(self) self.status_dict = vim.b.gitsigns_status_dict end,
    {
      {
        provider = function(self)
          if self.status_dict then
            return ' ' --
              .. (self.status_dict.head == '' and 'main' or self.status_dict.head)
              .. ' '
          end
        end,
        on_click = {
          callback = function() listBranches() end,
          name = 'git_change_branch',
        },
        hl = { fg = colors.yellowgreen, bg = bg },
      },
      {
        condition = function()
          return (
            GitStatus ~= nil
            and (GitStatus.ahead ~= 0 or _G.GitStatus.behind ~= 0)
          )
        end,
        update = { 'User', pattern = 'GitStatusChanged' },
        {
          condition = function() return GitStatus.status == 'pending' end,
          provider = ' ',
          hl = { fg = fg, bg = bg },
        },
        {
          provider = function() return GitStatus.behind .. '⇣ ' end,
          hl = function()
            return {
              fg = GitStatus.behind == 0 and fg or colors.pale_red,
              bg = bg,
            }
          end,
          on_click = {
            callback = function()
              if GitStatus.behind > 0 then git_pull() end
            end,
            name = 'git_pull',
          },
        },
        {
          provider = function() return GitStatus.ahead .. '⇡ ' end,
          hl = function()
            return {
              fg = GitStatus.ahead == 0 and fg or colors.yellowgreen,
              bg = bg,
            }
          end,
          on_click = {
            callback = function()
              if _G.GitStatus.ahead > 0 then git_push() end
            end,
            name = 'git_push',
          },
        },
      },
    },
  },
  file_name_block = utils.insert(
    file_block,
    utils.insert(file_name, file_flags)
  ),
  python_env = {
    condition = function() return vim.bo.filetype == 'python' end,
    provider = function() return python_env() .. ' ' end,
    hl = { fg = colors.yellowgreen, bg = bg },
    on_click = {
      callback = function() require('swenv.api').pick_venv() end,
      name = 'update_plugins',
    },
  },
  lsp_diagnostics = {
    condition = conditions.has_diagnostics,
    static = {
      error_icon = codicons.lsp.error .. ' ',
      warn_icon = codicons.lsp.warn .. ' ',
      hint_icon = codicons.lsp.hint .. ' ',
      info_icon = codicons.lsp.info .. ' ',
    },
    update = { 'LspAttach', 'DiagnosticChanged', 'BufEnter' },
    init = function(self)
      self.errors =
        #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings =
        #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints =
        #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info =
        #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end,
    {
      provider = function(self)
        return self.errors > 0 and (self.error_icon .. self.errors .. ' ')
      end,
      hl = { fg = colors.error_red, bg = bg },
    },
    {
      provider = function(self)
        return self.warnings > 0 and (self.warn_icon .. self.warnings .. ' ')
      end,
      hl = { fg = colors.dark_orange, bg = bg },
    },
    {
      provider = function(self)
        return self.info > 0 and (self.info_icon .. self.info .. ' ')
      end,
      hl = { fg = colors.blue, bg = bg },
    },
    {
      provider = function(self)
        return self.hints > 0 and (self.hint_icon .. self.hints .. ' ')
      end,
      hl = { fg = colors.darker_green, bg = bg },
    },
    on_click = {
      callback = function()
        require('telescope.builtin').diagnostics({
          layout_strategy = 'center',
          bufnr = 0,
        })
      end,
      name = 'lsp_diagnostics',
    },
  },
  package_info = {
    condition = function() return fn.expand('%') == 'package.json' end,
    provider = stl_package_info,
    hl = { fg = colors.comment, bg = bg },
    on_click = {
      callback = function() require('package_info').toggle() end,
      name = 'update_plugins',
    },
  },
  git_diff = {
    condition = conditions.is_git_repo,
    init = function(self)
      ---@diagnostic disable-next-line: undefined-field
      self.status_dict = vim.b.gitsigns_status_dict
      self.has_changes = self.status_dict.added ~= 0
        or self.status_dict.removed ~= 0
        or self.status_dict.changed ~= 0
    end,
    hl = { fg = colors.dark_orange },
    {
      provider = function(self)
        local count = self.status_dict.added or 0
        return count > 0 and (' ' .. codicons.git.added .. ' ' .. count)
      end,
      hl = { fg = colors.yellowgreen, bg = bg },
    },
    {
      provider = function(self)
        local count = self.status_dict.removed or 0
        return count > 0 and (' ' .. codicons.git.removed .. ' ' .. count)
      end,
      hl = { fg = colors.error_red, bg = bg },
    },
    {
      provider = function(self)
        local count = self.status_dict.changed or 0
        return count > 0 and (' ' .. codicons.git.mod .. ' ' .. count)
      end,
      hl = { fg = colors.dark_orange, bg = bg },
    },
    on_click = {
      callback = function()
        vim.defer_fn(function() vim.cmd('Neogit') end, 100)
      end,
      name = 'git diff',
    },
  },
  lazy_updates = {
    provider = lazy_updates,
    hl = { fg = colors.orange, bg = bg },
    on_click = {
      callback = function() require('lazy').update() end,
      name = 'update_plugins',
    },
  },
  search_results = {
    condition = function() return vim.v.hlsearch ~= 0 end,
    init = function(self)
      local ok, search = pcall(vim.fn.searchcount)
      if ok and search.total then self.search = search end
    end,
    {
      provider = function(self)
        local search = self.search
        return ' '
          .. string.format(
            ' %d/%d ',
            search.current,
            math.min(search.total, search.maxcount)
          )
      end,
      hl = function() return { bg = bg, fg = fg } end,
    },
  },
  word_count = {
    condition = function() return vim.bo.filetype == 'markdown' end,
    provider = function()
      return ' ' .. tostring(vim.fn.wordcount().words) .. ' words'
    end,
    hl = { fg = fg, bg = bg },
  },
  lsp_clients = {
    condition = function()
      return conditions.lsp_attached and rvim.lsp.null_ls.enable
    end,
    update = { 'LspAttach', 'LspDetach', 'WinEnter' },
    provider = function() return ' ' .. lsp_client_names() end,
    hl = { fg = fg, bg = bg, bold = true },
    on_click = {
      callback = function()
        vim.defer_fn(function() vim.cmd('LspInfo') end, 100)
      end,
      name = 'lsp_clients',
    },
  },
  attached_clients = {
    condition = function()
      return conditions.lsp_attached and not rvim.lsp.null_ls.enable
    end,
    init = function(self)
      local curwin = api.nvim_get_current_win()
      local curbuf = api.nvim_win_get_buf(curwin)
      self.active = true
      self.clients = vim.lsp.get_clients({ bufnr = curbuf })
      local copilot = vim.tbl_filter(
        function(client) return client.name == 'copilot' end,
        self.clients
      )
      self.copilot = copilot[1]
      if self.copilot ~= nil then
        self.copilot.requests = copilot[1].requests
      end
      self.clients = vim.tbl_filter(
        function(client) return client.name ~= 'copilot' end,
        self.clients
      )
      if falsy(self.clients) then self.active = false end
      self.linters = get_linters()
      self.formatters = get_formatters(curbuf)
    end,
    {
      update = { 'LspAttach', 'LspDetach', 'WinEnter' },
      init = function(self)
        if self.active then
          local lsp_servers = vim.tbl_map(
            function(client) return { name = client.name } end,
            self.clients
          )
          self.client_names = vim
            .iter(ipairs(lsp_servers))
            :map(function(_, c) return c.name end)
            :totable()
          self.servers = ' '
            .. table.concat(self.client_names, fmt(' %s ', separator))
            .. ' '
            .. separator
        end
      end,
      provider = function(self)
        if not self.active then
          return '  ' .. 'No Active LSP ' .. separator
        end
        if #self.client_names > 2 then
          return ' ' .. self.client_names[1] .. ' and 2 others'
        end
        return ' ' .. self.servers
      end,
      hl = { fg = fg, bg = bg, bold = true },
    },
    {
      update = { 'LspAttach', 'LspDetach', 'WinEnter' },
      condition = function(self) return self.active end,
      provider = function(self)
        if not rvim.falsy(self.linters) then return ' ' .. self.linters end
      end,
      hl = { fg = fg, bg = bg, bold = true },
    },
    {
      update = { 'LspAttach', 'LspDetach', 'WinEnter' },
      condition = function(self) return self.active end,
      provider = function(self)
        if not rvim.falsy(self.formatters) then
          return ' ' .. self.formatters
        end
      end,
      hl = { fg = fg, bg = bg, bold = true },
      on_click = {
        callback = function()
          vim.defer_fn(function() vim.cmd('ConformInfo') end, 100)
        end,
        name = 'formatters',
      },
    },
    {
      provider = ' ' .. codicons.misc.octoface,
      hl = { fg = colors.forest_green, bg = bg },
      on_click = {
        callback = function()
          vim.defer_fn(function() vim.cmd('copilot status') end, 100)
        end,
        name = 'copilot_attached',
      },
    },
    {
      provider = function(self)
        if self.copilot == nil then return fmt(' inactive %s', separator) end
        if
          vim.tbl_isempty(self.copilot.requests)
          or self.copilot.requests.type == 'pending'
        then
          return fmt(' idle %s', separator)
        elseif self.copilot.requests.type == 'cancel' then
          return fmt(' working %s', separator)
        end
        return fmt(' working %s', separator)
      end,
      hl = { fg = fg, bg = bg, bold = true },
      on_click = {
        callback = function()
          vim.defer_fn(function() vim.cmd('copilot panel') end, 100)
        end,
        name = 'copilot_status',
      },
    },
  },
  copilot_attached = {
    condition = function()
      return rvim.ai.enable
        and not rvim.plugins.minimal
        and rvim.lsp.null_ls.enable
    end,
    provider = ' ' .. codicons.misc.octoface .. ' ',
    hl = { fg = colors.forest_green, bg = bg },
    on_click = {
      callback = function()
        vim.defer_fn(function() vim.cmd('copilot status') end, 100)
      end,
      name = 'copilot_attached',
    },
  },
  copilot_status = {
    condition = function()
      return rvim.ai.enable
        and not rvim.plugins.minimal
        and rvim.lsp.null_ls.enable
    end,
    provider = function() return stl_copilot_indicator() end,
    hl = { fg = fg, bg = bg, bold = true },
    on_click = {
      callback = function()
        vim.defer_fn(function() vim.cmd('copilot panel') end, 100)
      end,
      name = 'copilot_status',
    },
  },
  dap = {
    condition = function()
      local session = require('dap').session()
      return session ~= nil
    end,
    provider = ' ' .. codicons.misc.bug .. ' ',
    on_click = {
      callback = function() require('dap').continue() end,
      name = 'dap_continue',
    },
    hl = { fg = colors.red, bg = bg },
  },
  file_type = utils.insert(file_block, file_icon, file_type),
  file_encoding = {
    condition = function(self)
      return not conditions.buffer_matches({
        filetype = self.filetypes,
      })
    end,
    {
      provider = function()
        local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc -- :h 'enc'
        return ' ' .. enc
      end,
      hl = { fg = fg, bg = bg },
    },
  },
  spell = {
    condition = function() return vim.wo.spell end,
    provider = function() return '  ' .. icons.misc.spell_check end,
    hl = { fg = colors.blue, bg = bg },
  },
  formatting = {
    condition = function()
      local curwin = api.nvim_get_current_win()
      local curbuf = api.nvim_win_get_buf(curwin)
      return vim.b[curbuf].formatting_disabled == true
        or vim.g.formatting_disabled == true
    end,
    provider = function() return '  ' .. codicons.misc.shaded_lock end,
    hl = { fg = colors.blue, bg = bg, bold = true },
  },
  treesitter = {
    condition = function() return rvim.treesitter.enable end,
    provider = function() return '  ' .. ts_active() end,
    hl = { fg = colors.forest_green, bg = bg },
  },
  session = {
    update = { 'User', pattern = 'PersistedStateChange' },
    {
      condition = function(self)
        return not conditions.buffer_matches({
          filetype = self.filetypes,
        })
      end,
      {
        provider = function()
          if vim.g.persisting then
            return ' 󰅠 '
          else
            return ' 󰅣 '
          end
        end,
        hl = { fg = colors.blue, bg = bg },
        on_click = {
          callback = function() vim.cmd('SessionToggle') end,
          name = 'toggle_session',
        },
      },
    },
  },
  macro_recording = {
    condition = function()
      return vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= ''
    end,
    update = { 'RecordingEnter', 'RecordingLeave' },
    {
      init = function(self)
        self.rec = vim.fn.reg_recording()
        self.exec = vim.fn.reg_executing()
      end,
      provider = function(self)
        if not rvim.falsy(self.rec) then
          return '  ' .. icons.misc.dot_alt .. ' ' .. 'REC'
        end
        if not rvim.falsy(self.exec) then
          return '  ' .. icons.misc.play .. ' ' .. 'PLAY'
        end
      end,
      hl = { bg = bg, fg = colors.red },
    },
  },
  buffers = {
    provider = function()
      local buffers = require('buffalo').buffers()
      local tabpages = require('buffalo').tabpages()
      return ' � ' .. buffers .. ' � ' .. tabpages -- �
    end,
    hl = { fg = '#ffaa00', bg = bg },
  },
  ruler = {
    provider = function() return '  %7(%l/%3L%):%2c ' .. progress() end,
    hl = { fg = colors.fg, bg = bg },
  },
  scroll_bar = {
    init = function(self)
      self.mode = vim.fn.mode(1)
      self.mode_color = mode_colors[self.mode:sub(1, 1)]
    end,
    provider = function()
      local current_line = vim.fn.line('.')
      local total_lines = vim.fn.line('$')
      local chars = {
        '▁',
        '▂',
        '▃',
        '▄',
        '▅',
        '▆',
        '▇',
        '█',
      }
      local line_ratio = current_line / total_lines
      local index = math.ceil(line_ratio * #chars)
      return ' ' .. chars[index]
    end,
    hl = function(self) return { fg = self.mode_color, bg = bg } end,
  },
}
