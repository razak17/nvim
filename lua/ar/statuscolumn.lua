local fn, api = vim.fn, vim.api
local ui, falsy, format_text = ar.ui, ar.falsy, ar.format_text
local icons = ui.icons
local fcs = vim.opt.fillchars:get()

local M = {}

---@param num? integer
---@return string
function M.space(num) return string.rep(' ', num or 1) end

---@alias ExtmarkSign {[1]: number, [2]: number, [3]: number, [4]: {sign_text: string, sign_hl_group: string}}
---@alias Sign {name:string, text:string, texthl:string, priority:number}

---@param line_count integer
---@param lnum integer
---@param relnum integer
---@param virtnum integer
---@return string
function M.nr(win, lnum, relnum, virtnum, line_count)
  local col_width = api.nvim_strwidth(tostring(line_count))
  if virtnum and virtnum ~= 0 then
    return M.space():rep(col_width - 1) .. (virtnum < 0 and '' or M.space())
  end -- virtual line
  local num = vim.wo[win].relativenumber and not falsy(relnum) and relnum
    or lnum
  if line_count > 999 then col_width = col_width + 1 end
  local ln =
    tostring(num):reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')
  local num_width = col_width - api.nvim_strwidth(ln)

  local v_hl = ''

  local mode = fn.strtrans(fn.mode()):lower():gsub('%W', '')
  if mode == 'v' then
    local v_range = ar.get_visual_range()
    local is_in_range = lnum >= v_range[1] and lnum <= v_range[3]
    v_hl = is_in_range and '%#CursorLineNr#' or ''
  end
  if num_width == 0 then return v_hl .. ln end
  return string.rep(M.space(), num_width) .. v_hl .. ln
end

-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@return Sign[],Sign[]
---@param curbuf integer
---@param lnum number
function M.extmark_signs(curbuf, lnum)
  ---@type ExtmarkSign[]
  local signs = api.nvim_buf_get_extmarks(
    curbuf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = 'sign' }
  )
  local sns = vim
    .iter(signs)
    :map(function(item) return format_text(item[4], 'sign_text') end)
    :fold({ git = {}, other = {} }, function(acc, item)
      local txt, hl = item.sign_text, item.sign_hl_group
      -- HACK: to remove number from trailblazer signs by replacing it with a bookmark icon
      if hl:match('^Trail') then txt = ui.codicons.misc.bookmark end
      local is_git = hl:match('^Git') or hl:match('^MiniDiffSign')
      local target = is_git and acc.git or acc.other
      table.insert(target, { text = txt, texthl = hl })
      return acc
    end)
  return sns.git, sns.other
end

---@return Sign?
---@param buf number
---@param lnum number
function M.get_mark(buf, lnum)
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
function M.icon(sign, len)
  local spaces = len or 0
  sign = sign or {}
  local text = sign.text
  if spaces > 0 then
    text = fn.strcharpart(sign.text or '', 0, spaces) ---@type string
    text = text .. string.rep(M.space(), spaces - fn.strchars(text))
  end
  return sign.texthl and ('%#' .. sign.texthl .. '#' .. text .. '%*') or text
end

---@param buf integer
---@param lnum integer
function M.get_left(buf, lnum)
  local marks = M.get_mark(buf, lnum)
  local gitsigns, other_sns = M.extmark_signs(buf, lnum)
  local left = {}
  if marks then
    if #other_sns == 0 then
      left[#left + 1] = M.icon(marks, 2)
    else
      left[#left + 1] = M.icon(marks, 1)
    end
  end
  if #other_sns > 0 then
    vim.iter(other_sns):fold(left, function(acc, key)
      if #acc == 0 then
        acc[#acc + 1] = M.icon(key, 1)
      else
        acc[#acc + 1] = M.space() .. M.icon(key, 0)
      end
      return acc
    end)
  end
  local signs = #left > 0 and table.concat(left, '') or M.space(2)

  return signs, gitsigns
end

---@param lnum integer
---@return Sign?
function M.get_fold(lnum)
  -- https://www.reddit.com/r/neovim/comments/1djjc6q/statuscolumn_a_beginers_guide/
  local foldlevel = fn.foldlevel(lnum)
  local foldlevel_before = fn.foldlevel((lnum - 1) >= 1 and lnum - 1 or 1)
  local foldlevel_after =
    fn.foldlevel((lnum + 1) <= fn.line('$') and (lnum + 1) or fn.line('$'))

  local foldclosed = fn.foldclosed(lnum)

  -- Line is in the middle of an open fold
  local fold = { text = M.space(), texthl = 'IndentBlanklineChar' } -- │
  -- Line has nothing to do with folds so we will skip it
  if foldlevel == 0 then
    fold = { text = M.space(), texthl = 'Comment' }
    -- Line is a closed fold (I know second condition feels unnecessary but I will still add it)
  elseif foldclosed ~= -1 and foldclosed == lnum then
    fold =
      { text = fcs.foldclose or icons.chevron_right, texthl = 'StatusColFold' }
    -- I didn't use ~= because it couldn't make a nested fold have a lower level than it's parent fold and it's not something I would use
  elseif foldlevel > foldlevel_before then
    fold =
      { text = fcs.foldopen or icons.chevron_down, texthl = 'StatusColFold' }
    -- The line is the last line in the fold
  elseif foldlevel > foldlevel_after then
    fold = { text = M.space(), texthl = 'IndentBlanklineChar' } --  ╰
  end

  return fold
end

return M
