if not rvim or not vim.o.statuscolumn then return end

local fn, g, v, api = vim.fn, vim.g, vim.v, vim.api

---@alias SignColumnItem {name:string, text:string, texthl:string}

local sep_hl = '%#StatusColSep#'
local space = ' '
local separator = '▏' -- '│'

rvim.statuscolumn = {}

---@param group string
---@param text string
---@return string
local function hl(group, text) return '%#' .. group .. '#' .. text .. '%*' end

---@return SignColumnItem[]
local function get_signs()
  local buf = api.nvim_win_get_buf(g.statusline_winid)
  return vim.tbl_map(
    function(sign) return fn.sign_getdefined(sign.name)[1] end,
    fn.sign_getplaced(buf, { group = '*', lnum = v.lnum })[1].signs
  )
end

local function fdm()
  local is_folded = fn.foldlevel(v.lnum) > fn.foldlevel(v.lnum - 1)
  return is_folded and (fn.foldclosed(v.lnum) == -1 and '▼' or '') or ' '
end

local function nr()
  local is_relative = vim.wo[g.statusline_winid].relativenumber
  local num = (is_relative and not rvim.empty(v.relnum)) and v.relnum or v.lnum
  return fn.substitute(num, '\\d\\zs\\ze\\' .. '%(\\d\\d\\d\\)\\+$', ',', 'g')
end

function rvim.statuscolumn.render()
  local sign, git_sign
  -- This is dependent on using normal signs (rather than extmarks) for git signs
  for _, s in ipairs(get_signs()) do
    if s.name:find('GitSign') then
      git_sign = s
    else
      sign = s
    end
  end
  local components = {
    sign and hl(sign.texthl, sign.text) or space,
    [[%=]],
    nr(),
    space,
    git_sign and hl(git_sign.texthl, git_sign.text:gsub(space, '')) or space,
    rvim.empty(v.relnum) and sep_hl or '',
    separator,
    fdm(),
    space,
  }
  return table.concat(components, '')
end

local excluded = {
  'neo-tree',
  'NeogitStatus',
  'NeogitCommitMessage',
  'undotree',
  'log',
  'lazy',
  'man',
  'dap-repl',
  'markdown',
  'vimwiki',
  'vim-plug',
  'gitcommit',
  'toggleterm',
  'fugitive',
  'list',
  'NvimTree',
  'startify',
  'help',
  'orgagenda',
  'org',
  'himalaya',
  'Trouble',
  'NeogitCommitMessage',
  'NeogitRebaseTodo',
}

vim.o.statuscolumn = [[%!v:lua.rvim.statuscolumn.render()]]

rvim.augroup('StatusCol', {
  {
    event = { 'BufEnter', 'FileType' },
    command = function(args)
      local buf = vim.bo[args.buf]
      if buf.bt ~= '' or vim.tbl_contains(excluded, buf.ft) then vim.opt_local.statuscolumn = '' end
    end,
  },
})

if not vim.o.statuscolumn then return end
