if not rvim or not rvim.ui.statuscolumn.enable then return end

if rvim and rvim.none then return end

---@alias ExtmarkSign {[1]: number, [2]: number, [3]: number, [4]: {sign_text: string, sign_hl_group: string}}

local str = require('user.strings')
local section, spacer, display = str.section, str.spacer, str.display
local fn, v, api, opt = vim.fn, vim.v, vim.api, vim.opt
local ui, sep, falsy = rvim.ui, rvim.ui.icons.separators, rvim.falsy

local MIN_SIGN_WIDTH, space = 1, ' '
local fcs = opt.fillchars:get()
local shade, separator = sep.light_shade_block, sep.left_thin_block -- '│'

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
  if virtnum and virtnum ~= 0 then
    return space:rep(col_width - 1) .. (virtnum < 0 and shade or space)
  end -- virtual line
  local num = vim.wo[win].relativenumber and not falsy(relnum) and relnum or lnum
  if line_count > 999 then col_width = col_width + 1 end
  local ln = tostring(num):reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')
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
  local signs = api.nvim_buf_get_extmarks(
    curbuf,
    -1,
    { lnum, 0 },
    { lnum, -1 },
    { details = true, type = 'sign' }
  )
  local sns = vim
    .iter(signs)
    :map(function(item) return format_text(item[4], 'sign_text') end)
    :fold({ git = {}, other = {} }, function(acc, item)
      local txt, hl = item.sign_text, item.sign_hl_group
      -- Hack to remove number from trailblazer signs by replacing it with a bookmark icon
      local is_trail = hl:match('^Trail')
      if is_trail then txt = rvim.ui.codicons.misc.bookmark end
      local is_git = hl:match('^Git')
      local target = is_git and acc.git or acc.other
      table.insert(target, { { { txt, hl } }, after = '' })
      return acc
    end)
  if #sns.git == 0 then sns.git = { str.spacer(1) } end
  return sns.git, sns.other
end

function ui.statuscolumn.render()
  local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
  local win = api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)
  local line_count = api.nvim_buf_line_count(buf)

  local gitsign, other_sns = extmark_signs(buf, lnum)
  local sns = signplaced_signs(buf, lnum)
  vim.list_extend(sns, other_sns)
  while #sns < MIN_SIGN_WIDTH do
    table.insert(sns, spacer(1))
  end

  local r1 =
    section:new(spacer(1), { { { nr(win, lnum, relnum, virtnum, line_count) } } }, unpack(gitsign))
  local r2 = section:new({ { { separator, 'LineNr' } }, after = '' }, { { { fdm(lnum) } } })

  return display({ sns, r1 + r2 })
end

opt.statuscolumn = [[%!v:lua.rvim.ui.statuscolumn.render()]]

rvim.augroup('StatusCol', {
  event = { 'BufEnter', 'FileType', 'CursorHold' },
  command = function(args)
    local buf = args.buf
    local d =
      ui.decorations.get({ ft = vim.bo[buf].ft, fname = fn.bufname(buf), setting = 'statuscolumn' })
    if d.ft == false or d.fname == false then vim.opt_local.statuscolumn = '' end
  end,
})
