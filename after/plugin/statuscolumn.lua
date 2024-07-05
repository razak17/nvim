if
  not ar
  or ar.none
  or not ar.plugins.enable
  or ar.plugins.minimal
  or not ar.ui.statuscolumn.enable
  or not ar.ui.statuscolumn.custom
then
  return
end

local fn, v, api, opt, wo = vim.fn, vim.v, vim.api, vim.opt, vim.wo
local ui = ar.ui
local icons, separators = ui.icons, ui.icons.separators

local left_thin_block = separators.left_thin_block
local fcs = opt.fillchars:get()
local space = ' '

---@param num? integer
---@return string
local function spacer(num)
  num = num or 1
  return string.rep(space, num)
end

local sep = { text = left_thin_block, texthl = 'IndentBlanklineChar' }

function ar.ui.statuscolumn.render()
  local win = vim.g.statusline_winid

  if wo[win].signcolumn == 'no' then return '' end

  local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
  local statuscol = require('ar.statuscolumn').utils
  local buf = api.nvim_win_get_buf(win)
  local line_count = api.nvim_buf_line_count(buf)

  local icon = statuscol.icon
  local nr = statuscol.nr(win, lnum, relnum, virtnum, line_count)
  local marks = statuscol.get_mark(buf, lnum)
  local gitsigns, other_sns = statuscol.extmark_signs(buf, lnum)

  local left = {}
  if marks then
    if #other_sns == 0 then
      left[#left + 1] = icon(marks, 2)
    else
      left[#left + 1] = icon(marks, 1)
    end
  end
  if #other_sns > 0 then
    vim.iter(other_sns):fold(left, function(acc, key)
      if #acc == 0 then
        acc[#acc + 1] = icon(key, 1)
      else
        acc[#acc + 1] = ' ' .. icon(key, 0)
      end
      return acc
    end)
  end

  local fold
  api.nvim_win_call(win, function()
    -- https://www.reddit.com/r/neovim/comments/1djjc6q/statuscolumn_a_beginers_guide/
    local foldlevel = vim.fn.foldlevel(lnum)
    local foldlevel_before = fn.foldlevel((lnum - 1) >= 1 and lnum - 1 or 1)
    local foldlevel_after =
      fn.foldlevel((lnum + 1) <= fn.line('$') and (lnum + 1) or fn.line('$'))

    local foldclosed = fn.foldclosed(lnum)

    -- Line has nothing to do with folds so we will skip it
    if foldlevel == 0 then
      fold = { text = ' ', texthl = 'Comment' }
    -- Line is a closed fold(I know second condition feels unnecessary but I will still add it)
    elseif foldclosed ~= -1 and foldclosed == lnum then
      fold = { text = fcs.foldclose or icons.chevron_right, texthl = 'Comment' }
    -- I didn't use ~= because it couldn't make a nested fold have a lower level than it's parent fold and it's not something I would use
    elseif foldlevel > foldlevel_before then
      fold = { text = fcs.foldopen or icons.chevron_down, texthl = 'Comment' }
    -- The line is the last line in the fold
    elseif foldlevel > foldlevel_after then
      fold = { text = ' ', texthl = 'IndentBlanklineChar' } --  ╰
      -- Line is in the middle of an open fold
    else
      fold = { text = ' ', texthl = 'IndentBlanklineChar' } -- │
    end
    -- if fn.foldclosed(lnum) >= 0 then
    --   fold = { text = fcs.foldclose or '', texthl = 'Comment' }
    -- end
  end)

  return table.concat({
    #left > 0 and table.concat(left, '') or spacer(2),
    [[%=]],
    space,
    nr .. spacer(),
    gitsigns and icon(gitsigns[1], 1) or spacer(),
    icon(sep, 1),
    icon(fold, 2),
  }, '')
end

opt.statuscolumn = [[%!v:lua.ar.ui.statuscolumn.render()]]

ar.augroup('StatusCol', {
  event = { 'BufEnter', 'FileType', 'CursorMoved' },
  command = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].ft
    local d = ui.decorations.get({
      ft = ft,
      fname = fn.bufname(buf),
      setting = 'statuscolumn',
    })
    if not d then return end
    if d.ft == false or d.fname == false then
      vim.opt_local.statuscolumn = ''
      -- else
      --   opt.statuscolumn = [[%!v:lua.ar.ui.statuscolumn.render()]]
    end
  end,
})
