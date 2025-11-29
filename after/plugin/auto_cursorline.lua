local enabled = ar.config.plugin.custom.auto_cursorline.enable

if not ar or ar.none or not enabled then return end

local decor = ar.ui.decorations

---@param buf number
---@return boolean
function ar.ui.show_cursorline(buf)
  local show = false
  local decs = decor.get({
    ft = vim.bo[buf].ft,
    bt = vim.bo[buf].bt,
    setting = 'cursorline',
  })
  if not decs or ar.falsy(decs) then
    show = true
  else
    show = decs.ft == true or decs.bt == true
  end

  return vim.bo[buf].buftype ~= 'terminal'
    and not vim.wo.previewwindow
    -- and vim.wo.winhighlight == '' -- NOTE: enable this if you want to disable cursorline in floating windows (neo-tree)
    and vim.bo[buf].filetype ~= ''
    and show
end

ar.augroup('ShowCursorline', {
  event = { 'BufEnter', 'WinEnter', 'CursorHold', 'InsertLeave' },
  command = function(args) vim.wo.cursorline = ar.ui.show_cursorline(args.buf) end,
}, {
  event = { 'BufLeave', 'InsertEnter' },
  command = function() vim.wo.cursorline = false end,
})

-- https://github.com/folke/dot/blob/cb1d6f956e0ef1848e57a57c1678d8635980d6c5/nvim/lua/config/autocmds.lua#L1C1-L17C3
-- show cursor line only in active window
ar.augroup('AutoCursorline', {
  event = { 'InsertLeave', 'WinEnter' },
  command = function()
    if vim.w.auto_cursorline then
      vim.wo.cursorline = true
      vim.w.auto_cursorline = nil
    end
  end,
}, {
  event = { 'InsertEnter', 'WinLeave' },
  command = function()
    if vim.wo.cursorline then
      vim.w.auto_cursorline = true
      vim.wo.cursorline = false
    end
  end,
})
