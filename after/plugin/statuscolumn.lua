if not rvim or not rvim.ui.statuscolumn.enable then return end

if rvim and rvim.none then return end

local fn, v, api, opt, wo = vim.fn, vim.v, vim.api, vim.opt, vim.wo
local sp = rvim.ui.icons.separators

local separator = sp.left_thin_block
local fcs = opt.fillchars:get()
local space = ' '

---@alias Sign {name:string, text:string, texthl:string, priority:number}

-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@return Sign[]
---@param buf number
---@param lnum number
local function get_signs(buf, lnum)
  -- Get regular signs
  ---@type Sign[]
  local signs = vim.tbl_map(function(sign)
    ---@type Sign
    local ret = fn.sign_getdefined(sign.name)[1]
    ret.priority = sign.priority
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
  for _, extmark in pairs(extmarks) do
    signs[#signs + 1] = {
      name = extmark[4].sign_hl_group or '',
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end

  -- Sort by priority
  table.sort(
    signs,
    function(a, b) return (a.priority or 0) < (b.priority or 0) end
  )

  return signs
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
  sign = sign or {}
  len = len or 2
  local text = fn.strcharpart(sign.text or '', 0, len) ---@type string
  text = text .. string.rep(space, len - fn.strchars(text))
  return sign.texthl and ('%#' .. sign.texthl .. '#' .. text .. '%*') or text
end

function rvim.ui.statuscolumn()
  local win = vim.g.statusline_winid
  if wo[win].signcolumn == 'no' then return '' end
  local buf = api.nvim_win_get_buf(win)

  ---@type Sign?,Sign?,Sign?
  local left, gitsigns, fold
  for _, s in ipairs(get_signs(buf, v.lnum)) do
    if s.name and s.name:find('GitSign') then
      gitsigns = s
    else
      left = s
    end
  end

  local lnum = v.lnum
  api.nvim_win_call(win, function()
    local folded = fn.foldlevel(lnum) > fn.foldlevel(lnum - 1)

    if not folded then fold = { text = ' ' } end

    if folded and fn.foldclosed(lnum) == -1 then
      fold = { text = fcs.foldopen or '', texthl = 'Folded' }
    end

    if folded and fn.foldclosed(lnum) ~= -1 then
      fold = { text = fcs.foldclose or '', texthl = 'Folded' }
    end
  end)

  local nu = ''
  if wo[win].number and v.virtnum == 0 then
    nu = wo[win].relativenumber and v.relnum ~= 0 and v.relnum or lnum
  end

  local sep = { text = separator, texthl = 'LineNr' }

  return table.concat({
    icon(get_mark(buf, lnum) or left),
    [[%=]],
    nu .. space,
    icon(gitsigns, 1),
    icon(sep, 1),
    icon(fold),
  }, '')
end

opt.statuscolumn = [[%!v:lua.rvim.ui.statuscolumn()]]
