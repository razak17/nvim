if not ar then return end

if
  ar.none
  or not ar.config.ui.statuscolumn.enable
  or ar.config.ui.statuscolumn.variant ~= 'custom'
then
  return
end

local fn, v, api, opt, wo, bo = vim.fn, vim.v, vim.api, vim.opt, vim.wo, vim.bo
local ui = ar.ui
local decor = ui.decorations
local separators = ui.icons.separators

local left_thin_block = separators.left_thin_block

local sep = { text = left_thin_block, texthl = 'StatusColSep' }

local config = {
  excluded_bts = { 'terminal' },
  excluded_fts = { 'blink-cmp-menu' },
  skipped_bts = { 'terminal' },
  skipped_fts = { 'neo-tree', 'snacks_picker_input' },
}

ar.ui.statuscolumn = {}

local function excluded(what, value)
  local tbl = config['excluded_' .. what]
  if not tbl then return false end
  return vim.tbl_contains(tbl, value)
end

local function skipped(what, value)
  local tbl = config['skipped_' .. what]
  if not tbl then return false end
  return vim.tbl_contains(tbl, value)
end

function ar.ui.statuscolumn.render()
  local win = vim.g.statusline_winid

  if wo[win].signcolumn == 'no' then return '' end

  if fn.win_gettype() == 'popup' then goto continue end

  if skipped('bts', bo.bt) then goto continue end

  if skipped('fts', bo.ft) then goto continue end

  if excluded('bts', bo.bt) then return '' end

  if excluded('fts', bo.ft) then return '' end

  ::continue::
  local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
  local buf = api.nvim_win_get_buf(win)
  local line_count = api.nvim_buf_line_count(buf)
  local statuscol = require('ar.statuscolumn')
  local icon, spacer = statuscol.icon, statuscol.space

  local left, gitsigns = statuscol.get_left(buf, lnum)
  local nr = statuscol.nr(win, lnum, relnum, virtnum, line_count)

  local fold
  api.nvim_win_call(win, function() fold = statuscol.get_fold(lnum) end)

  return table.concat({
    left,
    [[%=]],
    spacer(),
    nr .. spacer(),
    gitsigns and icon(gitsigns[1], 1) or spacer(),
    icon(sep, 1),
    icon(fold, 2),
  }, '')
end

ar.highlight.plugin('statuscolumn', {
  { StatusColSep = { link = 'VertSplit' } },
})

opt.statuscolumn = [[%!v:lua.ar.ui.statuscolumn.render()]]

ar.augroup('StatusCol', {
  event = { 'BufEnter', 'FileType', 'FocusGained', 'TextChanged' },
  command = function(args)
    local ft = bo[args.buf].ft
    local filepath = api.nvim_buf_get_name(args.buf)
    if ft == '' and filepath == '' then
      vim.opt_local.statuscolumn = ''
      return
    end
    local d = decor.get({
      ft = ft,
      fname = fn.bufname(args.buf),
      setting = 'statuscolumn',
    })
    if not d or ar.falsy(d) then return end
    if ar.falsy(d.ft) then vim.opt_local.statuscolumn = '' end
  end,
})
