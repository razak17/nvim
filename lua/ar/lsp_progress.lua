-- ref: https://github.com/rockyzhang24/dotfiles/blob/master/.config/nvim/lua/rockyz/lsp/progress.lua

-- Buffer number and window id for the floating window

local api = vim.api
local border = rvim.ui.current.border

local M = {
  bufnr = nil,
  winid = nil,
  spinner = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
  idx = 0,
  is_done = true,
}

-- Get the progress message for all clients. The format is
-- "65%: [lua_ls] Loading Workspace: 123/1500 | [client2] xxx | [client3] xxx"
local function get_lsp_progress_msg()
  -- Most code is grabbed from the source of vim.lsp.status()
  -- Ref: https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp.lua
  local percentage = nil
  local all_messages = {}
  M.is_done = true
  for _, client in ipairs(vim.lsp.get_clients()) do
    local messages = {}
    for progress in client.progress do
      local value = progress.value
      if type(value) == 'table' and value.kind then
        if value.kind ~= 'end' then M.is_done = false end
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
  M.idx = M.idx == #M.spinner * 4 and 1 or M.idx + 1
  message = M.spinner[math.ceil(M.idx / 4)] .. message
  return message
end

rvim.augroup('CustomLspProgress', {
  event = 'LspProgress',
  pattern = '*',
  command = function()
    -- The row position of the floating window. Just right above the status line.
    local win_row = vim.o.lines - vim.o.cmdheight - 4
    local message = get_lsp_progress_msg()
    if
      M.winid == nil
      or not api.nvim_win_is_valid(M.winid)
      or api.nvim_win_get_tabpage(M.winid) ~= api.nvim_get_current_tabpage()
    then
      M.bufnr = api.nvim_create_buf(false, true)
      M.winid = api.nvim_open_win(M.bufnr, false, {
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
      api.nvim_win_set_config(M.winid, {
        relative = 'editor',
        width = #message,
        row = win_row,
        col = vim.o.columns - #message,
      })
    end
    vim.wo[M.winid].winhl = 'NormalFloat:NormalFloat'
    api.nvim_buf_set_lines(M.bufnr, 0, 1, false, { message })
    if M.is_done then
      if api.nvim_win_is_valid(M.winid) then
        api.nvim_win_close(M.winid, true)
      end
      if api.nvim_buf_is_valid(M.bufnr) then
        api.nvim_buf_delete(M.bufnr, { force = true })
      end
      M.winid = nil
      M.idx = 0
    end
  end,
})
