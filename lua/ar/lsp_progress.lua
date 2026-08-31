-- ref: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/lsp/progress.lua

local api, o = vim.api, vim.o
local border_style = vim.o.winborder
local border_enabled = border_style ~= 'none'
local stale_timeout = 5 * 60 * 1000

local M = {
  ---@type table<LspProgressClient>
  clients = {},
}

-- Suppress errors that may occur while render windows. E.g., nvim_buf_set_lines() will throw E565
-- when textlock is active. I encounter this issue when I use quick-scope in visual mode and its
-- getchar() brings about textlock.
-- All other errors will be re-thrown.
-- Adapted from j-hui/fidget.nvim
---@param callable function
---@return boolean # If the callable executes successfully or not
local function guard(callable)
  local whitelist = {
    'E11: Invalid in command%-line window',
    'E523: Not allowed here',
    'E565: Not allowed to change',
  }
  local ok, err = pcall(callable)
  if ok then return true end
  if type(err) ~= 'string' then error(err) end
  for _, msg in ipairs(whitelist) do
    if string.find(err, msg) then return false end
  end
  error(err)
end

-- Initialize or reset the properties of the given client
--- @param client LspProgressClient
local function init_or_reset(client)
  client.name = nil
  client.is_done = false
  client.spinner_idx = 0
  client.winid = nil
  client.bufnr = nil
  client.message = nil
  client.timer = nil
  client.generation = client.generation or 0
end

-- Place the float at the bottom-right, above the command area and statusline.
---@param message string
---@return vim.api.keyset.win_config
local function get_win_config(message)
  local border_size = border_enabled and 2 or 0
  local statusline_height = o.laststatus == 0 and 0 or 1
  local width = math.min(
    math.max(1, api.nvim_strwidth(message)),
    math.max(1, o.columns - border_size)
  )
  return {
    relative = 'editor',
    width = width,
    height = 1,
    row = math.max(
      0,
      o.lines - o.cmdheight - statusline_height - border_size - 1
    ),
    col = math.max(0, o.columns - width - border_size),
  }
end

-- Update the window config
--- @param client LspProgressClient
local function win_update_config(client)
  api.nvim_win_set_config(client.winid, get_win_config(client.message))
end

-- Close the window and delete the associated buffer when provided.
--- @param winid integer?
--- @param bufnr integer?
local function close_window(winid, bufnr)
  if winid and api.nvim_win_is_valid(winid) then
    api.nvim_win_close(winid, true)
  end
  if bufnr and api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_delete(bufnr, { force = true })
  end
end

-- Close only the float, preserving its buffer for a replacement in another tab.
---@param client LspProgressClient
---@return boolean
local function close_client_window(client)
  if client.winid == nil then return true end
  local success = guard(function() close_window(client.winid, nil) end)
  if success then client.winid = nil end
  return success
end

-- Close all resources associated with a client's progress display.
---@param client LspProgressClient
---@return boolean
local function cleanup_client(client)
  local success = guard(function() close_window(client.winid, client.bufnr) end)
  if not success then return false end

  if client.timer then
    client.timer:stop()
    client.timer:close()
  end
  init_or_reset(client)
  return true
end

-- Close completed progress after a short delay, or abandoned progress after
-- five minutes without another event. Repeating handles transient textlock.
---@param client LspProgressClient
---@param timeout integer
local function arm_cleanup(client, timeout)
  client.timer:stop()
  local generation = client.generation
  client.timer:start(
    timeout,
    100,
    vim.schedule_wrap(function()
      if client.generation ~= generation then return end
      cleanup_client(client)
    end)
  )
end

-- Show the progress message in floating window
local function show_message(client)
  local winid = client.winid
  -- Create a new window or update the existing one
  if
    winid == nil
    or not api.nvim_win_is_valid(winid)
    or api.nvim_win_get_tabpage(winid) ~= api.nvim_get_current_tabpage() -- Switch to another tab
  then
    -- A float cannot move between tabpages. Close the old one before opening
    -- its replacement so it does not become an unreachable orphan.
    if not close_client_window(client) then return end
    local success = guard(function()
      local config = get_win_config(client.message)
      config.focusable = false
      config.style = 'minimal'
      config.noautocmd = true
      config.border = border_style
      winid = api.nvim_open_win(client.bufnr, false, config)
    end)
    if not success then return end
    client.winid = winid
  else
    win_update_config(client)
  end
  vim.wo[winid].winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder'
  -- Write the message into the buffer
  guard(
    function()
      api.nvim_buf_set_lines(client.bufnr, 0, 1, false, { client.message })
    end
  )
end

-- Display the progress message
---@param args AutocmdArgs
local function handler(args)
  local client_id, params = args.data.client_id, args.data.params.value

  -- Initialize the properties
  if M.clients[client_id] == nil then
    M.clients[client_id] = {}
    init_or_reset(M.clients[client_id])
  end

  ---@type LspProgressClient
  local cur_client = M.clients[client_id]
  local lsp_client = vim.lsp.get_client_by_id(client_id)
  if not lsp_client then
    cleanup_client(cur_client)
    return
  end
  cur_client.name = lsp_client.name
  cur_client.generation = (cur_client.generation or 0) + 1
  -- Create buffer for the floating window showing the progress message and the timer used to close
  -- the window when progress report is done.
  cur_client.bufnr = cur_client.bufnr or api.nvim_create_buf(false, true)
  cur_client.timer = cur_client.timer or vim.uv.new_timer()

  -- Get the formatted progress message
  local utils = require('ar.utils.lsp')
  cur_client.message = utils.process_progress_msg(cur_client, params)

  -- Show progress message in floating window
  show_message(cur_client)

  arm_cleanup(cur_client, cur_client.is_done and 2000 or stale_timeout)
end

local function update_windows()
  for _, client in pairs(M.clients) do
    if client.winid ~= nil and api.nvim_win_is_valid(client.winid) then
      guard(function() win_update_config(client) end)
    end
  end
end

ar.augroup('lsp_progress', {
  event = { 'LspProgress' },
  pattern = { 'begin', 'report', 'end' },
  command = function(args) handler(args) end,
}, {
  event = 'LspDetach',
  command = function(args)
    vim.schedule(function()
      local client_id = args.data.client_id
      local client = vim.lsp.get_client_by_id(client_id)
      if
        client
        and not client:is_stopped()
        and next(client.attached_buffers)
      then
        return
      end
      if M.clients[client_id] then cleanup_client(M.clients[client_id]) end
    end)
  end,
}, {
  event = { 'VimResized', 'TermLeave', 'WinEnter' },
  command = update_windows,
})
