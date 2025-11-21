-- ref: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/lsp/progress.lua

local api, o = vim.api, vim.o
local border_enabled = ar_config.ui.border ~= 'none'
local border_style = ar_config.ui.border
local border = ar.ui.current.border

local M = {
  -- Maintain the total number of current windows
  total_wins = 0,
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
  client.pos = M.total_wins + 1
  client.timer = nil
end

-- Get the row position of the current floating window. If it is the first one, it is placed just
-- right above the statusline; if not, it is placed on top of others.
--- @param pos integer
local function get_win_row(pos)
  return vim.o.lines - vim.o.cmdheight - 1 - pos * (border_enabled and 3 or 1)
end

-- Update the window config
--- @param client LspProgressClient
local function win_update_config(client)
  api.nvim_win_set_config(client.winid, {
    relative = 'editor',
    width = #client.message,
    height = 1,
    row = get_win_row(client.pos),
    -- row = vim.o.lines - 3,
    col = o.columns - #client.message,
  })
end

-- Close the window and delete the associated buffer
--- @param winid integer
--- @param bufnr integer
local function close_window(winid, bufnr)
  if api.nvim_win_is_valid(winid) then api.nvim_win_close(winid, true) end
  if api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_delete(bufnr, { force = true })
  end
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
    local success = guard(function()
      winid = api.nvim_open_win(client.bufnr, false, {
        relative = 'editor',
        width = #client.message,
        height = 1,
        row = get_win_row(client.pos),
        -- row = vim.o.lines - 3,
        col = o.columns - #client.message,
        focusable = false,
        style = 'minimal',
        noautocmd = true,
        border = border_style == 'single' and border or border_style,
      })
    end)
    if not success then return end
    client.winid = winid
    M.total_wins = M.total_wins + 1
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
  cur_client.name = vim.lsp.get_client_by_id(client_id).name
  -- Create buffer for the floating window showing the progress message and the timer used to close
  -- the window when progress report is done.
  cur_client.bufnr = cur_client.bufnr or api.nvim_create_buf(false, true)
  cur_client.timer = cur_client.timer or vim.uv.new_timer()

  -- Get the formatted progress message
  local utils = require('ar.utils.lsp')
  cur_client.message = utils.process_progress_msg(cur_client, params)

  -- Show progress message in floating window
  show_message(cur_client)

  -- Close the window when finished and adjust the positions of other windows if they exist.
  -- Let the window stay briefly on the screen before closing it (say 2s). When closing, attempt to
  -- close at intervals (say 100ms) to handle the potential textlock. We can use uv.timer to
  -- implement it.
  if cur_client.is_done then
    cur_client.timer:start(
      2000,
      100,
      vim.schedule_wrap(function()
        -- To handle the scenario 1
        if not cur_client.is_done and cur_client.winid ~= nil then
          cur_client.timer:stop()
          return
        end
        local success = false
        -- Close the window if it has not been closed yet
        if cur_client.winid ~= nil and cur_client.bufnr ~= nil then
          success = guard(
            function() close_window(cur_client.winid, cur_client.bufnr) end
          )
        end
        -- If the window is closed successfully, stop the timer, adjust the positions of other windows
        -- and reset properties of the client
        if success then
          cur_client.timer:stop()
          cur_client.timer:close()
          M.total_wins = M.total_wins - 1
          -- Move all windows above this closed window down by one position
          for _, c in ipairs(M.clients) do
            if c.winid ~= nil and c.pos > cur_client.pos then
              c.pos = c.pos - 1
              win_update_config(c)
            end
          end
          -- Reset the properties
          init_or_reset(cur_client)
        end
      end)
    )
  end
end

ar.augroup('lsp_progress', {
  event = { 'LspProgress' },
  pattern = { 'begin', 'report', 'end' },
  command = function(args) handler(args) end,
}, {
  event = { 'VimResized', 'TermLeave' },
  command = function()
    for _, c in ipairs(M.clients) do
      if c.is_done then win_update_config(c) end
    end
  end,
})
