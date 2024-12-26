local M = {}

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
    client.stop(true)
    opts.on_close(client)
    return
  end
  client.stop()
  ---@diagnostic disable-next-line: invisible
  if client.is_stopped() then
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

return M
