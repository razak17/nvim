local fn, api, env, fmt = vim.fn, vim.api, vim.env, string.format
local icons, codicons = ar.ui.icons, ar.ui.codicons
local separator = icons.separators.dotted_thin_block
local root_util = require('ar.utils.root')
local theming = require('ar.theming')
local P = theming.get_statusline_palette(ar.config.colorscheme.name)

local M = {}

M.is_dots_repo = false

M.git_status = { ahead = 0, behind = 0, status = nil }

---@param num? integer
---@return string
function M.space(num) return string.rep(' ', num or 1) end

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

---@param branch string
function M.pretty_branch(branch)
  if branch:len() < 15 then return branch end
  local prefix, rest = branch:match('^([^/]+)/(.+)$')
  if prefix then return prefix .. '/' .. ar.abbreviate(rest) end
  return ar.abbreviate(branch)
end

M.mode_to_str = {
  ['n'] = 'NORMAL',
  ['no'] = 'OP-PENDING',
  ['nov'] = 'OP-PENDING',
  ['noV'] = 'OP-PENDING',
  ['no\22'] = 'OP-PENDING',
  ['niI'] = 'NORMAL',
  ['niR'] = 'NORMAL',
  ['niV'] = 'NORMAL',
  ['nt'] = 'NORMAL',
  ['ntT'] = 'NORMAL',
  ['v'] = 'VISUAL',
  ['vs'] = 'VISUAL',
  ['V'] = 'V-LINE',
  ['Vs'] = 'VISUAL',
  ['\22'] = 'V-BLOCK',
  ['\22s'] = 'V-BLOCK',
  ['s'] = 'SELECT',
  ['S'] = 'S-LINE',
  ['\19'] = 'S-BLOCK',
  ['i'] = 'INSERT',
  ['ic'] = 'INSERT',
  ['ix'] = 'INSERT',
  ['R'] = 'REPLACE',
  ['Rc'] = 'REPLACE',
  ['Rx'] = 'REPLACE',
  ['Rv'] = 'VIRT REPLACE',
  ['Rvc'] = 'VIRT REPLACE',
  ['Rvx'] = 'VIRT REPLACE',
  ['c'] = 'COMMAND',
  ['cv'] = 'VIM EX',
  ['ce'] = 'EX',
  ['r'] = 'PROMPT',
  ['rm'] = 'MORE',
  ['r?'] = 'CONFIRM',
  ['!'] = 'SHELL',
  ['t'] = 'TERMINAL',
}

M.mode_colors = {
  n = P.blue,
  i = P.forest_green,
  v = P.pale_red,
  ['\22'] = P.pale_red,
  V = P.pale_red,
  c = P.pale_blue,
  no = P.pale_red,
  s = P.dark_orange,
  S = P.dark_orange,
  ['\19'] = P.lightgreen,
  ic = P.lightgreen,
  R = P.error_red,
  Rv = P.error_red,
  cv = P.pale_red,
  ce = P.pale_red,
  r = P.pale_blue,
  rm = P.pale_blue,
  ['r?'] = P.pale_blue,
  ['!'] = P.pale_red,
  t = P.pale_red,
}
-- https://github.com/LazyVim/LazyVim/blob/3f034d0a7f58031123300309f2efd3bb0356ee21/lua/lazyvim/util/lualine.lua?plain=1#L141
---@param opts? {cwd:false, subdirectory: true, parent: true, other: true, icon?:string}
function M.root_dir(opts)
  opts = vim.tbl_extend('force', {
    cwd = false,
    subdirectory = true,
    parent = true,
    other = true,
    icon = '󱉭',
    color = function() return { fg = ar.highlight.get('Special', 'fg') } end,
  }, opts or {})

  local function get()
    local cwd = root_util.cwd()
    local root = root_util.get({ normalize = true })
    local name = vim.fs.basename(root)

    if root == cwd then
      -- root is cwd
      return opts.cwd and name
    elseif root:find(cwd, 1, true) == 1 then
      -- root is subdirectory of cwd
      return opts.subdirectory and name
    elseif cwd:find(root, 1, true) == 1 then
      -- root is parent directory of cwd
      return opts.parent and name
    else
      -- root and cwd are not related
      return opts.other and name
    end
  end

  return { dir = get(), hl = opts.color(), icon = opts.icon }
end

function M.file_size()
  local bufnr = api.nvim_get_current_buf()
  local buf = api.nvim_buf_get_name(bufnr)

  if vim.bo[bufnr].readonly or vim.bo.bt == 'nowrite' then return '' end

  if string.len(buf) == 0 then return '' end

  local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
  local fsize = fn.getfsize(buf)
  fsize = (fsize < 0 and 0) or fsize
  if fsize < 1024 then return ' ' .. fsize .. suffix[1] end
  local i = math.floor((math.log(fsize) / math.log(1024)))

  return string.format(' %.1f%s', fsize / math.pow(1024, i), suffix[i + 1])
end

function M.file_icon()
  if ar.has('nvim-web-devicons') or ar.has('mini.icons') then
    local icon, icon_hl =
      require('nvim-web-devicons').get_icon(fn.expand('%:t'))
    return icon, icon_hl
  end
  return codicons.documents.default_file, 'DevIconDefault'
end

local function location_space(total, line_number)
  local t_digits = #tostring(total)
  local ln_digits = #tostring(line_number)
  if t_digits <= 3 then return M.space(t_digits - 2) end
  if t_digits == 4 and ln_digits <= 1 then
    return M.space(t_digits - ln_digits)
  end
  return M.space(t_digits - (ln_digits - 1))
end

function M.location()
  local line_number = fn.line('.')
  local total = fn.line('$')
  local location = '%7(%l/%1L%):%2c '
  if total <= 9 then location = '%4(%l/%1L%):%2c ' end
  return location_space(total, line_number) .. location
end

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
  if has_pending_updates then return pending_updates end
  return ''
end

function M.package_info()
  local ok, pkg_info = pcall(require, 'package-info')
  if not ok then return '' end
  return pkg_info.get_status()
end

function M.get_lsp_servers(opts)
  local curwin = api.nvim_get_current_win()
  local curbuf = api.nvim_win_get_buf(curwin)
  opts.ignored = opts.ignored or {}
  opts.included = opts.included or {}
  -- stylua: ignore
  return vim
    .iter(vim.lsp.get_clients({ bufnr = curbuf }))
    :filter(function(c) return #opts.included and vim.tbl_contains(opts.included, c.name) or true end)
    :filter(function(c) return not vim.tbl_contains(opts.ignored, c.name) end)
    :map(function(client) return client.name end)
    :totable()
end

function M.format_servers(servers)
  if #servers == 0 then return 'No Active LSP ' end
  if #servers > 2 then
    return fmt('%s +%d %s', servers[1], #servers - 1, separator)
  end
  local names = table.concat(servers, fmt(' %s ', separator))
  -- return table.concat(servers, ', ') .. ' ' .. separator
  return names .. ' ' .. separator
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
  return #linters > 0 and M.format_servers(linters) or ''
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
  return #formatters > 0 and M.format_servers(formatters) or ''
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

local copilot_opts = {
  icons = {
    enabled = '',
    sleep = '',
    disabled = '',
    warning = '',
    unknown = '',
  },
  hl = {
    pending = '#50FA7B',
    sleep = '#636DA6',
    warning = '#FFB86C',
    unknown = '#FF5555',
  },
}

function M.sidekick_status()
  local status = require('sidekick.status').get()
  if status == nil then return '' end
  local opts = copilot_opts
  if status.busy then
    return { icon = opts.icons.enabled, hl = opts.hl.pending }
  end
  if status.kind == 'Normal' then
    return { icon = opts.icons.enabled, hl = opts.hl.sleep }
  elseif status.kind == 'Warning' then
    return { icon = opts.icons.warning, hl = opts.hl.warning }
  elseif status.kind == 'Inactive' then
    return { icon = opts.icons.sleep, hl = opts.hl.sleep }
  elseif status.kind == 'Error' then
    return { icon = opts.icons.sleep, hl = opts.hl.unknown }
  else
    return { icon = opts.icons.enabled, hl = opts.hl.sleep }
  end
end

function M.copilot_native_status()
  local opts = copilot_opts
  local clients = vim.lsp.get_clients({ name = 'copilot', bufnr = 0 })
  if not (clients and #clients > 0) then return '' end
  local status = ar.config.ai.completion.status
  if ar.falsy(status) then
    return { icon = opts.icons.sleep, hl = opts.hl.sleep }
  elseif status[1] == 'pending' then
    return { icon = opts.icons.enabled, hl = opts.hl.pending }
  else
    return { icon = opts.icons.enabled, hl = opts.hl.sleep }
  end
end

-- Ref: https://github.com/AndreM222/copilot-lualine/blob/6bc29ba1fcf8f0f9ba1f0eacec2f178d9be49333/lua/lualine/components/copilot.lua?plain=1#L7
function M.copilot_status()
  local opts = copilot_opts
  local clients = vim.lsp.get_clients({ name = 'copilot', bufnr = 0 })
  if not ar.has('copilot.lua') and not (clients and #clients > 0) then
    return { icon = opts.icons.unknown, hl = opts.hl.unknown }
  end
  local copilot = require('ar.copilot_status')
  if copilot.is_loading() then
    return { icon = opts.icons.enabled, hl = opts.hl.pending }
  elseif copilot.is_error() then
    return { icon = opts.icons.warning, hl = opts.hl.warning }
  elseif not copilot.is_enabled() then
    return { icon = opts.icons.disabled, hl = opts.hl.sleep }
  elseif copilot.is_sleep() then
    return { icon = opts.icons.sleep, hl = opts.hl.sleep }
  else
    return { icon = opts.icons.enabled, hl = opts.hl.sleep }
  end
end

M.lsp_progress = { message = '' }
M.lsp_pending = { message = '' }

---@param args AutocmdArgs
function M.lsp_progress.handle(args)
  local data, params = args.data, args.data.params.value

  ---@type LspProgressClient
  local client = { name = vim.lsp.get_client_by_id(data.client_id).name }
  local message = require('ar.utils.lsp').process_progress_msg(client, params)

  -- replace % with %% to avoid statusline issues
  return { message = message:gsub('%%', '%%%%'), is_done = client.is_done }
end

function M.autocmds()
  -- Ref: https://github.com/NvChad/ui/blob/v3.0/lua/nvchad/stl/utils.lua?plain=1#L161
  ar.augroup('stl_lsp_autocmds', {
    event = { 'LspProgress' },
    desc = 'LSP Progress',
    pattern = { 'begin', 'report', 'end' },
    command = function(args)
      local progress = M.lsp_progress.handle(args)
      M.lsp_progress.message = progress.message
      if progress.is_done then M.lsp_progress.message = '' end
      vim.defer_fn(function() vim.cmd.redrawstatus() end, 500)
    end,
  }, {
    -- Ref: https://github.com/emmanueltouzery/nvim_config/blame/5c3d184b2ab62aa0cd3e8861ecc23c5f51931d33/lua/plugins/lualine.lua#L240
    event = { 'LspRequest' },
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
        M.lsp_pending.message = '󰘦 Pending LSP requests: '
          .. active_requests_count
      else
        M.lsp_pending.message = ''
      end
      vim.cmd.redrawstatus()
    end,
  })
end

function M.search_matches()
  local ok, search = pcall(fn.searchcount)
  if ok and search.total then search = search end
  if search.current == 0 or search.total == 0 then return '' end
  return string.format(
    ' %d/%d',
    search.current,
    math.min(search.total, search.maxcount)
  )
end

function M.word_count() return '' .. tostring(fn.wordcount().words) .. ' words' end

function M.gp_extract_topic_from_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
  if not first_line then return nil end
  local topic = first_line:match('^#%s*topic:%s*(.+)$')
  return topic
end

function M.intro_statusline(bufnr)
  -- opt.foldenable = false
  vim.opt.colorcolumn = ''
  vim.o.laststatus = 0
  map('n', 'q', '<Cmd>q<CR>', { buffer = bufnr, nowait = true })

  vim.api.nvim_create_autocmd('BufUnload', {
    buffer = bufnr,
    callback = function() vim.o.laststatus = 3 end,
  })
end

return M
