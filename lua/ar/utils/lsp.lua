local M = {}

-- https://github.com/CRAG666/dotfiles/blob/27c915ea05c4a15171b4db16f6883f2de065ecec/config/nvim/lua/utils/lsp.lua#L3

---@type lsp.config
---@diagnostic disable-next-line: missing-fields
M.default_config = {
  root_markers = require('ar.utils.fs').root_markers,
}

--- @class LspProgressParams
--- @field kind string?
--- @field title string?
--- @field percentage integer?
--- @field message string?

--- @class LspProgressClient
--- @field name string?
--- @field is_done boolean?
--- @field spinner_idx integer?
--- @field winid integer?
--- @field bufnr integer?
--- @field message string?
--- @field pos integer?
--- @field timer (uv.uv_timer_t)?

---@class (partial) lsp.config : vim.lsp.Config
---@field requires? string[] additional executables required to start the language server
---@field buf_support? boolean whether the language server works on buffers without corresponding files

-- Avoid recursion after overriding
local lsp_start = vim.lsp.start

---Wrapper of `vim.lsp.start()`, starts and attaches LSP client for
---the current buffer
---@param config lsp.config
---@param opts table?
---@return integer? client_id id of attached client or nil if failed
function M.start(config, opts)
  -- Don't early return if `buftype` is 'nofile', because some plugins
  -- (e.g. opencode) may start a in-process LSP server to provide completions
  if not config then return end

  local cmd_type = type(config.cmd)
  local cmd_exec = cmd_type == 'table' and config.cmd[1]
  if
    cmd_type == 'table' and vim.fn.executable(cmd_exec or '') == 0
    or vim
      .iter(config.requires or {})
      :any(function(e) return vim.fn.executable(e) == 0 end)
  then
    return
  end

  local name = cmd_exec
  local bufname = vim.api.nvim_buf_get_name(0)

  if config.buf_support == false and not vim.uv.fs_stat(bufname) then return end

  ---Check if a directory is valid, return it if so, else return nil
  ---@param dir string?
  ---@return string?
  local function validate(dir)
    -- For some special buffers like `fugitive:///xxx`, `vim.fs.root()`
    -- returns '.' as result, which is NOT a valid directory
    return dir ~= nil
        and dir ~= ''
        and dir ~= '.'
        and vim.fn.isdirectory(dir) == 1
        -- Some language servers e.g. lua-language-server, refuse
        -- to use home dir as its root dir and prints an error message
        and not require('ar.utils.fs').is_home_dir(dir)
        and not require('ar.utils.fs').is_root_dir(dir)
        and dir
      or nil
  end

  local root_dir = validate(
    require('ar.utils.fs').root(
      bufname,
      vim.list_extend(
        config.root_markers or {},
        M.default_config.root_markers or {}
      )
    )
  ) or validate(vim.fs.dirname(bufname)) or vim.fn.getcwd(0)

  return lsp_start(
    vim.tbl_deep_extend('keep', config or {}, {
      name = name,
      root_dir = root_dir,
    }, M.default_config),
    opts
  )
end

---@class lsp.soft_stop.opts
---@field retry integer?
---@field interval integer?
---@field on_close fun(client: vim.lsp.Client)

---Soft stop LSP client with retries
---@param client_or_id integer|vim.lsp.Client
---@param opts lsp.soft_stop.opts?
function M.soft_stop(client_or_id, opts)
  local client = type(client_or_id) == 'number'
      and vim.lsp.get_client_by_id(client_or_id)
    or client_or_id --[[@as vim.lsp.Client]]
  if not client then return end
  opts = opts or {}
  opts.retry = opts.retry or 4
  opts.interval = opts.interval or 500
  opts.on_close = opts.on_close or function() end

  if client:is_stopped() then
    opts.on_close(client)
    return
  end

  if opts.retry < 0 then return end

  client:stop(opts.retry == 0)
  vim.defer_fn(function()
    opts.retry = opts.retry - 1
    M.soft_stop(client, opts)
  end, opts.interval)
end

---Restart and reattach LSP client
---@param client_or_id integer|vim.lsp.Client
---@param opts { on_restart: fun(client_id: integer)? }?
function M.restart(client_or_id, opts)
  local client = type(client_or_id) == 'number'
      and vim.lsp.get_client_by_id(client_or_id)
    or client_or_id --[[@as vim.lsp.Client]]
  if not client then return end

  -- `client.attached_buffers` will be empty after client is stopped,
  -- save it before stopping
  local attached_buffers = vim.deepcopy(client.attached_buffers, true)
  local config = client.config
  M.soft_stop(client, {
    on_close = function()
      for buf, _ in pairs(attached_buffers) do
        if not vim.api.nvim_buf_is_valid(buf) then return end
        vim.api.nvim_buf_call(buf, function()
          ---@cast config lsp.config
          local id = M.start(config)
          if id and opts and opts.on_restart then opts.on_restart(id) end
        end)
      end
    end,
  })
end

-- Assemble the output progress message and set the flag to mark if it's completed.
-- * Circle Spinner:  󰪟 30% [client.name] title: message
-- * Regular Spinner: ⣾ [client.name] title: message ( 5%)
-- * Done:             [client.name] title: DONE!
--- @param client LspProgressClient
--- @param params LspProgressParams
function M.process_progress_msg(client, params)
  local kind, msg, title = params.kind, params.message, params.title
  local message = client.name and '[' .. client.name .. ']' or ''
  if title then message = message .. ' ' .. title end
  if kind == 'end' then
    client.is_done = true
    message = ar.ui.codicons.misc.checkmark .. '  ' .. message .. ': DONE!'
  else
    client.is_done = false
    local loaded_count = msg and string.match(msg, '^(%d+/%d+)') or ''
    if loaded_count ~= '' then message = message .. ': ' .. loaded_count end
    local pct = params.percentage
    local progress = ''
    if ar.config.lsp.progress.spinner == 'circle' then
      if pct then
        local spinners = ar.ui.spinners.circle_quarters
        local idx = math.max(1, math.floor(pct / 10))
        progress = spinners[idx] .. ' ' .. pct .. '% '
      end
      message = progress .. message
    elseif ar.config.lsp.progress.spinner == 'dots' then
      if pct then
        local spinners = ar.ui.spinners.dots_alt
        message = string.format('%s (%3d%%)', message, pct)
        local idx = client.spinner_idx or 0
        idx = idx == #spinners * 4 and 1 or idx + 1
        client.spinner_idx = idx
        progress = spinners[math.ceil(idx / 4)] .. ' '
      end
      message = progress .. message
    end
  end
  return message
end

return M
