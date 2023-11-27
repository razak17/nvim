if
  not rvim
  or rvim.none
  or not rvim.plugins.enable
  or rvim.plugins.minimal
  or not rvim.ui.statuscolumn.enable
  or not rvim.ui.statuscolumn.custom
then
  return
end

local fn, v, api, opt, wo = vim.fn, vim.v, vim.api, vim.opt, vim.wo
local ui = rvim.ui
local sp = ui.icons.separators

local separator = sp.left_thin_block
local fcs = opt.fillchars:get()
local space = ' '

local sep = { text = separator, texthl = 'IndentBlanklineChar' }

---@alias Sign {name:string, text:string, texthl:string, priority:number}

-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@return Sign[],Sign[]
---@param buf number
---@param lnum number
local function get_signs(buf, lnum)
  -- Get regular signs
  ---@type Sign[]
  local signs = vim.tbl_map(function(sign)
    ---@type Sign
    local ret = fn.sign_getdefined(sign.name)[1]
    -- ret.priority = sign.priority
    return ret
  end, fn.sign_getplaced(buf, { group = '*', lnum = lnum })[1].signs)

  -- Get extmark signs
  local extmarks = api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = 'sign' }
  )

  local sns = vim
    .iter(extmarks)
    :map(function(item) return rvim.format_text(item[4], 'sign_text') end)
    :fold({ git = {}, other = {} }, function(acc, item)
      local txt, hl = item.sign_text, item.sign_hl_group
      if hl:match('^Trail') then txt = ui.codicons.misc.bookmark end
      local target = hl:match('^Git') and acc.git or acc.other
      table.insert(target, { text = txt, texthl = hl })
      return acc
    end)

  return sns.git, sns.other
end

---@return Sign?
---@param buf number
---@param lnum number
local function get_mark(buf, lnum)
  local marks = fn.getmarklist(buf)
  vim.list_extend(marks, fn.getmarklist())
  for _, mark in ipairs(marks) do
    if
      mark.pos[1] == buf
      and mark.pos[2] == lnum
      and mark.mark:match('[a-zA-Z]')
    then
      return { text = mark.mark:sub(2), texthl = 'DiagnosticHint' }
    end
  end
end

---@param sign? Sign
---@param len? number
local function icon(sign, len)
  local spaces = len or 0
  sign = sign or {}
  local text = sign.text
  if spaces > 0 then
    text = fn.strcharpart(sign.text or '', 0, spaces) ---@type string
    text = text .. string.rep(space, spaces - fn.strchars(text))
  end
  return sign.texthl and ('%#' .. sign.texthl .. '#' .. text .. '%*') or text
end

function rvim.ui.statuscolumn.render()
  local win = vim.g.statusline_winid
  if wo[win].signcolumn == 'no' then return '' end

  local lnum = v.lnum
  local buf = api.nvim_win_get_buf(win)
  local marks = get_mark(buf, lnum)
  local gitsigns, other_sns = get_signs(buf, lnum)

  local left = {}
  if marks then left[#left + 1] = icon(marks, 2) end
  if #other_sns > 0 then
    vim
      .iter(other_sns)
      :fold('', function(_, item) left[#left + 1] = icon(item, 2) end)
  end

  local fold
  api.nvim_win_call(win, function()
    if fn.foldclosed(lnum) >= 0 then
      fold = { text = fcs.foldclose or '', texthl = 'Comment' }
    end
    -- if fn.foldclosed(lnum) == -1 then
    --   fold =
    --     { text = fcs.foldopen or '', texthl = 'IndentBlanklineContextChar' }
    -- else
    --   fold = { text = fcs.foldclose or '', texthl = 'Comment' }
    -- end
    -- fold = { text = space }
  end)

  local nu = ''
  if wo[win].number and v.virtnum == 0 then
    nu = wo[win].relativenumber and v.relnum ~= 0 and v.relnum or lnum
  end

  return table.concat({
    #left > 0 and table.concat(left, '') or space,
    space,
    [[%=]],
    nu .. space,
    gitsigns and icon(gitsigns[1], 1) or space,
    icon(sep, 1),
    icon(fold, 2),
  }, '')
end

opt.statuscolumn = [[%!v:lua.rvim.ui.statuscolumn.render()]]

rvim.augroup('StatusCol', {
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
      --   opt.statuscolumn = [[%!v:lua.rvim.ui.statuscolumn.render()]]
    end
  end,
})
