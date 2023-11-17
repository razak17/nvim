if not rvim or not rvim.lsp.enable or rvim.plugins.minimal then return end

-- ref: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/lsp/progress.lua

local api = vim.api

-- Buffer number and window id for the floating window
local bufnr
local winid
local spinner = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' }
local idx = 0
-- Progress is done or not
local is_done = true

-- Get the progress message for all clients. The format is
-- "65%: [lua_ls] Loading Workspace: 123/1500 | [client2] xxx | [client3] xxx"
local function get_lsp_progress_msg()
  -- Most code is grabbed from the source of vim.lsp.status()
  -- Ref: https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp.lua
  local percentage = nil
  local all_messages = {}
  is_done = true
  for _, client in ipairs(vim.lsp.get_clients()) do
    local messages = {}
    for progress in client.progress do
      local value = progress.value
      if type(value) == 'table' and value.kind then
        if value.kind ~= 'end' then is_done = false end
        local message = value.message and (value.title .. ': ' .. value.message)
          or value.title
        messages[#messages + 1] = message
        if value.percentage then
          percentage = math.max(percentage or 0, value.percentage)
        end
      end
    end
    if next(messages) ~= nil then
      table.insert(
        all_messages,
        '[' .. client.name .. '] ' .. table.concat(messages, ', ')
      )
    end
  end
  local message = table.concat(all_messages, ' | ')
  -- Show percentage
  if percentage then
    message = string.format('%3d%%: %s', percentage, message)
  end
  -- Show spinner
  idx = idx == #spinner * 4 and 1 or idx + 1
  message = spinner[math.ceil(idx / 4)] .. message
  return message
end

rvim.augroup('CustomLspProgress', {
  event = 'LspProgress',
  pattern = '*',
  command = function()
    -- The row position of the floating window. Just right above the status line.
    local win_row = vim.o.lines - vim.o.cmdheight - 4
    local message = get_lsp_progress_msg()
    local border = rvim.ui.current.border
    if
      winid == nil
      or not api.nvim_win_is_valid(winid)
      or api.nvim_win_get_tabpage(winid) ~= api.nvim_get_current_tabpage()
    then
      bufnr = api.nvim_create_buf(false, true)
      winid = api.nvim_open_win(bufnr, false, {
        relative = 'editor',
        width = #message,
        height = 1,
        row = win_row,
        col = vim.o.columns - #message,
        style = 'minimal',
        noautocmd = true,
        border = border,
      })
    else
      api.nvim_win_set_config(winid, {
        relative = 'editor',
        width = #message,
        row = win_row,
        col = vim.o.columns - #message,
      })
    end
    vim.wo[winid].winhl = 'NormalFloat:NormalFloat'
    api.nvim_buf_set_lines(bufnr, 0, 1, false, { message })
    if is_done then
      if api.nvim_win_is_valid(winid) then api.nvim_win_close(winid, true) end
      if api.nvim_buf_is_valid(bufnr) then
        api.nvim_buf_delete(bufnr, { force = true })
      end
      winid = nil
      idx = 0
    end
  end,
})
