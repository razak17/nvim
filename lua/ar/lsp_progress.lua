-- ref: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/lsp/progress.lua

local api, o = vim.api, vim.o
local border = ar.ui.current.border

local M = {
  icons = {
    spinner = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
    done = ' ',
  },
  -- Maintain the total number of current windows
  total_wins = 0,
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
local function init_or_reset(client)
  client.is_done = false
  client.spinner_idx = 0
  client.winid = nil
  client.bufnr = nil
  client.message = nil
  client.pos = M.total_wins + 1
  client.timer = nil
end

-- Get the row position of the current floating window. If it is the first one, it is placed just
-- right above the statuslien; if not, it is placed on top of others.
local function get_win_row(pos) return o.lines - o.cmdheight - 1 - pos * 3 end

-- Update the window config
local function win_update_config(client)
  api.nvim_win_set_config(client.winid, {
    relative = 'editor',
    width = #client.message,
    height = 1,
    row = get_win_row(client.pos),
    col = o.columns - #client.message,
  })
end

-- Close the window and delete the associated buffer
local function close_window(winid, bufnr)
  if api.nvim_win_is_valid(winid) then api.nvim_win_close(winid, true) end
  if api.nvim_buf_is_valid(bufnr) then
    api.nvim_buf_delete(bufnr, { force = true })
  end
end

-- Assemble the output progress message and set the flag to mark if it's completed.
-- * General: ⣾ [client_name] title: message ( 5%)
-- * Done:     [client_name] title: DONE!
local function process_message(client, name, params)
  local message = ''
  message = '[' .. name .. ']'
  local kind = params.value.kind
  local title = params.value.title
  if title then message = message .. ' ' .. title .. ':' end
  if kind == 'end' then
    client.is_done = true
    message = M.icons.done .. ' ' .. message .. ' DONE!'
  else
    client.is_done = false
    local raw_msg = params.value.message
    local pct = params.value.percentage
    if raw_msg then message = message .. ' ' .. raw_msg end
    if pct then message = string.format('%s (%3d%%)', message, pct) end
    -- Spinner
    local idx = client.spinner_idx
    idx = idx == #M.icons.spinner * 4 and 1 or idx + 1
    message = M.icons.spinner[math.ceil(idx / 4)] .. ' ' .. message
    client.spinner_idx = idx
  end
  return message
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
        col = o.columns - #client.message,
        focusable = false,
        style = 'minimal',
        noautocmd = true,
        -- border = border,
      })
    end)
    if not success then return end
    client.winid = winid
    M.total_wins = M.total_wins + 1
  else
    win_update_config(client)
  end
  -- Write the message into the buffer
  vim.wo[winid].winhl = 'Normal:Normal'
  guard(
    function()
      api.nvim_buf_set_lines(client.bufnr, 0, 1, false, { client.message })
    end
  )
end

-- Display the progress message
local function handler(args)
  local client_id = args.data.client_id

  -- Initialize the properties
  if M.clients[client_id] == nil then
    M.clients[client_id] = {}
    init_or_reset(M.clients[client_id])
  end
  local cur_client = M.clients[client_id]

  -- Create buffer for the floating window showing the progress message and the timer used to close
  -- the window when progress report is done.
  if cur_client.bufnr == nil then
    cur_client.bufnr = api.nvim_create_buf(false, true)
  end
  if cur_client.timer == nil then cur_client.timer = vim.uv.new_timer() end

  -- Get the formatted progress message
  cur_client.message = process_message(
    cur_client,
    vim.lsp.get_client_by_id(client_id).name,
    args.data.params
  )

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
  pattern = { '*' },
  command = function(args) handler(args) end,
}, {
  event = { 'VimResized', 'TermLeave' },
  pattern = { '*' },
  command = function()
    for _, c in ipairs(M.clients) do
      if c.is_done then win_update_config(c) end
    end
  end,
})

-- https://github.com/santhosh-tekuri/dotfiles/blob/80767bccd3de67861d1dd06771b0bee06bdf4d95/.config/nvim/lua/autocmds.lua#L49
-- Show lsp progress on statusline
-- local lspprogress_buf = nil
-- vim.api.nvim_create_autocmd('LspProgress', {
--   desc = 'Show LSP Progress at bottom right corner',
--   ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
--   callback = function(ev)
--     --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
--     local value = ev.data.params.value
--     if type(value) ~= 'table' then return end
--     if value.kind == 'end' then
--       if lspprogress_buf ~= nil then
--         vim.api.nvim_buf_delete(lspprogress_buf, {})
--         lspprogress_buf = nil
--       end
--       return
--     end
--     local width = 35
--     if lspprogress_buf == nil then
--       lspprogress_buf = vim.api.nvim_create_buf(false, true)
--       vim.api.nvim_set_option_value(
--         'bufhidden',
--         'wipe',
--         { buf = lspprogress_buf }
--       )
--       local winid = vim.api.nvim_open_win(lspprogress_buf, false, {
--         relative = 'editor',
--         row = vim.o.lines - 1,
--         col = vim.o.columns - width,
--         width = width,
--         height = 1,
--         style = 'minimal',
--         focusable = false,
--       })
--       vim.api.nvim_set_option_value(
--         'winhighlight',
--         'Normal:Normal',
--         { win = winid }
--       )
--     end
--     local msg = ('%3d%%: %s %s'):format(
--       value.percentage or 100,
--       value.title or '',
--       value.message or ''
--     )
--     msg = ('%' .. width .. 's'):format(msg)
--     vim.api.nvim_buf_set_lines(lspprogress_buf, 0, -1, false, { msg })
--   end,
-- })
