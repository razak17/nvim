local M = {}

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

---@class lsp_soft_stop_opts_t
---@field retry integer?
---@field interval integer?
---@field on_close fun(client: vim.lsp.Client)

---Soft stop LSP client with retries
---@param client_or_id integer|vim.lsp.Client
---@param opts lsp_soft_stop_opts_t?
function M.soft_stop(client_or_id, opts)
  local client = type(client_or_id) == 'number'
      and vim.lsp.get_client_by_id(client_or_id)
    or client_or_id --[[@as vim.lsp.Client]]
  if not client then return end
  opts = opts or {}
  opts.retry = opts.retry or 4
  opts.interval = opts.interval or 500
  opts.on_close = opts.on_close or function() end

  if opts.retry <= 0 then
    client:stop(true)
    opts.on_close(client)
    return
  end
  client:stop()
  ---@diagnostic disable-next-line: invisible
  if client:is_stopped() then
    opts.on_close(client)
    return
  end
  vim.defer_fn(function()
    opts.retry = opts.retry - 1
    M.soft_stop(client, opts)
  end, opts.interval)
end

---Restart and reattach LSP client
---@param client_or_id integer|vim.lsp.Client
function M.restart(client_or_id)
  local client = type(client_or_id) == 'number'
      and vim.lsp.get_client_by_id(client_or_id)
    or client_or_id --[[@as vim.lsp.Client]]
  if not client then return end
  local config = client.config
  local attached_buffers = client.attached_buffers
  M.soft_stop(client, {
    on_close = function()
      for buf, _ in pairs(attached_buffers) do
        if not vim.api.nvim_buf_is_valid(buf) then return end
        vim.api.nvim_buf_call(buf, function() M.start(config) end)
      end
    end,
  })
end

function M.get_other_matching_providers(filetype)
  local configs = require('lspconfig.configs')
  local active_clients_list = M.get_active_clients_list_by_ft(filetype)
  local other_matching_configs = {}
  for _, config in pairs(configs) do
    if not vim.tbl_contains(active_clients_list, config.name) then
      local filetypes = config.filetypes or {}
      for _, ft in pairs(filetypes) do
        if ft == filetype then table.insert(other_matching_configs, config) end
      end
    end
  end
  return other_matching_configs
end

function M.get_managed_clients()
  local configs = require('lspconfig.configs')
  local clients = {}
  for _, config in pairs(configs) do
    if config.manager then
      vim.list_extend(clients, config.manager:clients())
    end
  end
  return clients
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
  if title then message = message .. ' ' .. title .. ':' end
  if kind == 'end' then
    client.is_done = true
    message = ar.ui.codicons.misc.checkmark .. '  ' .. message .. ' DONE!'
  else
    client.is_done = false
    local loaded_count = msg and string.match(msg, '^(%d+/%d+)') or ''
    message = message .. ' ' .. (loaded_count or '')
    local pct = params.percentage
    if ar_config.lsp.progress.spinner == 'circle' then
      local progress = ''
      if params.percentage then
        local spinners = ar.ui.spinners.circle_quarters
        local idx = math.max(1, math.floor(pct / 10))
        progress = spinners[idx] .. ' ' .. pct .. '% '
      end
      message = progress .. message
    elseif ar_config.lsp.progress.spinner == 'dots' then
      local spinners = ar.ui.spinners.dots_alt
      if pct then message = string.format('%s (%3d%%)', message, pct) end
      local idx = client.spinner_idx or 0
      idx = idx == #spinners * 4 and 1 or idx + 1
      message = spinners[math.ceil(idx / 4)] .. ' ' .. message
      client.spinner_idx = idx
    end
  end
  return message
end

return M
