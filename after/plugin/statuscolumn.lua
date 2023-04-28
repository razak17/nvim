if not rvim or not rvim.ui.statuscolumn.enable then return end

---@alias ExtmarkSign {[1]: number, [2]: number, [3]: number, [4]: {sign_text: string, sign_hl_group: string}}

local fn, v, api, opt, optl = vim.fn, vim.v, vim.api, vim.opt, vim.opt_local
local ui, separators, falsy = rvim.ui, rvim.ui.icons.separators, rvim.falsy
local str = require('user.strings')

local space = ' '
local fcs = opt.fillchars:get()
local shade, separator = separators.light_shade_block, separators.left_thin_block -- '│'
local sep_hl = 'LineNr'

local function fdm(lnum)
  if fn.foldlevel(lnum) <= fn.foldlevel(lnum - 1) then return space end
  return fn.foldclosed(lnum) == -1 and fcs.foldopen or fcs.foldclose
end

---@param line_count integer
---@param lnum integer
---@param relnum integer
---@param virtnum integer
---@return string
local function nr(win, lnum, relnum, virtnum, line_count)
  local col_width = api.nvim_strwidth(tostring(line_count))
  if virtnum and virtnum ~= 0 then return space:rep(col_width - 1) .. (virtnum < 0 and shade or space) end -- virtual line
  local num = vim.wo[win].relativenumber and not falsy(relnum) and relnum or lnum
  local ln = fn.substitute(num, '\\d\\zs\\ze\\%(\\d\\d\\d\\)\\+$', ',', 'g')
  if line_count >= 1000 then col_width = col_width + 1 end
  local num_width = col_width - api.nvim_strwidth(ln)
  return string.rep(space, num_width) .. ln
end

---@generic T:table<string, any>
---@param t T the object to format
---@param k string the key to format
---@return T?
local function format_text(t, k)
  local txt = t[k] and t[k]:gsub('%s', '') or ''
  if #txt < 1 then return end
  t[k] = txt
  return t
end

---@param curbuf integer
---@param lnum integer
---@return StringComponent[] sgns non-git signs
local function signplaced_signs(curbuf, lnum)
  return vim.tbl_map(function(s)
    local sign = format_text(fn.sign_getdefined(s.name)[1], 'text')
    if not sign then return end
    return { { { sign.text, sign.texthl } }, after = '' }
  end, fn.sign_getplaced(curbuf, { group = '*', lnum = lnum })[1].signs)
end

---@param curbuf integer
---@return StringComponent[], StringComponent[]
local function extmark_signs(curbuf, lnum)
  lnum = lnum - 1
  ---@type ExtmarkSign[]
  local signs = api.nvim_buf_get_extmarks(curbuf, -1, { lnum, 0 }, { lnum, -1 }, { details = true, type = 'sign' })
  local sns = rvim.fold(function(acc, item)
    item = format_text(item[4], 'sign_text')
    local txt, hl = item.sign_text, item.sign_hl_group
    local is_git = hl:match('^Git')
    local target = is_git and acc.git or acc.other
    table.insert(target, { { { txt, hl } }, after = '' })
    return acc
  end, signs, { git = {}, other = {} })
  if #sns.git == 0 then sns.git = { str.spacer(1) } end
  return sns.git, sns.other
end

function ui.statuscolumn.render()
  local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
  local win = api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)

  local gitsign, other_sns = extmark_signs(buf, lnum)
  local sns = signplaced_signs(buf, lnum)
  vim.list_extend(sns, other_sns)

  local line_count = api.nvim_buf_line_count(buf)

  local right = {}
  local add = str.append(right)
  add(str.spacer(1), { { { nr(win, lnum, relnum, virtnum, line_count) } } }, unpack(gitsign))
  add({ { { separator, sep_hl } }, after = '' }, { { { fdm(lnum) } } })

  return str.display({ sns, right })
end

vim.o.statuscolumn = [[%!v:lua.rvim.ui.statuscolumn.render()]]

rvim.augroup('StatusCol', {
  event = { 'BufEnter', 'FileType' },
  command = function(args)
    local decor = ui.decorations.get({
      ft = vim.bo[args.buf].ft,
      fname = fn.bufname(args.buf),
      setting = 'statuscolumn',
    })
    if decor.ft == false or decor.fname == false then optl.statuscolumn = '' end
  end,
})
