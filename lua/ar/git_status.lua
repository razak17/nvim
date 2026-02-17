-- https://github.com/mattmorgis/git-statusline.nvim/blob/main/lua/git_statusline/init.lua

local M = {}

local state = {
  by_root = {},
  inflight = {},
  timers = {},
  autocmds_setup = false,
}

local config = {
  debounce_ms = 200,
}

local function setup_autocmds()
  if state.autocmds_setup then return end

  state.autocmds_setup = true
  ar.augroup('GitRemote', {
    event = { 'BufEnter', 'BufWritePost', 'FocusGained', 'DirChanged' },
    command = function(args) M.refresh(args.buf) end,
  })
end

local function git_root_for_buf(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return vim.fs.root(vim.fn.getcwd(0), { '.git' }) end
  return vim.fs.root(name, { '.git' })
end

local function parse_git_status(output)
  if not output or output == '' then return '' end

  local lines = vim.split(output, '\n', { trimempty = true })
  if #lines == 0 then return '' end

  local head = lines[1]
  if not vim.startswith(head, '## ') then return '' end

  local branch_info = head:sub(4)
  local branch = branch_info
  local ahead = tonumber(branch_info:match('ahead (%d+)') or 0)
  local behind = tonumber(branch_info:match('behind (%d+)') or 0)

  local local_branch = branch_info:match('^([^%.]+)%.%.%.')
    or branch_info:match('^([^%s]+)')
  if local_branch and local_branch ~= '' then branch = local_branch end

  if branch:match('^HEAD') then branch = 'detached' end

  local dirty = (#lines > 1)

  local parts = { branch .. (dirty and '*' or ''), behind, ahead }

  return table.concat(parts, ' ')
end

local function refresh_git_status(root)
  if state.inflight[root] then return end
  state.inflight[root] = true

  vim.system(
    { 'git', 'status', '--porcelain=v1', '-b' },
    { cwd = root },
    function(result)
      state.inflight[root] = nil

      if result.code ~= 0 then
        state.by_root[root] = ''
        return
      end

      state.by_root[root] = parse_git_status(result.stdout or '')
      vim.schedule(function() vim.cmd('redrawstatus') end)
    end
  )
end

local function schedule_refresh(root)
  if state.timers[root] then return end

  local timer = vim.uv.new_timer()
  if not timer then return end
  state.timers[root] = timer
  timer:start(config.debounce_ms, 0, function()
    timer:stop()
    timer:close()
    state.timers[root] = nil
    refresh_git_status(root)
  end)
end

local function ensure_git_status(root)
  if state.by_root[root] == nil then
    state.by_root[root] = ''
    refresh_git_status(root)
    return
  end

  schedule_refresh(root)
end

function M.get(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  setup_autocmds()
  local root = git_root_for_buf(buf)
  if not root then return '' end
  ensure_git_status(root)
  return state.by_root[root] or ''
end

function M.refresh(buf)
  local root = git_root_for_buf(buf)
  if not root then return end
  schedule_refresh(root)
end

function M.setup(opts) config = vim.tbl_extend('force', config, opts or {}) end

return M
