if
  not ar
  or ar.none
  or not ar.plugins.enable
  or ar.plugins.minimal
  or not ar_config.ui.statuscolumn.enable
  or ar_config.ui.statuscolumn.variant ~= 'local'
then
  return
end

local fn, v, api, opt, wo, bo = vim.fn, vim.v, vim.api, vim.opt, vim.wo, vim.bo
local ui = ar.ui
local decor = ui.decorations
local separators = ui.icons.separators

local left_thin_block = separators.left_thin_block

local sep = { text = left_thin_block, texthl = 'IndentBlanklineChar' }

ar.ui.statuscolumn = {}

function ar.ui.statuscolumn.render()
  local win = vim.g.statusline_winid

  if wo[win].signcolumn == 'no' then return '' end

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

opt.statuscolumn = [[%!v:lua.ar.ui.statuscolumn.render()]]

ar.augroup('StatusCol', {
  event = { 'BufEnter', 'FileType', 'FocusGained', 'TextChanged' },
  command = function(args)
    local d = decor.get({
      ft = bo[args.buf].ft,
      bt = bo[args.buf].bt,
      fname = fn.bufname(args.buf),
      setting = 'statuscolumn',
    })
    if not d or ar.falsy(d) then return end
    if d.ft == false or d.bt == false or d.fname == false then
      vim.opt_local.statuscolumn = ''
    end
  end,
})
