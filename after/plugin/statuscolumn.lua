if not rvim or not rvim.has('nvim-0.9') then return end

local fn, v, api, opt, optl = vim.fn, vim.v, vim.api, vim.opt, vim.opt_local
local ui, separators = rvim.ui, rvim.ui.icons.separators

local space = ' '
local fcs = opt.fillchars:get()
local fold_opened, fold_closed = fcs.foldopen, fcs.foldclose -- '▶'
local shade, separator = separators.light_shade_block, separators.left_thin_block -- '│'
local sep_hl = 'StatusColSep'

ui.statuscolumn = {}

---@param group string
---@param text string
---@return string
local function hl(group, text) return '%#' .. group .. '#' .. text .. '%*' end

---@param buf number
---@return {name:string, text:string, texthl:string}[]
local function get_signs(buf)
  return vim.tbl_map(
    function(sign) return fn.sign_getdefined(sign.name)[1] end,
    fn.sign_getplaced(buf, { group = '*', lnum = v.lnum })[1].signs
  )
end

local function fdm()
  if fn.foldlevel(v.lnum) <= fn.foldlevel(v.lnum - 1) then return space end
  return fn.foldclosed(v.lnum) == -1 and fold_opened or fold_closed
end

---@param win number
---@return string
local function nr(win)
  if v.virtnum < 0 then return shade end -- virtual line
  if v.virtnum > 0 then return space end -- wrapped line
  local num = vim.wo[win].relativenumber and not rvim.empty(v.relnum) and v.relnum or v.lnum
  local lnum = fn.substitute(num, '\\d\\zs\\ze\\%(\\d\\d\\d\\)\\+$', ',', 'g')
  local num_width = (vim.wo[win].numberwidth - 1) - api.nvim_strwidth(lnum)
  local padding = string.rep(space, num_width)
  return padding .. lnum
end

---@return string
---@return string|nil
local function sep()
  local separator_hl = (v.virtnum >= 0 and rvim.empty(v.relnum)) and sep_hl or nil
  return separator, separator_hl
end

local function signs_by_type(signs)
  local sgns, g_sgn
  for _, s in ipairs(signs) do
    if s.name:find('GitSign') then g_sgn = s end
    if s.name:find('Diagnostic') then sgns = s end
  end

  return sgns, g_sgn
end

function ui.statuscolumn.render()
  local curwin = api.nvim_get_current_win()
  local curbuf = api.nvim_win_get_buf(curwin)
  local signs = get_signs(curbuf)
  local sgns, g_sgn = signs_by_type(signs)

  local sns = sgns and hl(sgns.texthl, sgns.text:gsub(space, '')) or space
  local gitsigns = g_sgn and hl(g_sgn.texthl, g_sgn.text:gsub(space, '')) or space

  local components = {
    '%=',
    space,
    nr(curwin),
    space,
    sns,
    space,
    gitsigns,
    sep(),
    fdm(),
    space,
  }
  return table.concat(components, '')
end

vim.o.statuscolumn = [[%!v:lua.rvim.ui.statuscolumn.render()]]

rvim.augroup('StatusCol', {
  event = { 'BufEnter', 'FileType' },
  command = function(args)
    local has_statuscol = ui.decorations.get(vim.bo[args.buf].ft, 'statuscolumn', 'ft')
    if has_statuscol == false then optl.statuscolumn = '' end
  end,
})
